import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/local/app_database.dart';
import '../../../data/repositories/books_repository.dart';
import '../../../data/repositories/playback_progress_repository.dart';
import 'sleeping_audio_handler.dart';

Future<
  ({
    SleepingAudioHandler handler,
    AppDatabase db,
    SharedPreferences prefs,
  })
>
initSleepingAudioService() async {
  final prefs = await SharedPreferences.getInstance();
  final progress = PlaybackProgressRepository(prefs);
  final db = AppDatabase();
  final books = BooksRepository(db);

  late final SleepingAudioHandler handler;
  try {
    handler = await AudioService.init(
      builder: () => SleepingAudioHandler(
        progressRepository: progress,
        booksRepository: books,
      ),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'sleeping_radio_playback',
        androidNotificationChannelName: AppConstants.appNameShort,
        androidNotificationOngoing: !kIsWeb,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
        fastForwardInterval: const Duration(
          seconds: AppConstants.seekStepSeconds,
        ),
        rewindInterval: const Duration(seconds: AppConstants.seekStepSeconds),
      ),
    );
  } catch (error, stack) {
    debugPrint('AudioService.init failed, using local handler: $error\n$stack');
    handler = SleepingAudioHandler(
      progressRepository: progress,
      booksRepository: books,
    );
  }

  try {
    await handler.ready();
  } catch (error, stack) {
    debugPrint('Audio handler ready failed: $error\n$stack');
  }

  return (handler: handler, db: db, prefs: prefs);
}
