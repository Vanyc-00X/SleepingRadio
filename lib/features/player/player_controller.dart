import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/di/providers.dart';
import '../../domain/models/playback_session.dart';
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

    // Подтянуть скорость из настроек.
    ref.listen(settingsProvider, (prev, next) {
      next.whenData((settings) {
        unawaited(handler.setSpeed(settings.speechRate));
      });
    });

    return handler.session;
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
}
