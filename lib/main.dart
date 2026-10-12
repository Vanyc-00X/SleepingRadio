import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/di/providers.dart';
import 'features/player/audio/audio_service_init.dart';
import 'features/player/player_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF141A2E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final boot = await initSleepingAudioService();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(boot.db),
        audioHandlerProvider.overrideWithValue(boot.handler),
      ],
      child: const SleepingRadioApp(),
    ),
  );
}
