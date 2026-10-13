import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_constants.dart';
import 'core/di/providers.dart';
import 'core/routing/app_router.dart';
import 'core/share/share_intent_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_screen.dart';

class SleepingRadioApp extends ConsumerStatefulWidget {
  const SleepingRadioApp({super.key});

  @override
  ConsumerState<SleepingRadioApp> createState() => _SleepingRadioAppState();
}

class _SleepingRadioAppState extends ConsumerState<SleepingRadioApp> {
  GoRouter? _router;
  StreamSubscription<SharedPayload>? _shareSub;
  SharedPayload? _pendingShare;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initShare());
  }

  Future<void> _initShare() async {
    final initial = await shareIntentService.getInitial();
    if (initial != null) {
      _openShared(initial);
    }
    await _shareSub?.cancel();
    _shareSub = shareIntentService.stream.listen(_openShared);
  }

  void _openShared(SharedPayload payload) {
    final router = _router;
    if (router == null) {
      _pendingShare = payload;
      return;
    }
    final uri = Uri(
      path: '/link',
      queryParameters: {
        if (payload.url != null && payload.url!.isNotEmpty) 'url': payload.url!,
        if (payload.text != null && payload.text!.isNotEmpty)
          'text': payload.text!,
      },
    );
    router.go(uri.toString());
  }

  void _flushPendingShare() {
    final pending = _pendingShare;
    if (pending == null) return;
    _pendingShare = null;
    WidgetsBinding.instance.addPostFrameCallback((_) => _openShared(pending));
  }

  @override
  void dispose() {
    _shareSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const Scaffold(
          backgroundColor: AppColors.night,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.amber),
          ),
        ),
      ),
      error: (error, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Не удалось загрузить настройки.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
      data: (settings) {
        if (!settings.onboardingCompleted) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            themeMode: ThemeMode.dark,
            home: const OnboardingScreen(),
          );
        }

        _router ??= createAppRouter();
        _flushPendingShare();
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          routerConfig: _router!,
        );
      },
    );
  }
}
