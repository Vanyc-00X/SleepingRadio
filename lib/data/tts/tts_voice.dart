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
  });

  final String id;
  final String labelRu;
  final String cloudVoiceId;
  final double systemPitch;
  final String descriptionRu;
  final TtsBackend backend;

  bool get isLocalComfy => backend == TtsBackend.localComfy;
  bool get isOnDevice => backend == TtsBackend.onDevice;
}

abstract final class TtsVoices {
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

  static const piperIrina = TtsVoice(
    id: 'piper_irina',
    labelRu: 'Ирина (offline)',
    cloudVoiceId: 'irina',
    systemPitch: 1.0,
    descriptionRu:
        'Нейроголос Piper на телефоне. Без интернета после загрузки модели.',
    backend: TtsBackend.onDevice,
  );

  static const piperRuslan = TtsVoice(
    id: 'piper_ruslan',
    labelRu: 'Руслан (offline)',
    cloudVoiceId: 'ruslan',
    systemPitch: 0.95,
    descriptionRu:
        'Мужской нейроголос Piper на телефоне. Без интернета после загрузки.',
    backend: TtsBackend.onDevice,
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
    piperIrina,
    piperRuslan,
    calmFemale,
    warmMale,
    goblinLocal,
  ];

  static TtsVoice byId(String id) {
    return all.firstWhere((v) => v.id == id, orElse: () => calmFemale);
  }
}
