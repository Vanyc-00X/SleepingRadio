import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums/comment_length.dart';
import '../../domain/enums/episode_type.dart';
import '../../domain/enums/news_language.dart';
import '../../domain/enums/news_topic.dart';
import '../../domain/models/episode.dart' as domain;
import '../llm/local_comment_service.dart';
import '../local/app_database.dart' as db;
import '../news/news_episode_composer.dart';
import '../news/news_feed_store.dart';
import '../news/news_sources.dart';
import '../news/rss_client.dart';
import '../news/rss_models.dart';

class NewsRepository {
  NewsRepository(
    this._db, {
    RssClient? rssClient,
    this._commentService,
    this._feedStore,
  }) : _rss = rssClient ?? RssClient();

  final db.AppDatabase _db;
  final RssClient _rss;
  final LocalCommentService? _commentService;
  final NewsFeedStore? _feedStore;
  final _uuid = const Uuid();
  final _composer = NewsEpisodeComposer();

  Stream<List<domain.Episode>> watchNewsEpisodes() {
    return (_db.select(_db.episodes)
          ..where((t) => t.type.equals(EpisodeType.news.storageValue))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch()
        .map((rows) => rows.map(_mapEpisode).toList());
  }

  Future<domain.Episode?> getEpisode(String id) async {
    final row = await (_db.select(
      _db.episodes,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return _mapEpisode(row);
  }

  Future<List<RssItem>> fetchHeadlines(
    List<NewsTopic> topics, {
    NewsLanguage? language,
  }) async {
    final store = _feedStore;
    final lang = language ?? store?.language ?? NewsLanguage.ru;
    final feeds = store?.activeForTopics(topics, language: lang) ??
        NewsSources.forTopics(topics, language: lang)
            .map(
              (s) => NewsFeedEntry(
                id: s.id,
                label: s.label,
                feedUrl: s.feedUrl,
                topic: s.topic,
                language: s.language,
                priority: s.priority,
              ),
            )
            .toList();
    if (feeds.isEmpty) {
      throw RssFetchException(
        'Нет лент для выбранного языка и тем. '
        'Добавьте RSS в Настройки → RSS-ленты или смените язык.',
      );
    }

    final collected = <({RssItem item, int priority})>[];
    final errors = <String>[];

    for (final feed in feeds) {
      try {
        final parsed = await _rss.fetch(feed.feedUrl);
        for (final item in parsed.items.take(6)) {
          collected.add((item: item, priority: feed.priority));
        }
      } on RssFetchException catch (error) {
        errors.add('${feed.label}: ${error.message}');
      }
    }

    if (collected.isEmpty) {
      throw RssFetchException(
        errors.isEmpty
            ? 'Лента пуста. Попробуйте позже.'
            : errors.first,
      );
    }

    collected.sort((a, b) {
      final byPriority = b.priority.compareTo(a.priority);
      if (byPriority != 0) return byPriority;
      final ad = a.item.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = b.item.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bd.compareTo(ad);
    });

    return _dedupe(collected.map((e) => e.item).toList()).take(12).toList();
  }

  Future<domain.Episode> buildEpisode({
    required List<NewsTopic> topics,
    required CommentLength commentLength,
    required bool factsOnly,
    List<RssItem>? prefetched,
    NewsLanguage? language,
  }) async {
    final items =
        prefetched ?? await fetchHeadlines(topics, language: language);
    final factsBlob = items
        .take(6)
        .map((i) => '${i.title}. ${i.summary}')
        .join('\n');
    final aiComment = factsOnly
        ? null
        : await _commentService?.tryCalmComment(
            sourceText: factsBlob,
            length: commentLength,
          );
    final composed = _composer.compose(
      items: items,
      topics: topics,
      commentLength: commentLength,
      factsOnly: factsOnly,
      aiComment: aiComment,
    );

    final now = DateTime.now();
    final episodeId = _uuid.v4();
    await _db
        .into(_db.episodes)
        .insert(
          db.EpisodesCompanion.insert(
            id: episodeId,
            title: composed.title,
            type: EpisodeType.news.storageValue,
            script: Value(composed.script),
            createdAt: Value(now),
          ),
        );

    return (await getEpisode(episodeId))!;
  }

  Future<void> deleteEpisode(String episodeId) async {
    await (_db.delete(_db.episodes)..where((t) => t.id.equals(episodeId))).go();
  }

  List<RssItem> _dedupe(List<RssItem> items) {
    final seen = <String>{};
    final result = <RssItem>[];
    for (final item in items) {
      final key = item.title.toLowerCase().trim();
      if (seen.add(key)) result.add(item);
    }
    return result;
  }

  domain.Episode _mapEpisode(db.Episode row) {
    return domain.Episode(
      id: row.id,
      title: row.title,
      type: EpisodeType.fromStorage(row.type),
      script: row.script,
      audioPath: row.audioPath,
      duration: row.durationMs == null
          ? null
          : Duration(milliseconds: row.durationMs!),
      sourceId: row.sourceId,
      isFavorite: row.isFavorite,
      createdAt: row.createdAt,
    );
  }
}
