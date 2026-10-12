import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart' hide Book;
import '../../data/repositories/books_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/book.dart';
import '../../domain/models/user_settings.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden in main');
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(appDatabaseProvider));
});

final booksRepositoryProvider = Provider<BooksRepository>((ref) {
  return BooksRepository(ref.watch(appDatabaseProvider));
});

final booksProvider = StreamProvider<List<Book>>((ref) {
  return ref.watch(booksRepositoryProvider).watchBooks();
});

final bookProvider = FutureProvider.family<Book?, String>((ref, id) {
  return ref.watch(booksRepositoryProvider).getBook(id);
});

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, UserSettings>(SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<UserSettings> {
  @override
  Future<UserSettings> build() {
    return ref.read(settingsRepositoryProvider).load();
  }

  Future<void> updateSettings(
    UserSettings Function(UserSettings) transform,
  ) async {
    final current = state.asData?.value ?? const UserSettings();
    final next = transform(current);
    state = AsyncData(next);
    await ref.read(settingsRepositoryProvider).save(next);
  }
}
