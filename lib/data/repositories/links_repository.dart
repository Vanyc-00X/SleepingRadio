import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums/comment_length.dart';
import '../../domain/enums/episode_type.dart';
import '../../domain/enums/url_read_mode.dart';
import '../../domain/models/episode.dart' as domain;
import '../../domain/models/source_material.dart';
import '../local/app_database.dart' as db;
import '../llm/local_comment_service.dart';
import '../web/calm_script_composer.dart';
import '../web/url_extractor.dart';

class LinksRepository {
  LinksRepository(
    this._db, {
    UrlExtractor? extractor,
    this._commentService,
  }) : _extractor = extractor ?? UrlExtractor();

  final db.AppDatabase _db;
  final UrlExtractor _extractor;
  final LocalCommentService? _commentService;
  final _uuid = const Uuid();
  final _composer = CalmScriptComposer();

  Stream<List<domain.Episode>> watchLinkEpisodes() {
    return (_db.select(_db.episodes)
          ..where((t) => t.type.equals(EpisodeType.url.storageValue))
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

  Future<domain.Episode> importAndCompose({
    required String url,
    required UrlReadMode mode,
    required CommentLength commentLength,
  }) async {
    final sourceId = _uuid.v4();
    final now = DateTime.now();

    await _db
        .into(_db.sourceMaterials)
        .insert(
          db.SourceMaterialsCompanion.insert(
            id: sourceId,
            title: 'Загрузка…',
            url: Value(url),
            status: Value(SourceMaterialStatus.extracting.storageValue),
            createdAt: Value(now),
          ),
        );

    try {
      final article = await _extractor.extract(url);
      final aiComment = await _commentService?.tryCalmComment(
        sourceText: article.text,
        length: commentLength,
      );
      final composed = _composer.compose(
        title: article.title,
        articleText: article.text,
        mode: mode,
        commentLength: commentLength,
        aiComment: aiComment,
      );

      await (_db.update(_db.sourceMaterials)
            ..where((t) => t.id.equals(sourceId)))
          .write(
            db.SourceMaterialsCompanion(
              title: Value(article.title),
              extractedText: Value(article.text),
              status: Value(SourceMaterialStatus.ready.storageValue),
              errorMessage: const Value(null),
            ),
          );

      final episodeId = _uuid.v4();
      await _db
          .into(_db.episodes)
          .insert(
            db.EpisodesCompanion.insert(
              id: episodeId,
              title: composed.title,
              type: EpisodeType.url.storageValue,
              script: Value(composed.script),
              sourceId: Value(sourceId),
              createdAt: Value(now),
            ),
          );

      return (await getEpisode(episodeId))!;
    } catch (error) {
      final message = error is UrlExtractException
          ? error.message
          : 'Не удалось прочитать страницу.';
      await (_db.update(_db.sourceMaterials)
            ..where((t) => t.id.equals(sourceId)))
          .write(
            db.SourceMaterialsCompanion(
              title: const Value('Ошибка'),
              status: Value(SourceMaterialStatus.failed.storageValue),
              errorMessage: Value(message),
            ),
          );
      if (error is UrlExtractException) rethrow;
      throw UrlExtractException(message);
    }
  }

  Future<void> deleteEpisode(String episodeId) async {
    final episode = await getEpisode(episodeId);
    await (_db.delete(_db.episodes)..where((t) => t.id.equals(episodeId))).go();
    final sourceId = episode?.sourceId;
    if (sourceId != null) {
      await (_db.delete(
        _db.sourceMaterials,
      )..where((t) => t.id.equals(sourceId))).go();
    }
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
