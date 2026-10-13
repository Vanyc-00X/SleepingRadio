import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/di/providers.dart';
import '../../data/tts/on_device_tts_models.dart';
import '../../data/tts/tts_api_key_store.dart';
import '../../domain/models/playback_session.dart';
import '../settings/stage8_controller.dart';
import 'audio/sleeping_audio_handler.dart';
import 'home_widget_sync.dart';

final audioHandlerProvider = Provider<SleepingAudioHandler>((ref) {
  throw UnimplementedError('audioHandlerProvider must be overridden in main');
});

final playerSessionProvider =
    NotifierProvider<PlayerSessionNotifier, PlaybackSession>(
      PlayerSessionNotifier.new,
    );

class PlayerSessionNotifier extends Notifier<PlaybackSession> {
  StreamSubscription<PlaybackSession>? _sub;

  @override
  PlaybackSession build() {
    final handler = ref.watch(audioHandlerProvider);
    _sub?.cancel();
    _sub = handler.sessionStream.listen((session) {
      state = session;
      unawaited(HomeWidgetSync.push(session));
    });
    ref.onDispose(() => _sub?.cancel());
    unawaited(HomeWidgetSync.ensureConfigured());
    unawaited(HomeWidgetSync.push(handler.session));

    // Подтянуть скорость/высоту/ambient/паузы из настроек.
    ref.listen(settingsProvider, (prev, next) {
      next.whenData((settings) {
        unawaited(handler.setSpeed(settings.speechRate));
        unawaited(handler.setPitch(settings.pitch));
      });
    });
    final presets = ref.read(voicePresetsStoreProvider);
    handler.setInterChunkPauseMs(presets.interChunkPauseMs);
    ref.listen(stage8StateProvider, (prev, next) {
      unawaited(
        handler.setAmbient(
          enabled: next.ambientEnabled,
          volume: next.ambientVolume,
        ),
      );
      unawaited(handler.setVoiceVolume(next.voiceVolume));
      unawaited(handler.setAutoAdvanceChapters(next.autoAdvanceChapters));
    });
    final stage8 = ref.read(stage8StateProvider);
    unawaited(
      handler.setAmbient(
        enabled: stage8.ambientEnabled,
        volume: stage8.ambientVolume,
      ),
    );
    unawaited(handler.setVoiceVolume(stage8.voiceVolume));
    unawaited(handler.setAutoAdvanceChapters(stage8.autoAdvanceChapters));

    return handler.session;
  }

  Future<void> _syncAmbient() async {
    final stage8 = ref.read(stage8StateProvider);
    await _handler.setAmbient(
      enabled: stage8.ambientEnabled,
      volume: stage8.ambientVolume,
    );
  }

  Future<void> setVoiceVolume(double volume) async {
    await ref.read(stage8StateProvider.notifier).setVoiceVolume(volume);
    await _handler.setVoiceVolume(volume);
  }

  Future<void> setAmbientVolume(double volume) async {
    await ref.read(stage8StateProvider.notifier).setAmbientVolume(volume);
    await _syncAmbient();
  }

  Future<void> setAmbientEnabled(bool enabled) async {
    await ref.read(stage8StateProvider.notifier).setAmbientEnabled(enabled);
    await _syncAmbient();
  }

  Future<void> setAutoAdvanceChapters(bool value) async {
    await ref.read(stage8StateProvider.notifier).setAutoAdvanceChapters(value);
    await _handler.setAutoAdvanceChapters(value);
  }

  SleepingAudioHandler get _handler => ref.read(audioHandlerProvider);

  Future<void> _ensureOnDeviceVoice(String voiceId) async {
    final model = OnDeviceTtsModels.byId(voiceId);
    if (model == null) return;
    final engine = ref.read(onDeviceTtsEngineProvider);
    if (await engine.isReady(model)) return;
    await engine.ensureModel(model);
  }

  Future<void> play() => _handler.play();
  Future<void> pause() => _handler.pause();
  Future<void> toggle() => state.isPlaying ? pause() : play();
  Future<void> seekBy(Duration offset) => _handler.seekBy(offset);
  Future<void> seek(Duration position) => _handler.seek(position);

