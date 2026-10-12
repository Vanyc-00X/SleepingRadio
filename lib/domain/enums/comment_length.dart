enum CommentLength {
  off,
  short,
  medium;

  String get storageValue => name;

  String get labelRu => switch (this) {
    CommentLength.off => 'Выключено',
    CommentLength.short => 'Коротко',
    CommentLength.medium => 'Средне',
  };

  static CommentLength fromStorage(String value) {
    return CommentLength.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CommentLength.short,
    );
  }
}
