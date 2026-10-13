import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

import 'on_device_model_store.dart';
import 'on_device_tts_models.dart';

/// Offline Piper RU synthesizer (sherpa-onnx).
class OnDeviceTtsEngine {
  OnDeviceTtsEngine({OnDeviceModelStore? store})
      : _store = store ?? OnDeviceModelStore();

  final OnDeviceModelStore _store;
  sherpa.OfflineTts? _tts;
  String? _loadedModelId;
  var _bindingsReady = false;

  OnDeviceModelStore get store => _store;

  Future<void> _ensureBindings() async {
    if (_bindingsReady || kIsWeb) return;
    await sherpa.initBindingsAsync();
    _bindingsReady = true;
  }

  Future<bool> isReady(OnDeviceTtsModel model) => _store.isInstalled(model);

  Future<void> ensureModel(
    OnDeviceTtsModel model, {
    OnDeviceDownloadProgress? onProgress,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('On-device TTS недоступен в web');
    }
    await _store.ensureInstalled(model, onProgress: onProgress);
  }

  Future<void> load(OnDeviceTtsModel model) async {
    if (kIsWeb) {
      throw UnsupportedError('On-device TTS недоступен в web');
    }
    if (_loadedModelId == model.id && _tts != null) return;

    await _ensureBindings();
    final paths = await _store.ensureInstalled(model);
    _tts?.free();
    _tts = sherpa.OfflineTts(
      sherpa.OfflineTtsConfig(
        model: sherpa.OfflineTtsModelConfig(
          vits: sherpa.OfflineTtsVitsModelConfig(
            model: paths.model,
            tokens: paths.tokens,
            dataDir: paths.dataDir,
          ),
          numThreads: 2,
          debug: false,
          provider: 'cpu',
        ),
        maxNumSenetences: 1,
      ),
    );
    _loadedModelId = model.id;
  }

  /// Returns WAV bytes (16-bit PCM).
  Future<Uint8List> synthesize({
    required OnDeviceTtsModel model,
    required String text,
    double speed = 1.0,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('text is empty');
    }
    await load(model);
    final tts = _tts;
    if (tts == null) {
      throw StateError('TTS engine not loaded');
    }

    final audio = await Future(() {
      return tts.generate(
        text: trimmed,
        sid: 0,
        speed: speed.clamp(0.5, 2.0),
      );
    });

    if (audio.samples.isEmpty || audio.sampleRate <= 0) {
      throw StateError('On-device TTS returned empty audio');
    }
    return _float32ToWav(audio.samples, audio.sampleRate);
  }

  Future<File> synthesizeToCacheFile({
    required OnDeviceTtsModel model,
    required String text,
    required String outPath,
    double speed = 1.0,
  }) async {
    final bytes = await synthesize(model: model, text: text, speed: speed);
    final file = File(outPath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  void dispose() {
    _tts?.free();
    _tts = null;
    _loadedModelId = null;
    _store.close();
  }

  Uint8List _float32ToWav(Float32List samples, int sampleRate) {
    final pcm = Int16List(samples.length);
    for (var i = 0; i < samples.length; i++) {
      final v = (samples[i] * 32767.0).round().clamp(-32768, 32767);
      pcm[i] = v;
    }
    final dataLength = pcm.length * 2;
    final bytes = BytesBuilder();
    void writeString(String s) => bytes.add(s.codeUnits);
    void writeUint32(int v) {
      bytes.add([v & 0xff, (v >> 8) & 0xff, (v >> 16) & 0xff, (v >> 24) & 0xff]);
    }

    void writeUint16(int v) {
      bytes.add([v & 0xff, (v >> 8) & 0xff]);
    }

    writeString('RIFF');
    writeUint32(36 + dataLength);
    writeString('WAVE');
    writeString('fmt ');
    writeUint32(16);
    writeUint16(1); // PCM
    writeUint16(1); // mono
    writeUint32(sampleRate);
    writeUint32(sampleRate * 2);
    writeUint16(2);
    writeUint16(16);
    writeString('data');
    writeUint32(dataLength);
    bytes.add(Uint8List.view(pcm.buffer, pcm.offsetInBytes, dataLength));
    return bytes.toBytes();
  }
}

/// Convenience: resolve model by voice id used in settings.
OnDeviceTtsModel? onDeviceModelForVoiceId(String voiceId) {
  return OnDeviceTtsModels.byId(voiceId);
}

String onDeviceCacheFileName(String key) => p.setExtension(key, '.wav');
