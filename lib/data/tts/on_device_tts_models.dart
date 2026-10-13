/// Offline Russian neural TTS models (Piper via sherpa-onnx).
///
/// Kokoro-RU needs a Flutter RuG2P stack that isn't available yet;
/// Piper RU is the production-ready on-device path for this app.
abstract final class OnDeviceTtsModels {
  /// Clearest male reading voice — recommended default for sleep reading.
  static const denis = OnDeviceTtsModel(
    id: 'piper_denis',
    labelRu: 'Денис (лучший offline)',
    descriptionRu:
        'Самый чистый Piper RU для чтения вслух. Рекомендуем для книг и ночи.',
    archiveUrl:
        'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-piper-ru_RU-denis-medium.tar.bz2',
    folderName: 'vits-piper-ru_RU-denis-medium',
    modelFile: 'ru_RU-denis-medium.onnx',
    tokensFile: 'tokens.txt',
    dataDirName: 'espeak-ng-data',
    recommended: true,
  );

  static const dmitri = OnDeviceTtsModel(
    id: 'piper_dmitri',
    labelRu: 'Дмитрий (offline)',
    descriptionRu:
        'Глубокий мужской нейроголос Piper. Хорош для длинных глав.',
    archiveUrl:
        'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-piper-ru_RU-dmitri-medium.tar.bz2',
    folderName: 'vits-piper-ru_RU-dmitri-medium',
    modelFile: 'ru_RU-dmitri-medium.onnx',
    tokensFile: 'tokens.txt',
    dataDirName: 'espeak-ng-data',
  );

  static const irina = OnDeviceTtsModel(
    id: 'piper_irina',
    labelRu: 'Ирина (offline)',
    descriptionRu:
        'Мягкий женский Piper на телефоне. Без интернета после загрузки.',
    archiveUrl:
        'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-piper-ru_RU-irina-medium.tar.bz2',
    folderName: 'vits-piper-ru_RU-irina-medium',
    modelFile: 'ru_RU-irina-medium.onnx',
    tokensFile: 'tokens.txt',
    dataDirName: 'espeak-ng-data',
  );

  static const ruslan = OnDeviceTtsModel(
    id: 'piper_ruslan',
    labelRu: 'Руслан (offline)',
    descriptionRu:
        'Мужской нейроголос Piper на телефоне. Без интернета после загрузки.',
    archiveUrl:
        'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-piper-ru_RU-ruslan-medium.tar.bz2',
    folderName: 'vits-piper-ru_RU-ruslan-medium',
    modelFile: 'ru_RU-ruslan-medium.onnx',
    tokensFile: 'tokens.txt',
    dataDirName: 'espeak-ng-data',
  );

  static const List<OnDeviceTtsModel> all = [denis, dmitri, irina, ruslan];

  static OnDeviceTtsModel get recommended => denis;

  static OnDeviceTtsModel? byId(String id) {
    for (final m in all) {
      if (m.id == id) return m;
    }
    return null;
  }
}

class OnDeviceTtsModel {
  const OnDeviceTtsModel({
    required this.id,
    required this.labelRu,
    required this.descriptionRu,
    required this.archiveUrl,
    required this.folderName,
    required this.modelFile,
    required this.tokensFile,
    required this.dataDirName,
    this.recommended = false,
  });

  final String id;
  final String labelRu;
  final String descriptionRu;
  final String archiveUrl;
  final String folderName;
  final String modelFile;
  final String tokensFile;
  final String dataDirName;
  final bool recommended;
}
