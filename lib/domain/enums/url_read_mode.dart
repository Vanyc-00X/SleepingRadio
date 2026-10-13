enum UrlReadMode {
  read,
  readWithComment,
  summaryWithComment;

  String get labelRu => switch (this) {
    UrlReadMode.read => 'Прочитать',
    UrlReadMode.readWithComment => 'Прочитать + комментарий',
    UrlReadMode.summaryWithComment => 'Краткий пересказ + комментарий',
  };

  String get hintRu => switch (this) {
    UrlReadMode.read => 'Только текст статьи',
    UrlReadMode.readWithComment => 'Текст, затем короткий спокойный комментарий',
    UrlReadMode.summaryWithComment => 'Сжатый пересказ и мягкий комментарий',
  };
}
