class BookChapter {
  const BookChapter({
    required this.id,
    required this.title,
    required this.orderIndex,
    this.startOffset = 0,
    this.content = '',
  });

  final String id;
  final String title;
  final int orderIndex;
  final int startOffset;
  final String content;

  int get length => content.length;
}

class BookProgress {
  const BookProgress({
    this.chapterId,
    this.charOffset = 0,
    this.percent = 0,
  });

  final String? chapterId;
  final int charOffset;
  final double percent;
}

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.filePath,
    required this.format,
    this.author,
    this.coverPath,
    this.chapters = const [],
    this.progress = const BookProgress(),
    this.importedAt,
    this.lastOpenedAt,
  });

  final String id;
  final String title;
  final String? author;
  final String filePath;
  final String format;
  final String? coverPath;
  final List<BookChapter> chapters;
  final BookProgress progress;
  final DateTime? importedAt;
  final DateTime? lastOpenedAt;

  BookChapter? get currentChapter {
    if (chapters.isEmpty) return null;
    final id = progress.chapterId;
    if (id == null) return chapters.first;
    for (final chapter in chapters) {
      if (chapter.id == id) return chapter;
    }
    return chapters.first;
  }
}

/// Результат парсинга файла до сохранения в БД.
class ParsedBook {
  const ParsedBook({
    required this.title,
    required this.format,
    this.author,
    required this.chapters,
  });

  final String title;
  final String? author;
  final String format;
  final List<ParsedChapter> chapters;
}

class ParsedChapter {
  const ParsedChapter({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;
}
