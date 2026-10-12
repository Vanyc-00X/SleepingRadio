import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/user_settings.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(appDatabaseProvider));
});

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, UserSettings>(SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<UserSettings> {
  @override
  Future<UserSettings> build() {
    return ref.read(settingsRepositoryProvider).load();
  }

  Future<void> updateSettings(UserSettings Function(UserSettings) transform) async {
    final current = state.asData?.value ?? const UserSettings();
    final next = transform(current);
    state = AsyncData(next);
    await ref.read(settingsRepositoryProvider).save(next);
  }
}
