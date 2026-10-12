import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/book.dart' as domain;
import '../books/epub_book_parser.dart';
import '../books/fb2_book_parser.dart';
import '../local/app_database.dart' as db;

class BooksRepository {
  BooksRepository(this._db);

  final db.AppDatabase _db;
  final _uuid = const Uuid();
  final _epubParser = EpubBookParser();
  final _fb2Parser = Fb2BookParser();

  Stream<List<domain.Book>> watchBooks() {
    return (_db.select(_db.books)..orderBy([
          (t) => OrderingTerm(
            expression: t.lastOpenedAt,
            mode: OrderingMode.desc,
          ),
          (t) => OrderingTerm(
            expression: t.importedAt,
            mode: OrderingMode.desc,
          ),
        ]))
        .watch()
        .asyncMap((rows) async {
          final books = <domain.Book>[];
          for (final row in rows) {
            books.add(await _toDomain(row, includeContent: false));
          }
          return books;
        });
  }

  Future<domain.Book?> getBook(String id, {bool includeContent = true}) async {
    final row = await (_db.select(
      _db.books,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return _toDomain(row, includeContent: includeContent);
  }

  Future<domain.Book> importFromPath(String sourcePath) async {
    final ext = p.extension(sourcePath).toLowerCase();
    if (ext != '.epub' && ext != '.fb2') {
      throw FormatException(
        'Поддерживаются только .epub и .fb2, получено $ext',
      );
    }

    final bytes = await File(sourcePath).readAsBytes();
    final parsed = ext == '.epub'
        ? await _epubParser.parse(bytes)
        : _fb2Parser.parse(bytes);

    final docs = await getApplicationDocumentsDirectory();
    final booksDir = Directory(p.join(docs.path, 'books'));
    if (!await booksDir.exists()) {
      await booksDir.create(recursive: true);
    }

    final id = _uuid.v4();
    final storedPath = p.join(booksDir.path, '$id$ext');
    await File(storedPath).writeAsBytes(bytes, flush: true);

    final now = DateTime.now();
    final chapterCompanions = <db.BookChaptersCompanion>[];
    var offset = 0;
    for (var i = 0; i < parsed.chapters.length; i++) {
      final chapter = parsed.chapters[i];
      chapterCompanions.add(
        db.BookChaptersCompanion.insert(
          id: _uuid.v4(),
          bookId: id,
          title: chapter.title,
          orderIndex: i,
          startOffset: Value(offset),
          content: Value(chapter.content),
        ),
      );
      offset += chapter.content.length;
    }

    await _db.transaction(() async {
      await _db
          .into(_db.books)
          .insert(
            db.BooksCompanion.insert(
              id: id,
              title: parsed.title,
              author: Value(parsed.author),
              filePath: storedPath,
              format: parsed.format,
              chapterId: Value(chapterCompanions.first.id.value),
              importedAt: Value(now),
              lastOpenedAt: Value(now),
            ),
          );
      await _db.batch((batch) {
        batch.insertAll(_db.bookChapters, chapterCompanions);
      });
    });

    return (await getBook(id))!;
  }

  Future<void> updateProgress({
    required String bookId,
    required String chapterId,
    required int charOffset,
    required double percent,
  }) async {
    await (_db.update(_db.books)..where((t) => t.id.equals(bookId))).write(
      db.BooksCompanion(
        chapterId: Value(chapterId),
        charOffset: Value(charOffset),
        percent: Value(percent.clamp(0, 100)),
        lastOpenedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> touchOpened(String bookId) async {
    await (_db.update(_db.books)..where((t) => t.id.equals(bookId))).write(
      db.BooksCompanion(lastOpenedAt: Value(DateTime.now())),
    );
  }

  Future<void> deleteBook(String bookId) async {
    final book = await getBook(bookId, includeContent: false);
    await (_db.delete(
      _db.bookChapters,
    )..where((t) => t.bookId.equals(bookId))).go();
    await (_db.delete(_db.books)..where((t) => t.id.equals(bookId))).go();
    if (book != null) {
      final file = File(book.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<domain.Book> _toDomain(
    db.Book row, {
    required bool includeContent,
  }) async {
    final chapterQuery = _db.select(_db.bookChapters)
      ..where((t) => t.bookId.equals(row.id))
      ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]);
    final chapterRows = await chapterQuery.get();

    return domain.Book(
      id: row.id,
      title: row.title,
      author: row.author,
      filePath: row.filePath,
      format: row.format,
      coverPath: row.coverPath,
      chapters: [
        for (final c in chapterRows)
          domain.BookChapter(
            id: c.id,
            title: c.title,
            orderIndex: c.orderIndex,
            startOffset: c.startOffset,
            content: includeContent ? c.content : '',
          ),
      ],
      progress: domain.BookProgress(
        chapterId: row.chapterId,
        charOffset: row.charOffset,
        percent: row.percent,
      ),
      importedAt: row.importedAt,
      lastOpenedAt: row.lastOpenedAt,
    );
  }
}
