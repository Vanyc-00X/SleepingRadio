import 'package:audio_service/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/local/app_database.dart';
import '../../../data/repositories/books_repository.dart';
import '../../../data/repositories/playback_progress_repository.dart';
import 'sleeping_audio_handler.dart';

Future<({SleepingAudioHandler handler, AppDatabase db})>
initSleepingAudioService() async {
  final prefs = await SharedPreferences.getInstance();
  final progress = PlaybackProgressRepository(prefs);
  final db = AppDatabase();
  final books = BooksRepository(db);

  final handler = await AudioService.init(
    builder: () => SleepingAudioHandler(
      progressRepository: progress,
      booksRepository: books,
    ),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'sleeping_radio_playback',
      androidNotificationChannelName: AppConstants.appNameShort,
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
      fastForwardInterval: Duration(seconds: AppConstants.seekStepSeconds),
      rewindInterval: Duration(seconds: AppConstants.seekStepSeconds),
    ),
  );

  await handler.ready();
  return (handler: handler, db: db);
}
