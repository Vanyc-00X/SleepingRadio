import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../player/player_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final session = ref.watch(playerSessionProvider);
    final historyAsync = ref.watch(recentHistoryProvider);
    final recent = historyAsync.asData?.value.take(3).toList() ?? const [];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF12182C),
              AppColors.night,
              Color(0xFF080C18),
            ],
            stops: [0, 0.45, 1],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            children: [
              Text(
                AppConstants.appName,
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.moon,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Лёг вечером → выбрал источник → спокойный голос → сон',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              Text('Продолжить', style: textTheme.titleMedium),
              const SizedBox(height: 12),
              _ContinueCard(
                title: session.title.isEmpty
                    ? 'Ночной демо-трек'
                    : session.title,
                subtitle: session.isBookMode
                    ? (session.subtitle.isEmpty
                          ? 'Книга · системный TTS'
                          : session.subtitle)
                    : session.isPlaying
                    ? 'Играет · откройте плеер'
                    : 'Демо · таймер сна и фон',
                playing: session.isPlaying,
                onTap: () => context.go('/player'),
                onPlay: () =>
                    ref.read(playerSessionProvider.notifier).toggle(),
              ),
              const SizedBox(height: 28),
              Text('Быстрый старт', style: textTheme.titleMedium),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _ModeTile(
                    icon: Icons.menu_book_outlined,
                    label: 'Книга',
                    hint: 'fb2 · epub · txt',
                    onTap: () => context.go('/library'),
                  ),
                  _ModeTile(
                    icon: Icons.newspaper_outlined,
                    label: 'Новости',
                    hint: 'Сводка + комментарий',
                    onTap: () => context.push('/news'),
                  ),
                  _ModeTile(
                    icon: Icons.link_outlined,
                    label: 'Ссылка',
                    hint: 'URL → голос',
                    onTap: () => context.push('/link'),
                  ),
                  _ModeTile(
                    icon: Icons.podcasts_outlined,
                    label: 'Подкаст',
                    hint: 'Собрать выпуск',
                    onTap: () => context.push('/podcast'),
                  ),
                ],
              ),
              Builder(
                builder: (context) {
                  final recommendations = ref.watch(
                    topicRecommendationsProvider,
                  );
                  if (recommendations.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 28),
                      Text('Вам может подойти', style: textTheme.titleMedium),
                      const SizedBox(height: 12),
                      ...recommendations.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: AppColors.nightElevated,
                            borderRadius: BorderRadius.circular(14),
                            child: ListTile(
                              leading: const Icon(
                                Icons.auto_awesome,
                                color: AppColors.amber,
                              ),
                              title: Text(item.topic.labelRu),
                              subtitle: Text(item.reason),
                              onTap: () async {
                                final current =
                                    ref.read(settingsProvider).asData?.value;
                                if (current == null) return;
                                final topics = {
                                  ...current.newsTopics,
                                  item.topic,
                                }.toList();
                                await ref
                                    .read(settingsProvider.notifier)
                                    .updateSettings(
                                      (s) => s.copyWith(newsTopics: topics),
                                    );
                                if (context.mounted) {
                                  context.push('/news');
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              if (recent.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text('Недавнее', style: textTheme.titleMedium),
                const SizedBox(height: 12),
                ...recent.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: AppColors.nightElevated,
                      borderRadius: BorderRadius.circular(14),
                      child: ListTile(
                        leading: const Icon(
                          Icons.history,
                          color: AppColors.amber,
                        ),
                        title: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(item.subtitle),
                        onTap: () => context.go('/library'),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.title,
    required this.subtitle,
    required this.playing,
    required this.onTap,
    required this.onPlay,
  });

  final String title;
  final String subtitle;
  final bool playing;
  final VoidCallback onTap;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.nightElevated,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.headphones, color: AppColors.amber),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mist,
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                button: true,
                label: playing ? 'Пауза' : 'Играть',
                child: IconButton.filled(
                  onPressed: onPlay,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.amber,
                    foregroundColor: AppColors.night,
                    minimumSize: const Size(52, 52),
                  ),
                  icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.icon,
    required this.label,
    required this.hint,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.nightElevated,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label — в разработке ($hint)')),
              );
            },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppColors.amber, size: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.titleSmall),
                  Text(
                    hint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mist,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
