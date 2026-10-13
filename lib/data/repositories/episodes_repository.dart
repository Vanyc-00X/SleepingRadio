import 'package:drift/drift.dart';

import '../../domain/enums/episode_type.dart';
import '../../domain/models/episode.dart' as domain;
import '../local/app_database.dart' as db;

class EpisodesRepository {
  EpisodesRepository(this._db);

  final db.AppDatabase _db;

  Stream<List<domain.Episode>> watchFavorites() {
    return (_db.select(_db.episodes)
          ..where((t) => t.isFavorite.equals(true))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch()
        .map((rows) => rows.map(_map).toList());
  }

  Future<domain.Episode?> getEpisode(String id) async {
    final row = await (_db.select(
      _db.episodes,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return _map(row);
  }

  Future<void> setFavorite(String episodeId, bool favorite) async {
    await (_db.update(_db.episodes)..where((t) => t.id.equals(episodeId)))
        .write(db.EpisodesCompanion(isFavorite: Value(favorite)));
  }

  Future<void> rename(String episodeId, String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    await (_db.update(_db.episodes)..where((t) => t.id.equals(episodeId)))
        .write(db.EpisodesCompanion(title: Value(trimmed)));
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
