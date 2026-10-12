import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../domain/models/book.dart';

final bookImportProvider =
    AsyncNotifierProvider<BookImportNotifier, void>(BookImportNotifier.new);

class BookImportNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Book?> pickAndImport() async {
    state = const AsyncLoading();
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['epub', 'fb2'],
      );
      if (files.isEmpty) {
        state = const AsyncData(null);
        return null;
      }

      final path = files.single.path;
      if (path == null || path.isEmpty) {
        throw Exception('Не удалось получить путь к файлу');
      }

      final book = await ref.read(booksRepositoryProvider).importFromPath(path);
      ref.invalidate(bookProvider(book.id));
      state = const AsyncData(null);
      return book;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }

  Future<void> deleteBook(String bookId) async {
    await ref.read(booksRepositoryProvider).deleteBook(bookId);
    ref.invalidate(bookProvider(bookId));
  }
}
