import 'package:flutter_test/flutter_test.dart';
import 'package:sleeping_radio/data/tts/audio_cache_store.dart';
import 'package:sleeping_radio/data/tts/comfy_local_tts_client.dart';
import 'package:sleeping_radio/data/tts/on_device_tts_models.dart';
import 'package:sleeping_radio/data/tts/tts_voice.dart';

void main() {
  test('cache key stable for same inputs', () {
    final store = AudioCacheStore();
    final a = store.keyFor(
      voiceId: TtsVoices.calmFemale.id,
      text: 'Привет, ночь',
      speechRate: 1,
      pitch: 1,
    );
    final b = store.keyFor(
      voiceId: TtsVoices.calmFemale.id,
      text: 'Привет, ночь',
      speechRate: 1,
      pitch: 1,
    );
    final c = store.keyFor(
      voiceId: TtsVoices.warmMale.id,
      text: 'Привет, ночь',
      speechRate: 1,
      pitch: 1,
    );
    expect(a, b);
    expect(a, isNot(c));
    expect(a.length, 64);
  });

  test('voice catalog includes offline piper and goblin', () {
    expect(TtsVoices.all.length, greaterThanOrEqualTo(4));
    expect(TtsVoices.byId('unknown').id, TtsVoices.calmFemale.id);
    expect(TtsVoices.goblinLocal.isLocalComfy, isTrue);
    expect(TtsVoices.piperIrina.isOnDevice, isTrue);
    expect(TtsVoices.piperRuslan.isOnDevice, isTrue);
  });

  test('on-device model ids match voice ids', () {
    expect(OnDeviceTtsModels.byId(TtsVoices.piperIrina.id)?.folderName,
        contains('irina'));
    expect(OnDeviceTtsModels.byId(TtsVoices.piperRuslan.id)?.folderName,
        contains('ruslan'));
  });

  test('detectLanguage prefers Russian for cyrillic', () {
    expect(
      ComfyLocalTtsClient.detectLanguage('Привет, ночь'),
      'Russian (ru)',
    );
    expect(
      ComfyLocalTtsClient.detectLanguage('Hello night reader'),
      'English (en)',
    );
  });
}
