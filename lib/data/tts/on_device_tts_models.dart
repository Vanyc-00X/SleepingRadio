/// Offline Russian neural TTS models (Piper via sherpa-onnx).
///
/// Kokoro-RU (zaakirio) needs a Flutter RuG2P stack that isn't available yet;
/// Piper RU is the production-ready on-device path for this app.
abstract final class OnDeviceTtsModels {
  static const irina = OnDeviceTtsModel(
    id: 'piper_irina',
    labelRu: 'Ирина (offline)',
    descriptionRu:
        'Нейроголос Piper на телефоне. Без интернета после загрузки модели.',
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

  static const List<OnDeviceTtsModel> all = [irina, ruslan];

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
  });

  final String id;
  final String labelRu;
  final String descriptionRu;
  final String archiveUrl;
  final String folderName;
  final String modelFile;
  final String tokensFile;
  final String dataDirName;
}
