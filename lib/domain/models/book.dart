class BookChapter {
  const BookChapter({
    required this.id,
    required this.title,
    required this.orderIndex,
    this.startOffset = 0,
  });

  final String id;
  final String title;
  final int orderIndex;
  final int startOffset;
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
}
