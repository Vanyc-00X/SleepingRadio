import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/enums/episode_type.dart';
import '../../domain/models/book.dart';
import '../../domain/models/episode.dart';
import '../books/books_controller.dart';
import '../player/player_controller.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksProvider);
    final linksAsync = ref.watch(linkEpisodesProvider);
    final newsAsync = ref.watch(showEpisodesProvider);
    final favoritesAsync = ref.watch(favoriteEpisodesProvider);
    final importing = ref.watch(bookImportProvider).isLoading;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Библиотека'),
          actions: [
            IconButton(
              tooltip: 'Добавить ссылку',
              onPressed: () => context.push('/link'),
              icon: const Icon(Icons.link),
            ),
            IconButton(
              tooltip: 'Импорт книги',
              onPressed: importing ? null : () => _import(context, ref),
              icon: importing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.amber,
            labelColor: AppColors.amber,
            unselectedLabelColor: AppColors.mist,
            tabs: [
              Tab(text: 'Книги'),
              Tab(text: 'Выпуски'),
              Tab(text: 'Ссылки'),
              Tab(text: 'Избранное'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: importing ? null : () => _import(context, ref),
          backgroundColor: AppColors.amber,
          foregroundColor: AppColors.night,
          icon: const Icon(Icons.file_open_outlined),
          label: const Text('Импорт'),
        ),
        body: TabBarView(
          children: [
            booksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Ошибка: $e')),
              data: (books) => books.isEmpty
                  ? const _EmptyLibraryTab(
                      icon: Icons.menu_book_outlined,
                      title: 'Книг пока нет',
                      subtitle: 'Импортируйте .fb2, .epub, .txt или .pdf',
                    )
                  : _BooksList(books: books),
            ),
            newsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Ошибка: $e')),
              data: (episodes) => episodes.isEmpty
                  ? _EmptyLibraryTab(
                      icon: Icons.podcasts_outlined,
                      title: 'Выпусков пока нет',
                      subtitle: 'Новости или конструктор подкаста',
                      actionLabel: 'Собрать выпуск',
                      onAction: () => context.push('/podcast'),
                    )
                  : _EpisodesList(
                      episodes: episodes,
                      subtitleLabel: 'Выпуск',
                      onDelete: (id) async {
                        final episode = episodes.firstWhere((e) => e.id == id);
                        if (episode.type == EpisodeType.podcast) {
                          await ref
                              .read(podcastRepositoryProvider)
                              .deleteEpisode(id);
                        } else {
                          await ref
                              .read(newsRepositoryProvider)
                              .deleteEpisode(id);
                        }
                      },
                    ),
            ),
            linksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Ошибка: $e')),
              data: (links) => links.isEmpty
                  ? _EmptyLibraryTab(
                      icon: Icons.link_outlined,
                      title: 'Ссылок пока нет',
                      subtitle: 'Вставьте URL статьи на экране «Ссылка»',
                      actionLabel: 'Открыть',
                      onAction: () => context.push('/link'),
                    )
                  : _EpisodesList(
                      episodes: links,
                      subtitleLabel: 'Ссылка',
                      onDelete: (id) =>
                          ref.read(linksRepositoryProvider).deleteEpisode(id),
                    ),
            ),
            favoritesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Ошибка: $e')),
              data: (favorites) => favorites.isEmpty
                  ? const _EmptyLibraryTab(
                      icon: Icons.favorite_border,
                      title: 'Избранное пусто',
                      subtitle: 'Отмечайте выпуски и ссылки звёздочкой',
                    )
                  : _EpisodesList(
                      episodes: favorites,
                      subtitleLabel: 'Избранное',
                      deleteLabel: 'Убрать из избранного',
                      onDelete: (id) async {
                        await ref
                            .read(episodesRepositoryProvider)
                            .setFavorite(id, false);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    try {
      final book = await ref.read(bookImportProvider.notifier).pickAndImport();
      if (book != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Импортировано: ${book.title}')),
        );
        context.push('/book/${book.id}');
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось импортировать: $error')),
        );
      }
    }
  }
}

