import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/book.dart';
import '../books/books_controller.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksProvider);
    final importing = ref.watch(bookImportProvider).isLoading;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Библиотека'),
          actions: [
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
                      subtitle: 'Импортируйте .fb2 или .epub',
                    )
                  : _BooksList(books: books),
            ),
            const _EmptyLibraryTab(
              icon: Icons.podcasts_outlined,
              title: 'Выпусков пока нет',
              subtitle: 'Новости и подкасты появятся позже',
            ),
            const _EmptyLibraryTab(
              icon: Icons.link_outlined,
              title: 'Ссылок пока нет',
              subtitle: 'URL Reader — этап 4',
            ),
            const _EmptyLibraryTab(
              icon: Icons.favorite_border,
              title: 'Избранное пусто',
              subtitle: 'Отмечайте материалы звёздочкой',
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

class _EmptyLibraryTab extends StatelessWidget {
  const _EmptyLibraryTab({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

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
          ],
        ),
      ),
    );
  }
}
