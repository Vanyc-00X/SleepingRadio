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
  static const ambientAssetPath = 'assets/audio/night_loop.wav';

  static final extendTimerControl = MediaControl.custom(
    androidIcon: 'drawable/audio_service_fast_forward',
    label: '+15 мин',
    name: 'extend_timer',
  );

  final PlaybackProgressRepository progressRepository;
  final BooksRepository booksRepository;
  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _ambient = AudioPlayer();
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
  double _voiceVolume = 1;
  bool _fading = false;
  double _speechRate = 1;
  bool _ambientEnabled = false;
  double _ambientVolume = 0.12;
  bool _ambientLoaded = false;
  bool _autoAdvanceChapters = true;
  int _interChunkPauseMs = 280;
  String _scriptText = '';
  _BookTtsParams? _lastBookParams;

  PlaybackSession get session => _session;

  double get _effectiveVoiceVolume => _voiceVolume.clamp(0.15, 1.0);

  void setInterChunkPauseMs(int ms) {
    _interChunkPauseMs = ms.clamp(0, 2000);
  }

  /// Смена голоса во время озвучки (с текущего места).
  Future<void> switchVoice(String voiceId) async {
    if (!_bookMode) return;
    final shouldResume = _tts.isPlaying || _ttsLoop;
    await _tts.switchVoice(voiceId);
    final prev = _lastBookParams;
    if (prev != null) {
      _lastBookParams = prev.copyWith(voiceId: voiceId);
    }
    // Дождаться выхода текущего TTS-цикла.
    var guard = 0;
    while (_ttsLoop && guard < 40) {
      await Future<void>.delayed(const Duration(milliseconds: 25));
      guard++;
    }
    _emit(
      _session.copyWith(
        voiceId: voiceId,
        position: _tts.estimatePosition(),
        duration: _tts.estimateDuration(),
        currentChunkIndex: _tts.currentChunkIndex,
        charOffset: _tts.charOffset,
        state: shouldResume ? PlayerState.playing : PlayerState.paused,
      ),
    );
    if (shouldResume) {
      _emit(_session.copyWith(state: PlayerState.playing));
      _broadcastTtsState(playing: true);
      unawaited(_runTtsPlayback());
    } else {
      _broadcastTtsState(playing: false);
    }
  }

  Future<void> ready() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
    } catch (_) {
      // На части устройств session configure может падать — не блокируем старт.
    }

    try {
      await _tts.ready();
    } catch (_) {}

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

    try {
      await loadDemoTrack(autoplay: false);
    } catch (_) {
      _demoLoaded = false;
      _emit(
        const PlaybackSession(
          currentEpisodeId: demoMediaId,
          title: 'Ночной демо-трек',
          state: PlayerState.paused,
        ),
      );
    }
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
    double pitch = 1,
    String voiceId = 'calm_female_ru',
    bool preferCloud = false,
    String? ttsApiKey,
    String? ttsBaseUrl,
    String? comfyUrl,
    int cacheLimitGb = 2,
  }) async {
    await _player.stop();
    _bookMode = true;
    _speechRate = speechRate;
    _fading = false;
    _lastBookParams = _BookTtsParams(
      speechRate: speechRate,
      pitch: pitch,
      voiceId: voiceId,
      preferCloud: preferCloud,
      ttsApiKey: ttsApiKey,
      ttsBaseUrl: ttsBaseUrl,
      comfyUrl: comfyUrl,
      cacheLimitGb: cacheLimitGb,
    );

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
        voiceVolume: _voiceVolume,
        ambientVolume: _ambientVolume,
        autoAdvanceChapters: _autoAdvanceChapters,
      ),
    );

    _scriptText = text;
    await _tts.prepare(
      text: text,
      startOffset: startCharOffset,
      speechRate: speechRate,
      pitch: pitch,
      voiceId: voiceId,
      preferCloud: preferCloud,
      apiKey: ttsApiKey,
      baseUrl: ttsBaseUrl,
      comfyUrl: comfyUrl,
      cacheLimitGb: cacheLimitGb,
      interChunkPauseMs: _interChunkPauseMs,
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
        scriptText: text,
        chunks: _tts.chunks,
        chunkStarts: _tts.chunkStarts,
        currentChunkIndex: _tts.currentChunkIndex,
        charOffset: _tts.charOffset,
        voiceId: voiceId,
      ),
    );
    _broadcastTtsState(playing: false);
    await booksRepository.touchOpened(bookId);
    await play();
  }

  /// Озвучка произвольного скрипта (URL / новости / выпуск).
  Future<void> playNarration({
    required String episodeId,
    required String title,
    required String subtitle,
    required String script,
    required double speechRate,
    double pitch = 1,
    String voiceId = 'calm_female_ru',
    bool preferCloud = false,
    String? ttsApiKey,
    String? ttsBaseUrl,
    String? comfyUrl,
    int cacheLimitGb = 2,
    int? startCharOffset,
  }) async {
    await _player.stop();
    _bookMode = true;
    _speechRate = speechRate;
    _fading = false;

    final mediaId = 'episode:$episodeId';
    final savedOffset = startCharOffset ??
        await progressRepository.loadCharOffset(mediaId);
    _emit(
      _session.copyWith(
        currentEpisodeId: mediaId,
        clearBookId: true,
        clearChapterId: true,
        title: title,
        subtitle: subtitle,
        isBookMode: true,
        state: PlayerState.loading,
      ),
    );

    _scriptText = script;
    await _tts.prepare(
      text: script,
      startOffset: savedOffset,
      speechRate: speechRate,
      pitch: pitch,
      voiceId: voiceId,
      preferCloud: preferCloud,
      apiKey: ttsApiKey,
      baseUrl: ttsBaseUrl,
      comfyUrl: comfyUrl,
      cacheLimitGb: cacheLimitGb,
      interChunkPauseMs: _interChunkPauseMs,
    );

    final duration = _tts.estimateDuration();
    mediaItem.add(
      MediaItem(
        id: mediaId,
        title: title,
        album: subtitle,
        artist: AppConstants.appName,
        duration: duration,
      ),
    );

    _emit(
      PlaybackSession(
        currentEpisodeId: mediaId,
        title: title,
        subtitle: subtitle,
        isBookMode: true,
        position: _tts.estimatePosition(),
        duration: duration,
        state: PlayerState.paused,
        timerEndsAt: _session.timerEndsAt,
        timerPresetMinutes: _session.timerPresetMinutes,
        playUntilEnd: _session.playUntilEnd,
        timerMode: _session.timerMode,
        scriptText: script,
        chunks: _tts.chunks,
        chunkStarts: _tts.chunkStarts,
        currentChunkIndex: _tts.currentChunkIndex,
        charOffset: _tts.charOffset,
        voiceId: voiceId,
      ),
    );
    _broadcastTtsState(playing: false);
    await play();
  }

  @override
  Future<void> play() async {
    _fading = false;
    if (_bookMode) {
      await _applyLiveVolumes(fadeFactor: 1);
      await _startAmbient();
      _emit(
        _session.copyWith(
          state: PlayerState.playing,
          voiceVolume: _voiceVolume,
          ambientVolume: _ambientVolume,
        ),
      );
      _broadcastTtsState(playing: true);
      _ensureTicker();
      unawaited(_runTtsPlayback());
      return;
    }

    await _stopAmbient();
    if (!_demoLoaded) await loadDemoTrack();
    await _player.setLoopMode(
      _session.playUntilEnd ? LoopMode.off : LoopMode.one,
    );
    await _applyLiveVolumes(fadeFactor: 1);
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
      await _stopAmbient();
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
    await _stopAmbient();
    if (_bookMode) {
      await _tts.stop();
      await _persistBookProgress();
    } else {
      await _player.stop();
      await _player.seek(Duration.zero);
    }
    await _applyLiveVolumes(fadeFactor: 1);
    _emit(
      PlaybackSession(
        currentEpisodeId: demoMediaId,
        title: 'Ночной демо-трек',
        voiceVolume: _voiceVolume,
        ambientVolume: _ambientVolume,
        autoAdvanceChapters: _autoAdvanceChapters,
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

  Future<void> setPitch(double pitch) async {
    if (_bookMode) {
      await _tts.setPitch(pitch);
    }
  }

  Future<void> setAmbient({
    required bool enabled,
    double volume = 0.12,
  }) async {
    _ambientEnabled = enabled;
    _ambientVolume = volume.clamp(0.0, 0.4);
    _emit(
      _session.copyWith(
        ambientVolume: _ambientVolume,
      ),
    );
    if (!enabled) {
      await _stopAmbient();
      return;
    }
    if (_bookMode && _isActivelyPlaying) {
      await _startAmbient();
    } else if (_bookMode) {
      await _applyLiveVolumes(fadeFactor: 1);
    }
  }

  Future<void> setVoiceVolume(double volume) async {
    _voiceVolume = volume.clamp(0.15, 1.0);
    _emit(_session.copyWith(voiceVolume: _voiceVolume));
    if (!_fading) {
      await _applyLiveVolumes(fadeFactor: 1);
    }
  }

  Future<void> setAutoAdvanceChapters(bool value) async {
    _autoAdvanceChapters = value;
    _emit(_session.copyWith(autoAdvanceChapters: value));
  }

  Future<void> _applyLiveVolumes({required double fadeFactor}) async {
    final voice = (_effectiveVoiceVolume * fadeFactor).clamp(0.0, 1.0);
    final ambient =
        (_ambientVolume * fadeFactor).clamp(0.0, 0.4);
    if (_bookMode) {
      await _tts.setVolume(voice);
      if (_ambientEnabled) {
        try {
          await _ambient.setVolume(ambient);
        } catch (_) {}
      }
    } else {
      await _player.setVolume(voice);
    }
  }

  Future<void> _ensureAmbientLoaded() async {
    if (_ambientLoaded) return;
    await _ambient.setAudioSource(AudioSource.asset(ambientAssetPath));
    await _ambient.setLoopMode(LoopMode.one);
    _ambientLoaded = true;
  }

  Future<void> _startAmbient() async {
    if (!_ambientEnabled || !_bookMode) return;
    try {
      await _ensureAmbientLoaded();
      await _ambient.setVolume(_ambientVolume.clamp(0.0, 0.4));
      await _ambient.play();
    } catch (_) {
      // Ambient — опциональный слой; голос важнее.
    }
  }

  Future<void> _stopAmbient() async {
    try {
      await _ambient.pause();
    } catch (_) {}
  }

  Future<void> setSleepTimer({
    int? minutes,
    bool playUntilEnd = false,
    SleepTimerMode? mode,
  }) async {
    _fading = false;
    _tts.clearStopAfterCurrentChunk();
    await _applyLiveVolumes(fadeFactor: 1);

    final resolvedMode = mode ??
        (playUntilEnd ? SleepTimerMode.afterChapter : SleepTimerMode.countdown);

    if (resolvedMode == SleepTimerMode.afterChapter ||
        resolvedMode == SleepTimerMode.afterSegment ||
        playUntilEnd) {
      _ticker?.cancel();
      if (!_bookMode) await _player.setLoopMode(LoopMode.off);
      if (resolvedMode == SleepTimerMode.afterSegment && _bookMode) {
        _tts.requestStopAfterCurrentChunk();
      }
      _emit(
        _session.copyWith(
          playUntilEnd: true,
          timerMode: resolvedMode == SleepTimerMode.countdown
              ? SleepTimerMode.afterChapter
              : resolvedMode,
          clearTimerEndsAt: true,
          clearTimerPreset: true,
          state: _isActivelyPlaying ? PlayerState.playing : _session.state,
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
        timerMode: SleepTimerMode.countdown,
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
    await _applyLiveVolumes(fadeFactor: 1);
    final endsAt = base.add(Duration(minutes: minutes));
    final remainingMinutes = endsAt.difference(now).inMinutes.clamp(1, 24 * 60);
    _emit(
      _session.copyWith(
        timerEndsAt: endsAt,
        timerPresetMinutes: remainingMinutes,
        playUntilEnd: false,
        timerMode: SleepTimerMode.countdown,
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
          mode: _modeFromName(extras?['mode'] as String?),
        );
        return null;
      case 'toggle_play':
        if (_isActivelyPlaying) {
          await pause();
        } else {
          await play();
        }
        return null;
      case 'widget_snapshot':
        return {
          'title': _session.title,
          'playing': _isActivelyPlaying,
          'timerLabel': _widgetTimerLabel(),
        };
      default:
        return super.customAction(name, extras);
    }
  }

  SleepTimerMode? _modeFromName(String? name) {
    if (name == null) return null;
    return SleepTimerMode.values.firstWhere(
      (e) => e.name == name,
      orElse: () => SleepTimerMode.countdown,
    );
  }

  String _widgetTimerLabel() {
    if (_session.timerMode == SleepTimerMode.afterChapter) {
      return _session.isBookMode && _session.bookId != null
          ? 'До конца главы'
          : 'До конца';
    }
    if (_session.timerMode == SleepTimerMode.afterSegment) {
      return 'До конца фразы';
    }
    final left = _session.timerRemaining;
    if (left == null) return 'Таймер выкл.';
    final m = left.inMinutes;
    final s = left.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
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
      final fadeFactor = computeFadeVolume(
        remaining: remaining,
        fadeFor: fadeFor,
        baseVolume: 1,
      );
      // Голос и ambient затухают вместе.
      await _applyLiveVolumes(fadeFactor: fadeFactor);
    }

    _emit(_session.copyWith());
    _refreshControls();
  }

  Future<void> _finishByTimer() async {
    _ticker?.cancel();
    _fading = false;
    // Умный стоп: дослушать текущую фразу (сегмент), затем пауза.
    if (_bookMode && (_tts.isPlaying || _ttsLoop)) {
      _tts.requestStopAfterCurrentChunk();
      _emit(
        _session.copyWith(
          clearTimerEndsAt: true,
          clearTimerPreset: true,
          playUntilEnd: false,
          timerMode: SleepTimerMode.afterSegment,
          state: PlayerState.fadingOut,
        ),
      );
      _refreshControls();
      return;
    }
    await _stopAmbient();
    if (_bookMode) {
      await _tts.pause();
      await _persistBookProgress();
    } else {
      await _player.pause();
      await _persistDemoPosition();
    }
    await _applyLiveVolumes(fadeFactor: 1);
    _emit(
      _session.copyWith(
        state: PlayerState.paused,
        clearTimerEndsAt: true,
        clearTimerPreset: true,
        playUntilEnd: false,
        timerMode: SleepTimerMode.countdown,
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
    final stopAtBoundary = completed &&
        (_session.timerMode == SleepTimerMode.afterChapter ||
            _session.timerMode == SleepTimerMode.afterSegment) &&
        _session.playUntilEnd;
    final nextState = completed
        ? PlayerState.completed
        : (_tts.isPlaying || _ttsLoop
            ? (_fading || _session.timerMode == SleepTimerMode.afterSegment
                ? PlayerState.fadingOut
                : PlayerState.playing)
            : PlayerState.paused);
    _emit(
      _session.copyWith(
        position: _tts.estimatePosition(),
        duration: _tts.estimateDuration(),
        state: nextState,
        scriptText: _scriptText,
        chunks: _tts.chunks,
        chunkStarts: _tts.chunkStarts,
        currentChunkIndex: _tts.currentChunkIndex,
        charOffset: offset,
        playUntilEnd: completed ? false : _session.playUntilEnd,
        timerMode: completed ? SleepTimerMode.countdown : _session.timerMode,
        voiceVolume: _voiceVolume,
        ambientVolume: _ambientVolume,
        autoAdvanceChapters: _autoAdvanceChapters,
      ),
    );
    await _persistBookProgress();
    _broadcastTtsState(playing: !completed && (_tts.isPlaying || _ttsLoop));
    if (completed) {
      await _applyLiveVolumes(fadeFactor: 1);
      if (stopAtBoundary) {
        await _stopAmbient();
        return;
      }
      final canAdvance = _autoAdvanceChapters &&
          _session.bookId != null &&
          _session.chapterId != null;
      if (canAdvance) {
        // После выхода текущего TTS-цикла — следующая глава.
        unawaited(Future<void>(() async {
          await Future<void>.delayed(const Duration(milliseconds: 80));
          final advanced = await _tryPlayNextChapter();
          if (!advanced) await _stopAmbient();
        }));
        return;
      }
      await _stopAmbient();
    }
  }

  Future<bool> _tryPlayNextChapter() async {
    final bookId = _session.bookId;
    final chapterId = _session.chapterId;
    final params = _lastBookParams;
    if (bookId == null || chapterId == null || params == null) return false;

    final book = await booksRepository.getBook(bookId);
    if (book == null || book.chapters.isEmpty) return false;
    final index = book.chapters.indexWhere((c) => c.id == chapterId);
    if (index < 0 || index + 1 >= book.chapters.length) return false;

    final next = book.chapters[index + 1];
    if (next.content.trim().isEmpty) return false;

    await playBookChapter(
      bookId: bookId,
      chapterId: next.id,
      bookTitle: book.title,
      chapterTitle: next.title,
      text: next.content,
      startCharOffset: 0,
      speechRate: params.speechRate,
      pitch: params.pitch,
      voiceId: params.voiceId,
      preferCloud: params.preferCloud,
      ttsApiKey: params.ttsApiKey,
      ttsBaseUrl: params.ttsBaseUrl,
      comfyUrl: params.comfyUrl,
      cacheLimitGb: params.cacheLimitGb,
    );
    return true;
  }

  Future<void> _clearTimer() async {
    _ticker?.cancel();
    _fading = false;
    await _applyLiveVolumes(fadeFactor: 1);
    _tts.clearStopAfterCurrentChunk();
    _emit(
      _session.copyWith(
        clearTimerEndsAt: true,
        clearTimerPreset: true,
        playUntilEnd: false,
        timerMode: SleepTimerMode.countdown,
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
    final mediaId = _session.currentEpisodeId;
    if (mediaId != null && mediaId.startsWith('episode:')) {
      await progressRepository.saveCharOffset(
        mediaId: mediaId,
        charOffset: _tts.charOffset,
      );
    }

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
    await _stopAmbient();
    await _tts.dispose();
    await _sessionController.close();
    await _ambient.dispose();
    await _player.dispose();
  }
}

class _BookTtsParams {
  const _BookTtsParams({
    required this.speechRate,
    required this.pitch,
    required this.voiceId,
    required this.preferCloud,
    this.ttsApiKey,
    this.ttsBaseUrl,
    this.comfyUrl,
    required this.cacheLimitGb,
  });

  final double speechRate;
  final double pitch;
  final String voiceId;
  final bool preferCloud;
  final String? ttsApiKey;
  final String? ttsBaseUrl;
  final String? comfyUrl;
  final int cacheLimitGb;

  _BookTtsParams copyWith({String? voiceId}) {
    return _BookTtsParams(
      speechRate: speechRate,
      pitch: pitch,
      voiceId: voiceId ?? this.voiceId,
      preferCloud: preferCloud,
      ttsApiKey: ttsApiKey,
      ttsBaseUrl: ttsBaseUrl,
      comfyUrl: comfyUrl,
      cacheLimitGb: cacheLimitGb,
    );
  }
}
