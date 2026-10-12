import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';

class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).asData?.value;
    final timer = settings?.defaultTimerMinutes ?? 30;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.35),
            radius: 1.1,
            colors: [
              Color(0xFF1A2238),
              AppColors.night,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Сейчас играет', style: textTheme.titleMedium),
                ),
                const Spacer(),
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.nightSoft,
                    border: Border.all(
                      color: AppColors.amber.withValues(alpha: 0.25),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.nightlight_round,
                    size: 72,
                    color: AppColors.amber,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Тишина перед стартом',
                  style: textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Плеер и таймер сна — этап 1',
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Text(
                  'Таймер по умолчанию: $timer мин',
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.amber),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      iconSize: 36,
                      icon: const Icon(Icons.replay),
                      color: AppColors.mist,
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Воспроизведение подключится на этапе 1',
                            ),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(22),
                      ),
                      child: const Icon(Icons.play_arrow, size: 40),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {},
                      iconSize: 36,
                      icon: const Icon(Icons.forward),
                      color: AppColors.mist,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Пресеты: ${AppConstants.timerPresetsMinutes.join(" / ")} мин',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.mist),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
