import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

class SleepingRadioApp extends StatefulWidget {
  const SleepingRadioApp({super.key});

  @override
  State<SleepingRadioApp> createState() => _SleepingRadioAppState();
}

class _SleepingRadioAppState extends State<SleepingRadioApp> {
  late final GoRouter _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: _router,
    );
  }
}

/// Kept for Riverpod scope at the root without forcing ConsumerWidget here.
class SleepingRadioRoot extends StatelessWidget {
  const SleepingRadioRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: SleepingRadioApp());
  }
}
