import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums/episode_type.dart';
import '../../domain/models/episode.dart' as domain;
import '../local/app_database.dart' as db;
import '../podcast/podcast_composer.dart';

class PodcastRepository {
  PodcastRepository(this._db);

  final db.AppDatabase _db;
  final _uuid = const Uuid();
  final _composer = PodcastComposer();

  Stream<List<domain.Episode>> watchPodcastEpisodes() {
    return (_db.select(_db.episodes)
          ..where((t) => t.type.equals(EpisodeType.podcast.storageValue))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch()
        .map((rows) => rows.map(_map).toList());
  }

  /// Выпуски новостей и подкастов для вкладки «Выпуски».
  Stream<List<domain.Episode>> watchShowEpisodes() {
    return (_db.select(_db.episodes)
          ..where(
            (t) =>
                t.type.equals(EpisodeType.news.storageValue) |
                t.type.equals(EpisodeType.podcast.storageValue),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch()
        .map((rows) => rows.map(_map).toList());
  }

  Future<domain.Episode> buildAndSave({
    required List<PodcastSegmentDraft> segments,
    required PodcastTargetMinutes target,
    String? customTitle,
  }) async {
    final composed = _composer.compose(
      segments: segments,
      target: target,
      customTitle: customTitle,
    );

    final id = _uuid.v4();
    final now = DateTime.now();
    await _db
        .into(_db.episodes)
        .insert(
          db.EpisodesCompanion.insert(
            id: id,
            title: composed.title,
            type: EpisodeType.podcast.storageValue,
            script: Value(composed.script),
            createdAt: Value(now),
          ),
        );

    return domain.Episode(
      id: id,
      title: composed.title,
      type: EpisodeType.podcast,
      script: composed.script,
      createdAt: now,
    );
  }

  Future<void> deleteEpisode(String episodeId) async {
    await (_db.delete(_db.episodes)..where((t) => t.id.equals(episodeId))).go();
  }

  domain.Episode _map(db.Episode row) {
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
