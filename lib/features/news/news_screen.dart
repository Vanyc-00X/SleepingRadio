import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/news/news_episode_composer.dart';
import '../../data/news/rss_client.dart';
import '../../data/news/rss_models.dart';
import '../../domain/enums/news_language.dart';
import '../../domain/enums/news_topic.dart';
import '../player/player_controller.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  var _factsOnly = false;
  var _loadingFeed = false;
  var _building = false;
  String? _error;
  List<RssItem> _headlines = const [];
  NewsLanguage _language = NewsLanguage.ru;
  Set<NewsTopic> _topics = {
    NewsTopic.technology,
    NewsTopic.science,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapTopics());
  }

  Future<void> _bootstrapTopics() async {
    final settings = await ref.read(settingsProvider.future);
    final language = ref.read(newsFeedStoreProvider).language;
    if (!mounted) return;
    setState(() {
      _topics = settings.newsTopics.toSet();
      _language = language;
    });
    await _refreshFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новости')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            NewsEpisodeComposer.disclaimer,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.mist,
            ),
          ),
          const SizedBox(height: 16),
          Text('Язык новостей', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: NewsLanguage.values.map((lang) {
              final selected = _language == lang;
              return ChoiceChip(
                label: Text('${lang.shortLabel} · ${lang.labelRu}'),
                selected: selected,
                selectedColor: AppColors.amber.withValues(alpha: 0.25),
                labelStyle: TextStyle(
                  color: selected ? AppColors.amber : AppColors.moon,
                ),
                onSelected: (_) async {
                  setState(() {
                    _language = lang;
                    _headlines = const [];
                  });
                  await ref.read(newsFeedStoreProvider).setLanguage(lang);
                  await _refreshFeed();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('Темы', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: NewsTopic.values.map((topic) {
              final selected = _topics.contains(topic);
              return FilterChip(
                label: Text(topic.labelRu),
                selected: selected,
                selectedColor: AppColors.amber.withValues(alpha: 0.25),
                checkmarkColor: AppColors.amber,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _topics.add(topic);
                    } else if (_topics.length > 1) {
                      _topics.remove(topic);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Только факты'),
            subtitle: const Text('Без комментария'),
            value: _factsOnly,
            activeThumbColor: AppColors.amber,
            onChanged: (value) => setState(() => _factsOnly = value),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loadingFeed ? null : _refreshFeed,
                  icon: _loadingFeed
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: const Text('Обновить ленту'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _building || _headlines.isEmpty
                      ? null
                      : _buildAndPlay,
                  icon: _building
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_building ? 'Собираем…' : 'Сформировать'),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          ],
          const SizedBox(height: 20),
          Text('Лента', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          if (_headlines.isEmpty && !_loadingFeed)
            const Text(
              'Нажмите «Обновить ленту», чтобы подтянуть заголовки.',
              style: TextStyle(color: AppColors.mist),
            )
          else
            ..._headlines.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: AppColors.nightElevated,
                  borderRadius: BorderRadius.circular(14),
                  child: ListTile(
                    title: Text(item.title, maxLines: 2),
                    subtitle: item.summary.isEmpty
                        ? null
                        : Text(
                            item.summary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _refreshFeed() async {
    setState(() {
      _loadingFeed = true;
      _error = null;
    });
    try {
      await ref.read(settingsProvider.notifier).updateSettings(
        (s) => s.copyWith(newsTopics: _topics.toList()),
      );
      final items = await ref.read(newsRepositoryProvider).fetchHeadlines(
            _topics.toList(),
            language: _language,
          );
      if (!mounted) return;
      setState(() => _headlines = items);
    } on RssFetchException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Не удалось обновить ленту.');
    } finally {
      if (mounted) setState(() => _loadingFeed = false);
    }
  }

  Future<void> _buildAndPlay() async {
    setState(() {
      _building = true;
      _error = null;
    });
    try {
      final settings = await ref.read(settingsProvider.future);
      await ref.read(settingsProvider.notifier).updateSettings(
        (s) => s.copyWith(newsTopics: _topics.toList()),
      );
      final episode = await ref.read(newsRepositoryProvider).buildEpisode(
            topics: _topics.toList(),
            commentLength: settings.commentLength,
            factsOnly: _factsOnly,
            prefetched: _headlines,
            language: _language,
          );

      final script = episode.script?.trim() ?? '';
      if (script.isEmpty) {
        throw RssFetchException('Пустой скрипт выпуска.');
      }

      await ref.read(playerSessionProvider.notifier).playNarration(
        episodeId: episode.id,
        title: episode.title,
        subtitle: 'Новости',
        script: script,
      );

      if (!mounted) return;
      context.go('/player');
    } on RssFetchException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Не удалось собрать выпуск.');
    } finally {
      if (mounted) setState(() => _building = false);
    }
  }
}
