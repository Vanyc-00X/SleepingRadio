import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;

import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/playback_progress_repository.dart';
import '../../../domain/models/playback_session.dart';
import 'sleep_timer_math.dart';

/// Фоновый обработчик: воспроизведение, seek, таймер сна с fade-out.
class SleepingAudioHandler extends BaseAudioHandler with SeekHandler {
  SleepingAudioHandler(this._progressRepository);

  static const demoMediaId = 'demo_night_loop';
  static const demoAssetPath = 'assets/audio/night_loop.wav';

  static final extendTimerControl = MediaControl.custom(
    androidIcon: 'drawable/audio_service_fast_forward',
    label: '+15 мин',
    name: 'extend_timer',
  );

  final PlaybackProgressRepository _progressRepository;
  final AudioPlayer _player = AudioPlayer();

  final _sessionController = StreamController<PlaybackSession>.broadcast();
  Stream<PlaybackSession> get sessionStream => _sessionController.stream;

  PlaybackSession _session = const PlaybackSession(
    title: 'Ночной демо-трек',
  );

  Timer? _ticker;
  bool _loaded = false;
  final double _baseVolume = 1;
  bool _fading = false;

  PlaybackSession get session => _session;

  Future<void> ready() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _player.playbackEventStream.listen(_broadcastPlaybackState);
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        unawaited(_onNaturalComplete());
      }
    });
    _player.durationStream.listen((duration) {
      if (duration != null) {
        _emit(_session.copyWith(duration: duration));
      }
    });
    _player.positionStream.listen((position) {
      _emit(_session.copyWith(position: position));
      final id = _session.currentEpisodeId;
      if (id != null) {
        unawaited(
          _progressRepository.save(mediaId: id, position: position),
        );
      }
    });

    await loadDemoTrack();
  }

  Future<void> loadDemoTrack() async {
    _emit(
      _session.copyWith(
        currentEpisodeId: demoMediaId,
        title: 'Ночной демо-трек',
        state: PlayerState.loading,
      ),
    );

    final item = MediaItem(
      id: demoMediaId,
      title: 'Ночной демо-трек',
      album: AppConstants.appNameShort,
      artist: AppConstants.appName,
      duration: const Duration(seconds: 45),
    );
    mediaItem.add(item);

    final saved = await _progressRepository.load(demoMediaId);
    await _player.setAudioSource(
      AudioSource.asset(demoAssetPath),
      initialPosition: saved,
    );
    await _player.setLoopMode(LoopMode.one);
    _loaded = true;

    _emit(
      _session.copyWith(
        currentEpisodeId: demoMediaId,
        position: saved,
        duration: _player.duration ?? const Duration(seconds: 45),
        state: PlayerState.paused,
        title: 'Ночной демо-трек',
      ),
    );
    _broadcastPlaybackState(_player.playbackEvent);
  }

  @override
  Future<void> play() async {
    if (!_loaded) await loadDemoTrack();
    await _player.setLoopMode(
      _session.playUntilEnd ? LoopMode.off : LoopMode.one,
    );
    await _player.setVolume(_baseVolume);
    _fading = false;
    await _player.play();
    _emit(_session.copyWith(state: PlayerState.playing));
    _ensureTicker();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    _emit(_session.copyWith(state: PlayerState.paused));
    await _persistPosition();
  }

  @override
  Future<void> stop() async {
    await _clearTimer();
    await _player.stop();
    await _player.seek(Duration.zero);
    await _player.setVolume(_baseVolume);
    _emit(
      const PlaybackSession(
        currentEpisodeId: demoMediaId,
        title: 'Ночной демо-трек',
      ),
    );
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> seekBy(Duration offset) async {
    final next = _player.position + offset;
    final duration = _player.duration;
    var clamped = next < Duration.zero ? Duration.zero : next;
    if (duration != null && clamped > duration) clamped = duration;
    await seek(clamped);
  }

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  Future<void> setSleepTimer({
    int? minutes,
    bool playUntilEnd = false,
  }) async {
    _fading = false;
    await _player.setVolume(_baseVolume);

    if (playUntilEnd) {
      _ticker?.cancel();
      await _player.setLoopMode(LoopMode.off);
      _emit(
        _session.copyWith(
          playUntilEnd: true,
          clearTimerEndsAt: true,
          clearTimerPreset: true,
          state: _player.playing ? PlayerState.playing : _session.state,
        ),
      );
      _broadcastPlaybackState(_player.playbackEvent);
      return;
    }

    if (minutes == null || minutes <= 0) {
      await _clearTimer();
      await _player.setLoopMode(LoopMode.one);
      return;
    }

    await _player.setLoopMode(LoopMode.one);
    final endsAt = DateTime.now().add(Duration(minutes: minutes));
    _emit(
      _session.copyWith(
        timerEndsAt: endsAt,
        timerPresetMinutes: minutes,
        playUntilEnd: false,
      ),
    );
    _ensureTicker();
    _broadcastPlaybackState(_player.playbackEvent);
  }

  Future<void> extendSleepTimer([
    int minutes = AppConstants.timerExtendMinutes,
  ]) async {
    if (_session.playUntilEnd) return;

    final now = DateTime.now();
    final currentEnd = _session.timerEndsAt;
    final base = (currentEnd == null || currentEnd.isBefore(now))
        ? now
        : currentEnd;

    _fading = false;
    await _player.setVolume(_baseVolume);
    final endsAt = base.add(Duration(minutes: minutes));
    final remainingMinutes = endsAt.difference(now).inMinutes.clamp(1, 24 * 60);
    _emit(
      _session.copyWith(
        timerEndsAt: endsAt,
        timerPresetMinutes: remainingMinutes,
        playUntilEnd: false,
        state: _player.playing ? PlayerState.playing : _session.state,
      ),
    );
    _ensureTicker();
    _broadcastPlaybackState(_player.playbackEvent);
  }

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    switch (name) {
      case 'extend_timer':
        await extendSleepTimer();
        return null;
      case 'set_timer':
        await setSleepTimer(
          minutes: extras?['minutes'] as int?,
          playUntilEnd: extras?['playUntilEnd'] as bool? ?? false,
        );
        return null;
      default:
        return super.customAction(name, extras);
    }
  }

  @override
  Future<void> rewind() =>
      seekBy(const Duration(seconds: -AppConstants.seekStepSeconds));

  @override
  Future<void> fastForward() =>
      seekBy(const Duration(seconds: AppConstants.seekStepSeconds));

  void _ensureTicker() {
    _ticker?.cancel();
    if (_session.timerEndsAt == null) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      unawaited(_onTick());
    });
  }

  Future<void> _onTick() async {
    final endsAt = _session.timerEndsAt;
    if (endsAt == null) return;

    final remaining = endsAt.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      await _finishByTimer();
      return;
    }

    const fadeFor = Duration(seconds: AppConstants.fadeOutSecondsDefault);
    if (remaining <= fadeFor && _player.playing) {
      if (!_fading) {
        _fading = true;
        _emit(_session.copyWith(state: PlayerState.fadingOut));
      }
      await _player.setVolume(
        computeFadeVolume(
          remaining: remaining,
          fadeFor: fadeFor,
          baseVolume: _baseVolume,
        ),
      );
    }

    // Новый инстанс — чтобы UI пересчитал timerRemaining.
    _emit(_session.copyWith());
    _broadcastPlaybackState(_player.playbackEvent);
  }

  Future<void> _finishByTimer() async {
    _ticker?.cancel();
    _fading = false;
    await _player.pause();
    await _player.setVolume(_baseVolume);
    await _persistPosition();
    _emit(
      _session.copyWith(
        state: PlayerState.paused,
        clearTimerEndsAt: true,
        clearTimerPreset: true,
        playUntilEnd: false,
      ),
    );
    _broadcastPlaybackState(_player.playbackEvent);
  }

  Future<void> _onNaturalComplete() async {
    if (!_session.playUntilEnd) return;
    await _persistPosition();
    await _player.seek(Duration.zero);
    await _player.pause();
    _emit(
      _session.copyWith(
        state: PlayerState.completed,
        position: Duration.zero,
        playUntilEnd: false,
      ),
    );
    _broadcastPlaybackState(_player.playbackEvent);
  }

  Future<void> _clearTimer() async {
    _ticker?.cancel();
    _fading = false;
    await _player.setVolume(_baseVolume);
    _emit(
      _session.copyWith(
        clearTimerEndsAt: true,
        clearTimerPreset: true,
        playUntilEnd: false,
      ),
    );
    _broadcastPlaybackState(_player.playbackEvent);
  }

  Future<void> _persistPosition() async {
    final id = _session.currentEpisodeId;
    if (id == null) return;
    await _progressRepository.save(mediaId: id, position: _player.position);
  }

  void _emit(PlaybackSession next) {
    _session = next;
    _sessionController.add(next);
  }

  void _broadcastPlaybackState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.rewind,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.fastForward,
          if (_session.timerEndsAt != null) extendTimerControl,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.play,
          MediaAction.pause,
          MediaAction.stop,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: event.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ),
    );
  }

  Future<void> disposePlayer() async {
    _ticker?.cancel();
    await _sessionController.close();
    await _player.dispose();
  }
}
