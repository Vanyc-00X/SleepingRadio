enum TtsBackend {
  system,
  cloud,
  localComfy,
  onDevice,
}

class TtsVoice {
  const TtsVoice({
    required this.id,
    required this.labelRu,
    required this.cloudVoiceId,
    required this.systemPitch,
    required this.descriptionRu,
    this.backend = TtsBackend.cloud,
    this.badgeRu,
  });

  final String id;
  final String labelRu;
  final String cloudVoiceId;
  final double systemPitch;
  final String descriptionRu;
  final TtsBackend backend;
  final String? badgeRu;

  bool get isLocalComfy => backend == TtsBackend.localComfy;
  bool get isOnDevice => backend == TtsBackend.onDevice;
}

abstract final class TtsVoices {
  static const piperDenis = TtsVoice(
    id: 'piper_denis',
    labelRu: 'Денис',
    cloudVoiceId: 'denis',
    systemPitch: 0.95,
    descriptionRu:
        'Лучший offline-голос для чтения книг. Чистый Piper RU на телефоне.',
    backend: TtsBackend.onDevice,
    badgeRu: 'рекомендуем',
  );

  static const piperDmitri = TtsVoice(
    id: 'piper_dmitri',
    labelRu: 'Дмитрий',
    cloudVoiceId: 'dmitri',
    systemPitch: 0.9,
    descriptionRu: 'Глубокий мужской Piper offline для длинных глав.',
    backend: TtsBackend.onDevice,
  );

  static const piperIrina = TtsVoice(
    id: 'piper_irina',
    labelRu: 'Ирина',
    cloudVoiceId: 'irina',
    systemPitch: 1.0,
    descriptionRu: 'Мягкий женский Piper offline.',
    backend: TtsBackend.onDevice,
  );

  static const piperRuslan = TtsVoice(
    id: 'piper_ruslan',
    labelRu: 'Руслан',
    cloudVoiceId: 'ruslan',
    systemPitch: 0.95,
    descriptionRu: 'Мужской Piper offline.',
    backend: TtsBackend.onDevice,
  );

  static const calmFemale = TtsVoice(
    id: 'calm_female_ru',
    labelRu: 'Спокойный женский',
    cloudVoiceId: 'nova',
    systemPitch: 1.0,
    descriptionRu: 'Мягкий вечерний тембр (облако / система)',
  );

  static const warmMale = TtsVoice(
    id: 'warm_male_ru',
    labelRu: 'Тёплый мужской',
    cloudVoiceId: 'onyx',
    systemPitch: 0.85,
    descriptionRu: 'Низкий спокойный тембр (облако / система)',
  );

  static const goblinLocal = TtsVoice(
    id: 'goblin_local',
    labelRu: 'Гоблин (локальный клон)',
    cloudVoiceId: 'goblin',
    systemPitch: 1.0,
    descriptionRu:
        'Клон с вашего ПК через ComfyUI. Без облака, нужен Wi‑Fi до компьютера.',
    backend: TtsBackend.localComfy,
  );

  static const List<TtsVoice> all = [
    piperDenis,
    piperDmitri,
    piperIrina,
    piperRuslan,
    calmFemale,
    warmMale,
    goblinLocal,
  ];

  /// Voices shown in the live player picker (quick switch).
  static const List<TtsVoice> liveSwitchable = [
    piperDenis,
    piperDmitri,
    piperIrina,
    piperRuslan,
    calmFemale,
    warmMale,
  ];

  static TtsVoice byId(String id) {
    return all.firstWhere((v) => v.id == id, orElse: () => piperDenis);
  }
}
