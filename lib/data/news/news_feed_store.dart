import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums/news_language.dart';
import '../../domain/enums/news_topic.dart';
import 'news_sources.dart';

/// Пользовательская или встроенная лента с приоритетом (выше = раньше в сводке).
class NewsFeedEntry {
  const NewsFeedEntry({
    required this.id,
    required this.label,
    required this.feedUrl,
    required this.topic,
    this.language = NewsLanguage.ru,
    this.priority = 50,
    this.enabled = true,
    this.isCustom = false,
  });

  final String id;
  final String label;
  final String feedUrl;
  final NewsTopic topic;
  final NewsLanguage language;
  final int priority;
  final bool enabled;
  final bool isCustom;

  NewsFeedEntry copyWith({
    String? label,
    String? feedUrl,
    NewsTopic? topic,
    NewsLanguage? language,
    int? priority,
    bool? enabled,
  }) {
    return NewsFeedEntry(
      id: id,
      label: label ?? this.label,
      feedUrl: feedUrl ?? this.feedUrl,
      topic: topic ?? this.topic,
      language: language ?? this.language,
      priority: priority ?? this.priority,
      enabled: enabled ?? this.enabled,
      isCustom: isCustom,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'feedUrl': feedUrl,
        'topic': topic.storageValue,
        'language': language.storageValue,
        'priority': priority,
        'enabled': enabled,
        'isCustom': isCustom,
      };

  factory NewsFeedEntry.fromJson(Map<String, dynamic> json) {
    return NewsFeedEntry(
      id: json['id'] as String,
      label: json['label'] as String? ?? 'Лента',
      feedUrl: json['feedUrl'] as String? ?? '',
      topic: NewsTopic.fromStorage(json['topic'] as String? ?? 'technology'),
      language: NewsLanguage.fromStorage(
        json['language'] as String? ??
            _inferLanguage(
              id: json['id'] as String? ?? '',
              url: json['feedUrl'] as String? ?? '',
            ),
      ),
      priority: (json['priority'] as num?)?.toInt() ?? 50,
      enabled: json['enabled'] as bool? ?? true,
      isCustom: json['isCustom'] as bool? ?? true,
    );
  }

  static String _inferLanguage({required String id, required String url}) {
    final hay = '$id $url'.toLowerCase();
    if (hay.contains('bbc') ||
        hay.contains('nasa') ||
        hay.contains('hnrss') ||
        hay.contains('hacker')) {
      return NewsLanguage.en.storageValue;
    }
    return NewsLanguage.ru.storageValue;
  }

  NewsSource toSource() => NewsSource(
        id: id,
        label: label,
        feedUrl: feedUrl,
        topic: topic,
        priority: priority,
        language: language,
      );
}

class NewsFeedStore {
  NewsFeedStore(this._prefs);

  final SharedPreferences _prefs;
  final _uuid = const Uuid();

  static const _feedsKey = 'news_feeds_v1';
  static const _languageKey = 'news_language_v1';

  NewsLanguage get language {
    final raw = _prefs.getString(_languageKey);
    if (raw == null || raw.isEmpty) return NewsLanguage.ru;
    return NewsLanguage.fromStorage(raw);
  }

  Future<void> setLanguage(NewsLanguage language) async {
    await _prefs.setString(_languageKey, language.storageValue);
  }