  Future<void> setTimerMinutes(int minutes) =>
      _handler.setSleepTimer(minutes: minutes);

  Future<void> setPlayUntilEnd() =>
      _handler.setSleepTimer(playUntilEnd: true);

  Future<void> setSmartTimer(SleepTimerMode mode) =>
      _handler.setSleepTimer(mode: mode);

  Future<void> switchVoice(String voiceId) async {
    await _handler.switchVoice(voiceId);
    unawaited(
      ref.read(settingsProvider.notifier).updateSettings(
            (s) => s.copyWith(voiceId: voiceId),
          ),
    );
  }

  Future<void> clearTimer() => _handler.setSleepTimer();

  Future<void> extendTimer([
    int minutes = AppConstants.timerExtendMinutes,
  ]) =>
      _handler.extendSleepTimer(minutes);

  Future<void> playBookChapter({
    required String bookId,
    required String chapterId,
    required String bookTitle,
    required String chapterTitle,
    required String text,
    required int startCharOffset,
  }) async {
    final settings = ref.read(settingsProvider).asData?.value;
    final keyStore = ref.read(ttsApiKeyStoreProvider);
    final presets = ref.read(voicePresetsStoreProvider);
    final apiKey = keyStore.loadKey() ?? CloudTtsDefaults.envApiKey;
    final baseUrl = keyStore.loadBaseUrl().isEmpty
        ? CloudTtsDefaults.envBaseUrl
        : keyStore.loadBaseUrl();

    final voiceId = settings?.voiceId ?? 'piper_denis';
    _handler.setInterChunkPauseMs(presets.interChunkPauseMs);
    await _ensureOnDeviceVoice(voiceId);
    await _syncAmbient();
    await _handler.playBookChapter(
      bookId: bookId,
      chapterId: chapterId,
      bookTitle: bookTitle,
      chapterTitle: chapterTitle,
      text: text,
      startCharOffset: startCharOffset,
      speechRate: settings?.speechRate ?? 1,
      pitch: settings?.pitch ?? 1,
      voiceId: voiceId,
      preferCloud: settings?.useCloudAi ?? false,
      ttsApiKey: apiKey.isEmpty ? null : apiKey,
      ttsBaseUrl: baseUrl,
      comfyUrl: keyStore.loadComfyUrl(),
      cacheLimitGb: settings?.cacheLimitGb ?? 2,
    );
  }

  Future<void> loadDemo() => _handler.loadDemoTrack();

  Future<void> playNarration({
    required String episodeId,
    required String title,
    required String subtitle,
    required String script,
    int? startCharOffset,
    bool resumeSaved = true,
  }) async {
    final settings = ref.read(settingsProvider).asData?.value;
    final keyStore = ref.read(ttsApiKeyStoreProvider);
    final presets = ref.read(voicePresetsStoreProvider);
    final apiKey = keyStore.loadKey() ?? CloudTtsDefaults.envApiKey;
    final baseUrl = keyStore.loadBaseUrl().isEmpty
        ? CloudTtsDefaults.envBaseUrl
        : keyStore.loadBaseUrl();

    final voiceId = settings?.voiceId ?? 'piper_denis';
    _handler.setInterChunkPauseMs(presets.interChunkPauseMs);
    await _ensureOnDeviceVoice(voiceId);
    await _syncAmbient();
    await _handler.playNarration(
      episodeId: episodeId,
      title: title,
      subtitle: subtitle,
      script: script,
      speechRate: settings?.speechRate ?? 1,
      pitch: settings?.pitch ?? 1,
      voiceId: voiceId,
      preferCloud: settings?.useCloudAi ?? false,
      ttsApiKey: apiKey.isEmpty ? null : apiKey,
      ttsBaseUrl: baseUrl,
      comfyUrl: keyStore.loadComfyUrl(),
      cacheLimitGb: settings?.cacheLimitGb ?? 2,
      startCharOffset: resumeSaved ? startCharOffset : (startCharOffset ?? 0),
    );

    unawaited(
      ref.read(listenHistoryRepositoryProvider).recordStart(
        episodeId: episodeId,
      ),
    );
  }
}
