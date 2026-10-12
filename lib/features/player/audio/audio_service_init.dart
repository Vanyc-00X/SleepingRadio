import 'package:audio_service/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/playback_progress_repository.dart';
import 'sleeping_audio_handler.dart';

Future<SleepingAudioHandler> initSleepingAudioService() async {
  final prefs = await SharedPreferences.getInstance();
  final progress = PlaybackProgressRepository(prefs);

  final handler = await AudioService.init(
    builder: () => SleepingAudioHandler(progress),
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
  return handler;
}