class _BooksList extends ConsumerWidget {
  const _BooksList({required this.books});

  final List<Book> books;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
      itemCount: books.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final book = books[index];
        return ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: AppColors.nightElevated,
          leading: CircleAvatar(
            backgroundColor: AppColors.amber.withValues(alpha: 0.15),
            child: Text(
              book.format.toUpperCase().substring(0, 1),
              style: const TextStyle(color: AppColors.amber),
            ),
          ),
          title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            [
              if (book.author != null) book.author!,
              '${book.progress.percent.toStringAsFixed(0)}%',
              '${book.chapters.length} гл.',
            ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.mist),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.nightElevated,
                  title: const Text('Удалить книгу?'),
                  content: Text(book.title),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Отмена'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Удалить'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await ref.read(bookImportProvider.notifier).deleteBook(book.id);
              }
            },
          ),
          onTap: () => context.push('/book/${book.id}'),
        );
      },
    );
  }
}

class _EpisodesList extends ConsumerWidget {
  const _EpisodesList({
    required this.episodes,
    required this.subtitleLabel,
    required this.onDelete,
    this.deleteLabel,
  });

  final List<Episode> episodes;
  final String subtitleLabel;
  final String? deleteLabel;
  final Future<void> Function(String id) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLink = subtitleLabel == 'Ссылка';
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
      itemCount: episodes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final episode = episodes[index];
        final playLabel = switch (episode.type) {
          EpisodeType.url => 'Ссылка',
          EpisodeType.news => 'Новости',
          EpisodeType.podcast => 'Подкаст',
          EpisodeType.bookChapter => 'Книга',
        };
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: AppColors.nightElevated,
          leading: CircleAvatar(
            backgroundColor: AppColors.amber.withValues(alpha: 0.15),
            child: Icon(
              isLink ? Icons.link : Icons.podcasts_outlined,
              color: AppColors.amber,
            ),
          ),
          title: Text(
            episode.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            episode.script == null
                ? playLabel
                : '${episode.script!.length} знаков · $playLabel',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                button: true,
                label: episode.isFavorite
                    ? 'Убрать из избранного'
                    : 'В избранное',
                child: IconButton(
                  icon: Icon(
                    episode.isFavorite ? Icons.star : Icons.star_border,
                    color: episode.isFavorite
                        ? AppColors.amber
                        : AppColors.mist,
                  ),
                  onPressed: () {
                    ref.read(episodesRepositoryProvider).setFavorite(
                      episode.id,
                      !episode.isFavorite,
                    );
                  },
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.mist),
                color: AppColors.nightElevated,
                onSelected: (value) async {
                  if (value == 'rename') {
                    await _renameEpisode(context, ref, episode);
                  } else if (value == 'delete') {
                    final action = deleteLabel ??
                        'Удалить ${isLink ? 'ссылку' : 'выпуск'}';
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.nightElevated,
                        title: Text('$action?'),
                        content: Text(episode.title),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Отмена'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(deleteLabel ?? 'Удалить'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) await onDelete(episode.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'rename',
                    child: Text('Переименовать'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(deleteLabel ?? 'Удалить'),
                  ),
                ],
              ),
            ],
          ),
          onTap: () async {
            final script = episode.script?.trim() ?? '';
            if (script.isEmpty) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Нет текста для озвучки')),
                );
              }
              return;
            }
            await ref.read(playerSessionProvider.notifier).playNarration(
              episodeId: episode.id,
              title: episode.title,
              subtitle: playLabel,
              script: script,
            );
            if (context.mounted) context.go('/player');
          },
        );
      },
    );
  }

  Future<void> _renameEpisode(
    BuildContext context,
    WidgetRef ref,
    Episode episode,
  ) async {
    final controller = TextEditingController(text: episode.title);
    final next = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.nightElevated,
        title: const Text('Переименовать'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Название'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (next != null) {
      await ref.read(episodesRepositoryProvider).rename(episode.id, next);
    }
  }
}

class _EmptyLibraryTab extends StatelessWidget {
  const _EmptyLibraryTab({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.mist.withValues(alpha: 0.7)),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
