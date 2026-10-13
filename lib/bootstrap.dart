import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/di/providers.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/local/app_database.dart' hide Book;
import 'features/player/audio/audio_service_init.dart';
import 'features/player/audio/sleeping_audio_handler.dart';
import 'features/player/player_controller.dart';

/// Показывает тёмный splash сразу, затем поднимает приложение после init.
class SleepingRadioBootstrap extends StatefulWidget {
  const SleepingRadioBootstrap({super.key});

  @override
  State<SleepingRadioBootstrap> createState() => _SleepingRadioBootstrapState();
}

class _SleepingRadioBootstrapState extends State<SleepingRadioBootstrap> {
  Object? _error;
  SleepingAudioHandler? _handler;
  AppDatabase? _db;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final boot = await initSleepingAudioService().timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException(
          'Инициализация аудио заняла слишком много времени',
        ),
      );
      if (!mounted) return;
      setState(() {
        _handler = boot.handler;
        _db = boot.db;
        _prefs = boot.prefs;
        _error = null;
      });
    } catch (error, stack) {
      debugPrint('Boot failed: $error\n$stack');
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: _BootError(error: _error!, onRetry: () {
          setState(() {
            _error = null;
            _handler = null;
            _db = null;
            _prefs = null;
          });
          _start();
        }),
      );
    }

    final handler = _handler;
    final db = _db;
    final prefs = _prefs;
    if (handler == null || db == null || prefs == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const _BootLoading(),
      );
    }

    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        audioHandlerProvider.overrideWithValue(handler),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const SleepingRadioApp(),
    );
  }
}

class _BootLoading extends StatelessWidget {
  const _BootLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.night,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.amber),
            SizedBox(height: 20),
            Text(
              'Сонный радиоприёмник',
              style: TextStyle(color: AppColors.moon, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _BootError extends StatelessWidget {
  const _BootError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.night,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Не удалось запустить приложение',
                style: TextStyle(
                  color: AppColors.moon,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '$error',
                style: const TextStyle(color: AppColors.mist),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
