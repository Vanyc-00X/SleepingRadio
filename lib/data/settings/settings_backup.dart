import 'dart:convert';

import '../../domain/enums/comment_length.dart';
import '../../domain/enums/news_topic.dart';
import '../../domain/models/user_settings.dart';
import '../tts/tts_api_key_store.dart';
import 'stage8_prefs.dart';

/// Локальный экспорт/импорт профиля (без облачного аккаунта).
class SettingsBackup {
  SettingsBackup({
    required this.settings,
    required this.stage8,
    required this.keyStore,
  });

  final UserSettings settings;
  final Stage8Prefs stage8;
  final TtsApiKeyStore keyStore;

  static const formatVersion = 1;

  Map<String, Object?> toMap({bool includeSecrets = false}) {
    return {
      'formatVersion': formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': {
        'voiceId': settings.voiceId,
        'speechRate': settings.speechRate,
        'pitch': settings.pitch,
        'commentLength': settings.commentLength.storageValue,
        'defaultTimerMinutes': settings.defaultTimerMinutes,
        'cacheLimitGb': settings.cacheLimitGb,
        'newsTopics': settings.newsTopics.map((t) => t.storageValue).toList(),
        'useCloudAi': settings.useCloudAi,
        'booksReadOnly': settings.booksReadOnly,
        'onboardingCompleted': settings.onboardingCompleted,
      },
      'stage8': stage8.toJson(),
      if (includeSecrets)
        'secrets': {
          'ttsBaseUrl': keyStore.loadBaseUrl(),
          // Ключ по умолчанию не экспортируем.
        },
    };
  }

  String toPrettyJson({bool includeSecrets = false}) {
    return const JsonEncoder.withIndent('  ').convert(
      toMap(includeSecrets: includeSecrets),
    );
  }

  static UserSettings parseSettings(Map<String, dynamic> root) {
    final map = root['settings'];
    if (map is! Map) return const UserSettings();
    final topics = (map['newsTopics'] as List?)
            ?.whereType<String>()
            .map(NewsTopic.fromStorage)
            .toList() ??
        const <NewsTopic>[];
    return UserSettings(
      voiceId: map['voiceId'] as String? ?? 'calm_female_ru',
      speechRate: (map['speechRate'] as num?)?.toDouble() ?? 1,
      pitch: (map['pitch'] as num?)?.toDouble() ?? 1,
      commentLength: CommentLength.fromStorage(
        map['commentLength'] as String? ?? 'short',
      ),
      defaultTimerMinutes: map['defaultTimerMinutes'] as int? ?? 30,
      cacheLimitGb: map['cacheLimitGb'] as int? ?? 2,
      newsTopics: topics.isEmpty
          ? const [NewsTopic.technology, NewsTopic.science]
          : topics,
      useCloudAi: map['useCloudAi'] as bool? ?? true,
      booksReadOnly: map['booksReadOnly'] as bool? ?? true,
      onboardingCompleted: map['onboardingCompleted'] as bool? ?? true,
    );
  }

  static Map<String, dynamic>? parseStage8(Map<String, dynamic> root) {
    final map = root['stage8'];
    if (map is! Map) return null;
    return Map<String, dynamic>.from(map);
  }
}
