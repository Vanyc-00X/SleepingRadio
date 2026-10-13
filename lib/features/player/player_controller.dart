import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/di/providers.dart';
import '../../data/tts/tts_api_key_store.dart';
import '../../domain/models/playback_session.dart';
import '../settings/stage8_controller.dart';
import 'audio/sleeping_audio_handler.dart';

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
    });
    ref.onDispose(() => _sub?.cancel());

    // Подтянуть скорость/высоту/ambient из настроек.
    ref.listen(settingsProvider, (prev, next) {
      next.whenData((settings) {
        unawaited(handler.setSpeed(settings.speechRate));
        unawaited(handler.setPitch(settings.pitch));
      });
    });
    ref.listen(stage8StateProvider, (prev, next) {
      unawaited(
        handler.setAmbient(
          enabled: next.ambientEnabled,
          volume: next.ambientVolume,
        ),
      );
    });
    final stage8 = ref.read(stage8StateProvider);
    unawaited(
      handler.setAmbient(
        enabled: stage8.ambientEnabled,
        volume: stage8.ambientVolume,
      ),
    );

    return handler.session;
  }

  Future<void> _syncAmbient() async {
    final stage8 = ref.read(stage8StateProvider);
    await _handler.setAmbient(
      enabled: stage8.ambientEnabled,
      volume: stage8.ambientVolume,
    );
  }

  SleepingAudioHandler get _handler => ref.read(audioHandlerProvider);

  Future<void> play() => _handler.play();
  Future<void> pause() => _handler.pause();
  Future<void> toggle() => state.isPlaying ? pause() : play();
  Future<void> seekBy(Duration offset) => _handler.seekBy(offset);
  Future<void> seek(Duration position) => _handler.seek(position);

  Future<void> setTimerMinutes(int minutes) =>
      _handler.setSleepTimer(minutes: minutes);

  Future<void> setPlayUntilEnd() =>
      _handler.setSleepTimer(playUntilEnd: true);

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
    final apiKey = keyStore.loadKey() ?? CloudTtsDefaults.envApiKey;
    final baseUrl = keyStore.loadBaseUrl().isEmpty
        ? CloudTtsDefaults.envBaseUrl
        : keyStore.loadBaseUrl();

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
      voiceId: settings?.voiceId ?? 'calm_female_ru',
      preferCloud: settings?.useCloudAi ?? true,
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
  }) async {
    final settings = ref.read(settingsProvider).asData?.value;
    final keyStore = ref.read(ttsApiKeyStoreProvider);
    final apiKey = keyStore.loadKey() ?? CloudTtsDefaults.envApiKey;
    final baseUrl = keyStore.loadBaseUrl().isEmpty
        ? CloudTtsDefaults.envBaseUrl
        : keyStore.loadBaseUrl();

    await _syncAmbient();
    await _handler.playNarration(
      episodeId: episodeId,
      title: title,
      subtitle: subtitle,
      script: script,
      speechRate: settings?.speechRate ?? 1,
      pitch: settings?.pitch ?? 1,
      voiceId: settings?.voiceId ?? 'calm_female_ru',
      preferCloud: settings?.useCloudAi ?? true,
      ttsApiKey: apiKey.isEmpty ? null : apiKey,
      ttsBaseUrl: baseUrl,
      comfyUrl: keyStore.loadComfyUrl(),
      cacheLimitGb: settings?.cacheLimitGb ?? 2,
    );

    unawaited(
      ref.read(listenHistoryRepositoryProvider).recordStart(
        episodeId: episodeId,
      ),
    );
  }
}
