import 'package:drift/drift.dart';

import '../../domain/enums/comment_length.dart';
import '../../domain/enums/news_topic.dart';
import '../../domain/models/user_settings.dart';
import '../local/app_database.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Future<UserSettings> load() async {
    final row = await (_db.select(
      _db.userSettingsRows,
    )..where((t) => t.id.equals(1))).getSingleOrNull();

    if (row == null) {
      const defaults = UserSettings();
      await save(defaults);
      return defaults;
    }

    return _map(row);
  }

  Future<void> save(UserSettings settings) async {
    await _db
        .into(_db.userSettingsRows)
        .insertOnConflictUpdate(
          UserSettingsRowsCompanion.insert(
            id: const Value(1),
            voiceId: Value(settings.voiceId),
            speechRate: Value(settings.speechRate),
            pitch: Value(settings.pitch),
            commentLength: Value(settings.commentLength.storageValue),
            defaultTimerMinutes: Value(settings.defaultTimerMinutes),
            cacheLimitGb: Value(settings.cacheLimitGb),
            newsTopicsCsv: Value(
              settings.newsTopics.map((t) => t.storageValue).join(','),
            ),
            useCloudAi: Value(settings.useCloudAi),
            onboardingCompleted: Value(settings.onboardingCompleted),
            booksReadOnly: Value(settings.booksReadOnly),
          ),
        );
  }

  UserSettings _map(UserSettingsRow row) {
    final topics = row.newsTopicsCsv
        .split(',')
        .where((s) => s.isNotEmpty)
        .map(NewsTopic.fromStorage)
        .toList();

    return UserSettings(
      voiceId: row.voiceId,
      speechRate: row.speechRate,
      pitch: row.pitch,
      commentLength: CommentLength.fromStorage(row.commentLength),
      defaultTimerMinutes: row.defaultTimerMinutes,
      cacheLimitGb: row.cacheLimitGb,
      newsTopics: topics.isEmpty
          ? const [NewsTopic.technology, NewsTopic.science]
          : topics,
      useCloudAi: row.useCloudAi,
      onboardingCompleted: row.onboardingCompleted,
      booksReadOnly: row.booksReadOnly,
    );
  }
}
