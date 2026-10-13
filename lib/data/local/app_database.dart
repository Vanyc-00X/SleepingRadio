import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class UserSettingsRows extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get voiceId =>
      text().withDefault(const Constant('piper_denis'))();
  RealColumn get speechRate => real().withDefault(const Constant(1.0))();
  RealColumn get pitch => real().withDefault(const Constant(1.0))();
  TextColumn get commentLength =>
      text().withDefault(const Constant('short'))();
  IntColumn get defaultTimerMinutes =>
      integer().withDefault(const Constant(30))();
  IntColumn get cacheLimitGb => integer().withDefault(const Constant(2))();
  TextColumn get newsTopicsCsv =>
      text().withDefault(const Constant('technology,science'))();
  BoolColumn get useCloudAi => boolean().withDefault(const Constant(false))();
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get booksReadOnly =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Books extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get author => text().nullable()();
  TextColumn get filePath => text()();
  TextColumn get format => text()();
  TextColumn get coverPath => text().nullable()();
  TextColumn get chapterId => text().nullable()();
  IntColumn get charOffset => integer().withDefault(const Constant(0))();
  RealColumn get percent => real().withDefault(const Constant(0))();
  DateTimeColumn get importedAt => dateTime().nullable()();
  DateTimeColumn get lastOpenedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class BookChapters extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text()();
  TextColumn get title => text()();
  IntColumn get orderIndex => integer()();
  IntColumn get startOffset => integer().withDefault(const Constant(0))();
  TextColumn get content => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SourceMaterials extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get url => text().nullable()();
  TextColumn get rawText => text().nullable()();
  TextColumn get extractedText => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Episodes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get type => text()();
  TextColumn get script => text().nullable()();
  TextColumn get audioPath => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get sourceId => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ListenHistoryRows extends Table {
  TextColumn get id => text()();
  TextColumn get episodeId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get listenedMs => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    UserSettingsRows,
    Books,
    BookChapters,
    SourceMaterials,
    Episodes,
    ListenHistoryRows,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(bookChapters, bookChapters.content);
        await m.addColumn(userSettingsRows, userSettingsRows.booksReadOnly);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'sleeping_radio',
      // Нужен для Flutter Web; на Android/iOS параметр игнорируется.
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
