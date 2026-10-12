enum EpisodeType {
  bookChapter,
  news,
  url,
  podcast;

  String get storageValue => name;

  static EpisodeType fromStorage(String value) {
    return EpisodeType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EpisodeType.url,
    );
  }
}
