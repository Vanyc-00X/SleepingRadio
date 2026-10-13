import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/listen_history.dart';
import '../local/app_database.dart';

class HistoryItem {
  const HistoryItem({
    required this.entry,
    required this.title,
    required this.subtitle,
  });

  final ListenHistoryEntry entry;
  final String title;
  final String subtitle;
}

class ListenHistoryRepository {
  ListenHistoryRepository(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  Stream<List<HistoryItem>> watchRecent({int limit = 20}) {
    final query = _db.select(_db.listenHistoryRows).join([
      leftOuterJoin(
        _db.episodes,
        _db.episodes.id.equalsExp(_db.listenHistoryRows.episodeId),
      ),
    ])
      ..orderBy([
        OrderingTerm(
          expression: _db.listenHistoryRows.startedAt,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(limit);

    return query.watch().map((rows) {
      return rows.map((row) {
        final history = row.readTable(_db.listenHistoryRows);
        final episode = row.readTableOrNull(_db.episodes);
        return HistoryItem(
          entry: ListenHistoryEntry(
            id: history.id,
            episodeId: history.episodeId,
            startedAt: history.startedAt,
            endedAt: history.endedAt,
            listened: Duration(milliseconds: history.listenedMs),
          ),
          title: episode?.title ?? 'Прослушивание',
          subtitle: episode == null
              ? 'Материал удалён'
              : _subtitleForType(episode.type),
        );
      }).toList();
    });
  }

  Future<void> recordStart({
    required String episodeId,
  }) async {
    // Normalize media ids like episode:uuid / book:uuid
    final id = episodeId.contains(':')
        ? episodeId.split(':').last
        : episodeId;

    await _db
        .into(_db.listenHistoryRows)
        .insert(
          ListenHistoryRowsCompanion.insert(
            id: _uuid.v4(),
            episodeId: id,
            startedAt: DateTime.now(),
          ),
        );
  }

  String _subtitleForType(String type) {
    return switch (type) {
      'news' => 'Новости',
      'url' => 'Ссылка',
      'podcast' => 'Подкаст',
      'bookChapter' => 'Книга',
      _ => 'Выпуск',
    };
  }
}
