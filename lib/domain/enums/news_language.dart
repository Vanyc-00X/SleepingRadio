enum NewsLanguage {
  ru,
  en;

  String get storageValue => name;

  String get labelRu => switch (this) {
        NewsLanguage.ru => 'Русский',
        NewsLanguage.en => 'English',
      };

  String get shortLabel => switch (this) {
        NewsLanguage.ru => 'RU',
        NewsLanguage.en => 'EN',
      };

  static NewsLanguage fromStorage(String value) {
    return NewsLanguage.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NewsLanguage.ru,
    );
  }
}
