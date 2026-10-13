import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/tts/on_device_tts_engine.dart';
import '../../data/tts/on_device_tts_models.dart';
import '../../data/tts/tts_voice.dart';

/// Короткий семпл для предпрослушивания голоса в настройках.
class VoicePreview {
  VoicePreview({required this.onDevice});

  final OnDeviceTtsEngine onDevice;
  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _system = FlutterTts();
  var _busy = false;

  static const sampleRu =
      'Добрый вечер. Это короткий пример голоса для спокойного чтения.';

  bool get isBusy => _busy;

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    try {
      await _system.stop();
    } catch (_) {}
  }

  Future<void> play({
    required TtsVoice voice,
    double speechRate = 1,
    double pitch = 1,
    void Function(String status)? onStatus,
  }) async {
    if (_busy) {
      await stop();
    }
    _busy = true;
    try {
      await stop();
      if (voice.isOnDevice) {
        final model = OnDeviceTtsModels.byId(voice.id);
        if (model == null) {
          throw StateError('Модель не найдена');
        }
        final ready = await onDevice.isReady(model);
        if (!ready) {
          onStatus?.call('Сначала скачайте модель');
          throw StateError('Модель не установлена');
        }
        onStatus?.call('Синтез семпла…');
        final bytes = await onDevice.synthesize(
          model: model,
          text: sampleRu,
          speed: speechRate,
        );
        final dir = await getTemporaryDirectory();
        final file = File(p.join(dir.path, 'voice_preview_${voice.id}.wav'));
        await file.writeAsBytes(bytes, flush: true);
        onStatus?.call('Воспроизведение…');
        await _player.setFilePath(file.path);
        await _player.setVolume(1);
        await _player.seek(Duration.zero);
        await _player.play();
        await _player.processingStateStream.firstWhere(
          (s) => s == ProcessingState.completed,
        );
        onStatus?.call('Готово');
        return;
      }

      if (voice.isLocalComfy) {
        onStatus?.call('Превью Comfy — на плеере после настройки URL');
        throw StateError('Превью локального клона недоступно здесь');
      }

      onStatus?.call('Воспроизведение…');
      await _system.setLanguage('ru-RU');
      await _system.setSpeechRate((speechRate * 0.45).clamp(0.2, 0.7));
      await _system.setPitch(pitch.clamp(0.5, 1.5));
      await _system.setVolume(1);
      await _system.awaitSpeakCompletion(true);
      await _system.speak(sampleRu);
      onStatus?.call('Готово');
    } finally {
      _busy = false;
    }
  }

  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }
}
