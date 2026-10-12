import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/book.dart';
import '../player/player_controller.dart';

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBook = ref.watch(bookProvider(bookId));
    final settings = ref.watch(settingsProvider).asData?.value;

    return asyncBook.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Книга')),
        body: Center(child: Text('Ошибка: $error')),
      ),
      data: (book) {
        if (book == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Книга')),
            body: const Center(child: Text('Книга не найдена')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (book.author != null)
                      Text(
                        book.author!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      '${book.format.toUpperCase()} · ${book.chapters.length} глав · '
                      '${book.progress.percent.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mist,
                      ),
                    ),
                    if (settings?.booksReadOnly ?? true) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Только чтение — комментарии ИИ выключены',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.amberDim,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => _playChapter(
                        context,
                        ref,
                        book,
                        book.currentChapter ?? book.chapters.first,
                        resume: true,
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Продолжить'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: book.chapters.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final chapter = book.chapters[index];
                    final isCurrent = chapter.id == book.progress.chapterId;
                    return ListTile(
                      leading: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isCurrent ? AppColors.amber : AppColors.mist,
                        ),
                      ),
                      title: Text(
                        chapter.title,
                        style: TextStyle(
                          color: isCurrent ? AppColors.amber : AppColors.moon,
                          fontWeight:
                              isCurrent ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      subtitle: Text(
                        '${chapter.content.length} знаков',
                        style: const TextStyle(color: AppColors.mist),
                      ),
                      trailing: const Icon(Icons.play_circle_outline),
                      onTap: () => _playChapter(
                        context,
                        ref,
                        book,
                        chapter,
                        resume: isCurrent,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _playChapter(
    BuildContext context,
    WidgetRef ref,
    Book book,
    BookChapter chapter, {
    required bool resume,
  }) async {
    final full = await ref.read(booksRepositoryProvider).getBook(book.id);
    if (full == null) return;
    final fullChapter = full.chapters.firstWhere((c) => c.id == chapter.id);
    final offset = resume && chapter.id == book.progress.chapterId
        ? book.progress.charOffset
        : 0;

    await ref.read(playerSessionProvider.notifier).playBookChapter(
      bookId: book.id,
      chapterId: fullChapter.id,
      bookTitle: book.title,
      chapterTitle: fullChapter.title,
      text: fullChapter.content,
      startCharOffset: offset,
    );

    if (context.mounted) {
      context.go('/player');
    }
  }
}
