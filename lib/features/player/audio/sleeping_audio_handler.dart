import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;

import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/books_repository.dart';
import '../../../data/repositories/playback_progress_repository.dart';
import '../../../domain/models/playback_session.dart';
import 'book_tts_engine.dart';
import 'sleep_timer_math.dart';

/// Фоновый обработчик: демо-аудио + чтение книг (TTS), таймер сна.
class SleepingAudioHandler extends BaseAudioHandler with SeekHandler {
  SleepingAudioHandler({
    required this.progressRepository,
    required this.booksRepository,
  });

  static const demoMediaId = 'demo_night_loop';
  static const demoAssetPath = 'assets/audio/night_loop.wav';

  static final extendTimerControl = MediaControl.custom(
    androidIcon: 'drawable/audio_service_fast_forward',
    label: '+15 мин',
    name: 'extend_timer',
  );

  final PlaybackProgressRepository progressRepository;
  final BooksRepository booksRepository;
  final AudioPlayer _player = AudioPlayer();
  final BookTtsEngine _tts = BookTtsEngine();

  final _sessionController = StreamController<PlaybackSession>.broadcast();
  Stream<PlaybackSession> get sessionStream => _sessionController.stream;

  PlaybackSession _session = const PlaybackSession(
    title: 'Ночной демо-трек',
  );

  Timer? _ticker;
  bool _demoLoaded = false;
  bool _bookMode = false;
  bool _ttsLoop = false;
  final double _baseVolume = 1;
  bool _fading = false;
  double _speechRate = 1;

  PlaybackSession get session => _session;

  Future<void> ready() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    await _tts.ready();

    _tts.onProgress = (offset, completed) {
      unawaited(_onTtsProgress(offset, completed));
    };

    _player.playbackEventStream.listen((event) {
      if (!_bookMode) _broadcastAudioState(event);
    });
    _player.processingStateStream.listen((state) {
      if (!_bookMode && state == ProcessingState.completed) {
        unawaited(_onNaturalComplete());
      }
    });
    _player.durationStream.listen((duration) {
      if (!_bookMode && duration != null) {
        _emit(_session.copyWith(duration: duration));
      }
    });
    _player.positionStream.listen((position) {
      if (_bookMode) return;
      _emit(_session.copyWith(position: position));
      final id = _session.currentEpisodeId;
      if (id != null) {
        unawaited(
          progressRepository.save(mediaId: id, position: position),
        );
      }
    });