  List<NewsFeedEntry> builtins() {
    return [
      for (var i = 0; i < NewsSources.all.length; i++)
        NewsFeedEntry(
          id: NewsSources.all[i].id,
          label: NewsSources.all[i].label,
          feedUrl: NewsSources.all[i].feedUrl,
          topic: NewsSources.all[i].topic,
          language: NewsSources.all[i].language,
          priority: 80 - i,
          enabled: true,
          isCustom: false,
        ),
      const NewsFeedEntry(
        id: 'meduza_news',
        label: 'Meduza',
        feedUrl: 'https://meduza.io/rss/all',
        topic: NewsTopic.politics,
        language: NewsLanguage.ru,
        priority: 70,
      ),
      const NewsFeedEntry(
        id: 'lenta_top',
        label: 'Lenta.ru',
        feedUrl: 'https://lenta.ru/rss/news',
        topic: NewsTopic.politics,
        language: NewsLanguage.ru,
        priority: 65,
      ),
      const NewsFeedEntry(
        id: 'rbc_news',
        label: 'РБК',
        feedUrl: 'https://rssexport.rbc.ru/rbcnews/news/30/full.rss',
        topic: NewsTopic.politics,
        language: NewsLanguage.ru,
        priority: 66,
      ),
      const NewsFeedEntry(
        id: 'nplus1',
        label: 'N+1',
        feedUrl: 'https://nplus1.ru/rss',
        topic: NewsTopic.science,
        language: NewsLanguage.ru,
        priority: 72,
      ),
      const NewsFeedEntry(
        id: 'habr',
        label: 'Habr',
        feedUrl: 'https://habr.com/ru/rss/articles/?fl=ru',
        topic: NewsTopic.technology,
        language: NewsLanguage.ru,
        priority: 68,
      ),
      const NewsFeedEntry(
        id: 'ixbt',
        label: 'iXBT',
        feedUrl: 'https://www.ixbt.com/export/news.rss',
        topic: NewsTopic.technology,
        language: NewsLanguage.ru,
        priority: 64,
      ),
    ];
  }

  List<NewsFeedEntry> loadAll() {
    final raw = _prefs.getString(_feedsKey);
    if (raw == null || raw.isEmpty) {
      return builtins();
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final parsed = list
          .whereType<Map>()
          .map((e) => NewsFeedEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      if (parsed.isEmpty) return builtins();
      // Подтянуть новые встроенные ленты, которых ещё нет в сохранённом списке.
      final ids = parsed.map((e) => e.id).toSet();
      for (final built in builtins()) {
        if (!ids.contains(built.id)) {
          parsed.add(built);
        }
      }
      return parsed;
    } catch (_) {
      return builtins();
    }
  }

  Future<void> saveAll(List<NewsFeedEntry> feeds) async {
    await _prefs.setString(
      _feedsKey,
      jsonEncode(feeds.map((e) => e.toJson()).toList()),
    );
  }

  Future<NewsFeedEntry> addCustom({
    required String label,
    required String feedUrl,
    NewsTopic topic = NewsTopic.technology,
    NewsLanguage language = NewsLanguage.ru,
    int priority = 90,
  }) async {
    final feeds = loadAll();
    final entry = NewsFeedEntry(
      id: 'custom_${_uuid.v4()}',
      label: label.trim().isEmpty ? 'Моя лента' : label.trim(),
      feedUrl: feedUrl.trim(),
      topic: topic,
      language: language,
      priority: priority.clamp(0, 100),
      enabled: true,
      isCustom: true,
    );
    feeds.add(entry);
    await saveAll(feeds);
    return entry;
  }

  Future<void> update(NewsFeedEntry entry) async {
    final feeds = loadAll();
    final i = feeds.indexWhere((f) => f.id == entry.id);
    if (i < 0) return;
    feeds[i] = entry;
    await saveAll(feeds);
  }

  Future<void> remove(String id) async {
    final feeds = loadAll().where((f) => f.id != id).toList();
    await saveAll(feeds);
  }

  /// Активные ленты по языку и темам, отсортированные по приоритету (desc).
  List<NewsFeedEntry> activeForTopics(
    Iterable<NewsTopic> topics, {
    NewsLanguage? language,
  }) {
    final lang = language ?? this.language;
    final set = topics.toSet();
    final all = loadAll().where((f) => f.enabled && f.language == lang).toList();
    final filtered = set.isEmpty
        ? all
            .where(
              (f) =>
                  f.topic == NewsTopic.technology ||
                  f.topic == NewsTopic.science,
            )
            .toList()
        : all.where((f) => set.contains(f.topic)).toList();
    filtered.sort((a, b) => b.priority.compareTo(a.priority));
    return filtered;
  }
}
