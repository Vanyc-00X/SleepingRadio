enum NewsTopic {
  politics,
  technology,
  science,
  culture,
  sport,
  local;

  String get storageValue => name;

  String get labelRu => switch (this) {
    NewsTopic.politics => 'Политика',
    NewsTopic.technology => 'Технологии',
    NewsTopic.science => 'Наука',
    NewsTopic.culture => 'Культура',
    NewsTopic.sport => 'Спорт',
    NewsTopic.local => 'Local',
  };

  static NewsTopic fromStorage(String value) {
    return NewsTopic.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NewsTopic.technology,
    );
  }
}