    await loadDemoTrack(autoplay: false);
  }

  Future<void> loadDemoTrack({bool autoplay = false}) async {
    await _tts.stop();
    _bookMode = false;
    _emit(
      _session.copyWith(
        currentEpisodeId: demoMediaId,
        title: 'Ночной демо-трек',
        subtitle: '',
        isBookMode: false,
        state: PlayerState.loading,
      ),
    );

    mediaItem.add(
      MediaItem(
        id: demoMediaId,
        title: 'Ночной демо-трек',
        album: AppConstants.appNameShort,
        artist: AppConstants.appName,
        duration: const Duration(seconds: 45),
      ),
    );

    final saved = await progressRepository.load(demoMediaId);
    await _player.setAudioSource(
      AudioSource.asset(demoAssetPath),
      initialPosition: saved,
    );
    await _player.setLoopMode(LoopMode.one);
    _demoLoaded = true;

    _emit(
      _session.copyWith(
        currentEpisodeId: demoMediaId,
        position: saved,
        duration: _player.duration ?? const Duration(seconds: 45),
        state: PlayerState.paused,
        title: 'Ночной демо-трек',
        subtitle: '',
        isBookMode: false,
      ),
    );
    _broadcastAudioState(_player.playbackEvent);
    if (autoplay) await play();
  }

  Future<void> playBookChapter({
    required String bookId,
    required String chapterId,
    required String bookTitle,
    required String chapterTitle,
    required String text,
    required int startCharOffset,
    required double speechRate,
  }) async {
    await _player.stop();
    _bookMode = true;
    _speechRate = speechRate;
    _fading = false;

    final mediaId = 'book:$bookId:$chapterId';
    _emit(
      _session.copyWith(
        currentEpisodeId: mediaId,
        bookId: bookId,
        chapterId: chapterId,
        title: bookTitle,
        subtitle: chapterTitle,
        isBookMode: true,
        state: PlayerState.loading,
      ),
    );

    await _tts.prepare(
      text: text,
      startOffset: startCharOffset,
      speechRate: speechRate,
    );

    final duration = _tts.estimateDuration();
    mediaItem.add(
      MediaItem(
        id: mediaId,
        title: chapterTitle,
        album: bookTitle,
        artist: AppConstants.appName,
        duration: duration,
      ),
    );

    _emit(
      _session.copyWith(
        currentEpisodeId: mediaId,
        bookId: bookId,
        chapterId: chapterId,
        title: bookTitle,
        subtitle: chapterTitle,
        isBookMode: true,
        position: _tts.estimatePosition(),
        duration: duration,
        state: PlayerState.paused,
      ),
    );
    _broadcastTtsState(playing: false);
    await booksRepository.touchOpened(bookId);
    await play();
  }

  @override
  Future<void> play() async {
    _fading = false;
    if (_bookMode) {
      await _tts.setVolume(_baseVolume);
      _emit(_session.copyWith(state: PlayerState.playing));
      _broadcastTtsState(playing: true);
      _ensureTicker();
      unawaited(_runTtsPlayback());
      return;
    }

    if (!_demoLoaded) await loadDemoTrack();
    await _player.setLoopMode(
      _session.playUntilEnd ? LoopMode.off : LoopMode.one,
    );
    await _player.setVolume(_baseVolume);
    await _player.play();
    _emit(_session.copyWith(state: PlayerState.playing));
    _ensureTicker();
  }

  Future<void> _runTtsPlayback() async {
    _ttsLoop = true;
    await _tts.play();
    _ttsLoop = false;
  }

  @override
  Future<void> pause() async {
    if (_bookMode) {
      await _tts.pause();
      _emit(_session.copyWith(state: PlayerState.paused));
      _broadcastTtsState(playing: false);
      await _persistBookProgress();
      return;
    }
    await _player.pause();
    _emit(_session.copyWith(state: PlayerState.paused));
    await _persistDemoPosition();
  }

  @override
  Future<void> stop() async {
    await _clearTimer();
    if (_bookMode) {
      await _tts.stop();
      await _persistBookProgress();
    } else {
      await _player.stop();
      await _player.seek(Duration.zero);
    }
    await _player.setVolume(_baseVolume);
    await _tts.setVolume(_baseVolume);
    _emit(
      const PlaybackSession(
        currentEpisodeId: demoMediaId,
        title: 'Ночной демо-трек',
      ),
    );
    _bookMode = false;
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    if (_bookMode) {
      final duration = _session.duration.inMilliseconds;
      if (duration <= 0) return;
      final ratio = (position.inMilliseconds / duration).clamp(0.0, 1.0);
      final offset = (_tts.totalChars * ratio).round();
      await _tts.seekToChar(offset);
      _emit(
        _session.copyWith(
          position: _tts.estimatePosition(),
          state: _tts.isPlaying ? PlayerState.playing : PlayerState.paused,
        ),
      );
      await _persistBookProgress();
      return;
    }
    await _player.seek(position);
  }

  Future<void> seekBy(Duration offset) async {
    if (_bookMode) {
      await _tts.seekBySeconds(offset.inSeconds);
      _emit(
        _session.copyWith(
          position: _tts.estimatePosition(),
          state: _tts.isPlaying ? PlayerState.playing : PlayerState.paused,
        ),
      );
      _broadcastTtsState(playing: _tts.isPlaying || _ttsLoop);
      await _persistBookProgress();
      return;
    }
    final next = _player.position + offset;
    final duration = _player.duration;
    var clamped = next < Duration.zero ? Duration.zero : next;
    if (duration != null && clamped > duration) clamped = duration;
    await seek(clamped);
  }

  @override
  Future<void> setSpeed(double speed) async {
    _speechRate = speed;
    if (_bookMode) {
      await _tts.setSpeechRate(speed);
      _emit(_session.copyWith(duration: _tts.estimateDuration()));
      return;
    }
    await _player.setSpeed(speed);
  }

  Future<void> setSleepTimer({
    int? minutes,
    bool playUntilEnd = false,
  }) async {
    _fading = false;
    await _player.setVolume(_baseVolume);
    await _tts.setVolume(_baseVolume);

    if (playUntilEnd) {
      _ticker?.cancel();
      if (!_bookMode) await _player.setLoopMode(LoopMode.off);
      _emit(
        _session.copyWith(
          playUntilEnd: true,
          clearTimerEndsAt: true,
          clearTimerPreset: true,
          state: _isActivelyPlaying
              ? PlayerState.playing
              : _session.state,
        ),
      );
      _refreshControls();
      return;
    }

    if (minutes == null || minutes <= 0) {
      await _clearTimer();
      if (!_bookMode) await _player.setLoopMode(LoopMode.one);
      return;
    }

    if (!_bookMode) await _player.setLoopMode(LoopMode.one);
    final endsAt = DateTime.now().add(Duration(minutes: minutes));
    _emit(
      _session.copyWith(
        timerEndsAt: endsAt,
        timerPresetMinutes: minutes,
        playUntilEnd: false,
      ),
    );
    _ensureTicker();
    _refreshControls();
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
    await _tts.setVolume(_baseVolume);
    final endsAt = base.add(Duration(minutes: minutes));
    final remainingMinutes = endsAt.difference(now).inMinutes.clamp(1, 24 * 60);
    _emit(
      _session.copyWith(
        timerEndsAt: endsAt,
        timerPresetMinutes: remainingMinutes,
        playUntilEnd: false,
        state: _isActivelyPlaying ? PlayerState.playing : _session.state,
      ),
    );
    _ensureTicker();
    _refreshControls();
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

  bool get _isActivelyPlaying =>
      _bookMode ? (_tts.isPlaying || _ttsLoop) : _player.playing;

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
    if (remaining <= fadeFor && _isActivelyPlaying) {
      if (!_fading) {
        _fading = true;
        _emit(_session.copyWith(state: PlayerState.fadingOut));
      }
      final volume = computeFadeVolume(
        remaining: remaining,
        fadeFor: fadeFor,
        baseVolume: _baseVolume,
      );
      if (_bookMode) {
        await _tts.setVolume(volume);
      } else {
        await _player.setVolume(volume);
      }
    }

    _emit(_session.copyWith());
    _refreshControls();
  }

  Future<void> _finishByTimer() async {
    _ticker?.cancel();
    _fading = false;
    if (_bookMode) {
      await _tts.pause();
      await _tts.setVolume(_baseVolume);
      await _persistBookProgress();
    } else {
      await _player.pause();
      await _player.setVolume(_baseVolume);
      await _persistDemoPosition();
    }
    _emit(
      _session.copyWith(
        state: PlayerState.paused,
        clearTimerEndsAt: true,
        clearTimerPreset: true,
        playUntilEnd: false,
      ),
    );
    _refreshControls();
  }

  Future<void> _onNaturalComplete() async {
    if (!_session.playUntilEnd) return;
    await _persistDemoPosition();
    await _player.seek(Duration.zero);
    await _player.pause();
    _emit(
      _session.copyWith(
        state: PlayerState.completed,
        position: Duration.zero,
        playUntilEnd: false,
      ),
    );
    _refreshControls();
  }

  Future<void> _onTtsProgress(int offset, bool completed) async {
    if (!_bookMode) return;
    _emit(
      _session.copyWith(
        position: _tts.estimatePosition(),
        duration: _tts.estimateDuration(),
        state: completed
            ? PlayerState.completed
            : (_tts.isPlaying || _ttsLoop
                  ? (_fading ? PlayerState.fadingOut : PlayerState.playing)
                  : PlayerState.paused),
      ),
    );
    await _persistBookProgress();
    _broadcastTtsState(playing: !completed && (_tts.isPlaying || _ttsLoop));

    if (completed) {
      if (_session.playUntilEnd) {
        _emit(_session.copyWith(playUntilEnd: false, state: PlayerState.completed));
      }
    }
  }

  Future<void> _clearTimer() async {
    _ticker?.cancel();
    _fading = false;
    await _player.setVolume(_baseVolume);
    await _tts.setVolume(_baseVolume);
    _emit(
      _session.copyWith(
        clearTimerEndsAt: true,
        clearTimerPreset: true,
        playUntilEnd: false,
      ),
    );
    _refreshControls();
  }

  Future<void> _persistDemoPosition() async {
    final id = _session.currentEpisodeId;
    if (id == null) return;
    await progressRepository.save(mediaId: id, position: _player.position);
  }

  Future<void> _persistBookProgress() async {
    final bookId = _session.bookId;
    final chapterId = _session.chapterId;
    if (bookId == null || chapterId == null) return;
    final total = _tts.totalChars;
    final percent = total <= 0 ? 0.0 : (_tts.charOffset / total) * 100;
    await booksRepository.updateProgress(
      bookId: bookId,
      chapterId: chapterId,
      charOffset: _tts.charOffset,
      percent: percent,
    );
  }

  void _emit(PlaybackSession next) {
    _session = next;
    _sessionController.add(next);
  }

  void _refreshControls() {
    if (_bookMode) {
      _broadcastTtsState(playing: _isActivelyPlaying);
    } else {
      _broadcastAudioState(_player.playbackEvent);
    }
  }

  void _broadcastAudioState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(
      playbackState.value.copyWith(
        controls: _controls(playing),
        systemActions: _systemActions,
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

  void _broadcastTtsState({required bool playing}) {
    playbackState.add(
      playbackState.value.copyWith(
        controls: _controls(playing),
        systemActions: _systemActions,
        androidCompactActionIndices: const [0, 1, 2],
        processingState: playing
            ? AudioProcessingState.ready
            : AudioProcessingState.ready,
        playing: playing,
        updatePosition: _tts.estimatePosition(),
        bufferedPosition: _tts.estimateDuration(),
        speed: _speechRate,
      ),
    );
  }

  List<MediaControl> _controls(bool playing) => [
    MediaControl.rewind,
    if (playing) MediaControl.pause else MediaControl.play,
    MediaControl.fastForward,
    if (_session.timerEndsAt != null) extendTimerControl,
  ];

  static const _systemActions = {
    MediaAction.seek,
    MediaAction.seekForward,
    MediaAction.seekBackward,
    MediaAction.play,
    MediaAction.pause,
    MediaAction.stop,
  };

  Future<void> disposePlayer() async {
    _ticker?.cancel();
    await _tts.dispose();
    await _sessionController.close();
    await _player.dispose();
  }
}
