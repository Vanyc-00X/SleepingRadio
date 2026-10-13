import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Не блокируем UI, если шрифты не скачались.
  GoogleFonts.config.allowRuntimeFetching = true;

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

  // Важно: runApp сразу — иначе при ошибке/зависании init будет белый экран.
  runZonedGuarded(
    () => runApp(const SleepingRadioBootstrap()),
    (error, stack) => debugPrint('Uncaught: $error\n$stack'),
  );
}
