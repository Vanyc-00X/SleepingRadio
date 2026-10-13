import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/news/news_feed_store.dart';
import '../../domain/enums/news_language.dart';
import '../../domain/enums/news_topic.dart';

class NewsFeedsScreen extends ConsumerStatefulWidget {
  const NewsFeedsScreen({super.key});

  @override
  ConsumerState<NewsFeedsScreen> createState() => _NewsFeedsScreenState();
}

class _NewsFeedsScreenState extends ConsumerState<NewsFeedsScreen> {
  late List<NewsFeedEntry> _feeds;

  @override
  void initState() {
    super.initState();
    _feeds = ref.read(newsFeedStoreProvider).loadAll()
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  Future<void> _persist() async {
    await ref.read(newsFeedStoreProvider).saveAll(_feeds);
    setState(() {
      _feeds = [..._feeds]..sort((a, b) => b.priority.compareTo(a.priority));
    });
  }

  Future<void> _addCustom() async {
    final labelCtrl = TextEditingController();
    final urlCtrl = TextEditingController(text: 'https://');
    var topic = NewsTopic.technology;
    var language = ref.read(newsFeedStoreProvider).language;
    var priority = 90;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              backgroundColor: AppColors.nightElevated,
              title: const Text('Своя RSS-лента'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: labelCtrl,
                      decoration: const InputDecoration(labelText: 'Название'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: urlCtrl,
                      decoration: const InputDecoration(labelText: 'URL RSS'),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<NewsLanguage>(
                      initialValue: language,
                      decoration: const InputDecoration(labelText: 'Язык'),
                      items: [
                        for (final l in NewsLanguage.values)
                          DropdownMenuItem(
                            value: l,
                            child: Text('${l.shortLabel} · ${l.labelRu}'),
                          ),
                      ],
                      onChanged: (v) =>
                          setLocal(() => language = v ?? language),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<NewsTopic>(
                      initialValue: topic,
                      decoration: const InputDecoration(labelText: 'Тема'),
                      items: [
                        for (final t in NewsTopic.values)
                          DropdownMenuItem(value: t, child: Text(t.labelRu)),
                      ],
                      onChanged: (v) => setLocal(() => topic = v ?? topic),
                    ),
                    const SizedBox(height: 12),
                    Text('Приоритет: $priority'),
                    Slider(
                      value: priority.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: '$priority',
                      onChanged: (v) => setLocal(() => priority = v.round()),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Добавить'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) return;
    final url = urlCtrl.text.trim();
    if (!url.startsWith('http')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Укажите корректный URL ленты')),
        );
      }
      return;
    }
    final entry = await ref.read(newsFeedStoreProvider).addCustom(
          label: labelCtrl.text,
          feedUrl: url,
          topic: topic,
          language: language,
          priority: priority,
        );
    setState(() => _feeds = [..._feeds, entry]);
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RSS-ленты')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCustom,
        icon: const Icon(Icons.add),
        label: const Text('Своя лента'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
        itemCount: _feeds.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final feed = _feeds[index];
          return Card(
            color: AppColors.nightElevated,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          feed.label,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Switch(
                        value: feed.enabled,
                        onChanged: (v) async {
                          _feeds[index] = feed.copyWith(enabled: v);
                          await _persist();
                        },
                      ),
                      if (feed.isCustom)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await ref.read(newsFeedStoreProvider).remove(feed.id);
                            setState(() => _feeds.removeAt(index));
                          },
                        ),
                    ],
                  ),
                  Text(
                    feed.feedUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mist,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${feed.language.shortLabel} · ${feed.topic.labelRu} · приоритет ${feed.priority}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.amber,
                        ),
                  ),
                  Slider(
                    value: feed.priority.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '${feed.priority}',
                    onChanged: (v) {
                      setState(() {
                        _feeds[index] = feed.copyWith(priority: v.round());
                      });
                    },
                    onChangeEnd: (_) => _persist(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
