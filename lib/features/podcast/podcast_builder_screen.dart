import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/podcast/podcast_composer.dart';
import '../../domain/models/episode.dart';
import '../player/player_controller.dart';

class PodcastBuilderScreen extends ConsumerStatefulWidget {
  const PodcastBuilderScreen({super.key});

  @override
  ConsumerState<PodcastBuilderScreen> createState() =>
      _PodcastBuilderScreenState();
}

class _PodcastBuilderScreenState extends ConsumerState<PodcastBuilderScreen> {
  var _target = PodcastTargetMinutes.ten;
  final _selected = <String>{};
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  var _building = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final news = ref.watch(newsEpisodesProvider).asData?.value ?? const [];
    final links = ref.watch(linkEpisodesProvider).asData?.value ?? const [];
    final pool = [...news, ...links];

    return Scaffold(
      appBar: AppBar(title: const Text('Собрать выпуск')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            'Интро → до 5 сегментов → спокойной ночи. '
            'Длительность ориентировочная.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text('Целевая длительность', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: PodcastTargetMinutes.values.map((value) {
              final selected = _target == value;
              return ChoiceChip(
                label: Text(value.labelRu),
                selected: selected,
                selectedColor: AppColors.amber.withValues(alpha: 0.3),
                onSelected: (_) => setState(() => _target = value),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Название (необязательно)',
              hintText: 'Вечерний выпуск',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Свой сегмент (необязательно)',
              hintText: 'Короткая заметка своим текстом',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Материалы (${_selected.length}/5)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          if (pool.isEmpty)
            const Text(
              'Пока нет новостей и ссылок. Сначала соберите сводку или прочитайте URL.',
              style: TextStyle(color: AppColors.mist),
            )
          else
            ...pool.map((episode) {
              final checked = _selected.contains(episode.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: AppColors.nightElevated,
                  borderRadius: BorderRadius.circular(14),
                  child: CheckboxListTile(
                    value: checked,
                    activeColor: AppColors.amber,
                    title: Text(episode.title, maxLines: 2),
                    subtitle: Text(
                      episode.type.name == 'news' ? 'Новости' : 'Ссылка',
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          if (_selected.length >= 5) return;
                          _selected.add(episode.id);
                        } else {
                          _selected.remove(episode.id);
                        }
                      });
                    },
                  ),
                ),
              );
            }),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _building ? null : () => _build(pool),
            icon: _building
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_building ? 'Собираем…' : 'Собрать и слушать'),
          ),
        ],
      ),
    );
  }

  Future<void> _build(List<Episode> pool) async {
    setState(() {
      _building = true;
      _error = null;
    });

    try {
      final selectedEpisodes = pool
          .where((e) => _selected.contains(e.id))
          .toList();
      final drafts = <PodcastSegmentDraft>[
        ...PodcastComposer().draftsFromEpisodes(selectedEpisodes),
      ];

      final note = _noteController.text.trim();
      if (note.isNotEmpty) {
        drafts.add(
          PodcastSegmentDraft(title: 'Личная заметка', body: note),
        );
      }

      if (drafts.isEmpty) {
        throw Exception('Выберите материалы или добавьте свой текст.');
      }
      if (drafts.length > 5) {
        throw Exception('Не больше 5 сегментов.');
      }

      final episode = await ref.read(podcastRepositoryProvider).buildAndSave(
        segments: drafts,
        target: _target,
        customTitle: _titleController.text,
      );

      final script = episode.script?.trim() ?? '';
      if (script.isEmpty) {
        throw Exception('Пустой скрипт выпуска.');
      }

      await ref.read(playerSessionProvider.notifier).playNarration(
        episodeId: episode.id,
        title: episode.title,
        subtitle: 'Подкаст',
        script: script,
      );

      if (!mounted) return;
      context.go('/player');
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _building = false);
    }
  }
}
