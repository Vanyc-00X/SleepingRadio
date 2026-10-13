import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

import '../../../data/books/text_cleaner.dart';
import '../../../data/tts/audio_cache_store.dart';
import '../../../data/tts/cloud_tts_client.dart';
import '../../../data/tts/comfy_local_tts_client.dart';
import '../../../data/tts/on_device_tts_engine.dart';
import '../../../data/tts/on_device_tts_models.dart';
import '../../../data/tts/tts_voice.dart';

typedef BookTtsProgress = void Function(int charOffset, bool completed);

enum NarrationMode { system, cloud, localComfy, onDevice }

/// Чтение книги: offline neural / cloud / ComfyUI + fallback на системный.
class BookTtsEngine {
  BookTtsEngine({
    AudioCacheStore? cache,
    OnDeviceTtsEngine? onDevice,
  })  : _cache = cache ?? AudioCacheStore(),
        _onDevice = onDevice ?? OnDeviceTtsEngine();

  final AudioCacheStore _cache;
  final OnDeviceTtsEngine _onDevice;
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _cloudPlayer = AudioPlayer();
  final _done = StreamController<void>.broadcast();

  List<String> _chunks = const [];
  List<int> _chunkStarts = const [];
  int _index = 0;
  int _charOffset = 0;
  int _totalChars = 0;
  bool _playing = false;
  bool _ready = false;
  double _speechRate = 1;
  double _pitch = 1;
  TtsVoice _voice = TtsVoices.calmFemale;
  bool _preferCloud = false;
  String? _apiKey;
  String _baseUrl = CloudTtsClient.defaultBaseUrl;
  String _comfyUrl = ComfyLocalTtsClient.defaultBaseUrl;
  NarrationMode _activeMode = NarrationMode.system;
  BookTtsProgress? onProgress;

  bool get isPlaying => _playing;
  int get charOffset => _charOffset;
  int get totalChars => _totalChars;
  NarrationMode get activeMode => _activeMode;
  TtsVoice get voice => _voice;

  Future<void> ready() async {
    if (_ready) return;
    try {
      await _tts.setLanguage('ru-RU');
    } catch (_) {
      try {
        await _tts.setLanguage('en-US');
      } catch (_) {}
    }
    try {
      await _tts.awaitSpeakCompletion(true);
    } catch (_) {}
    _tts.setCompletionHandler(() {
      if (!_done.isClosed) _done.add(null);
    });
    _tts.setCancelHandler(() {
      if (!_done.isClosed) _done.add(null);
    });
    _cloudPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (!_done.isClosed) _done.add(null);
      }
    });
    _ready = true;
  }

  Future<void> prepare({
    required String text,
    required int startOffset,
    required double speechRate,
    double pitch = 1,
    String voiceId = 'calm_female_ru',
    bool preferCloud = false,
    String? apiKey,
    String? baseUrl,
    String? comfyUrl,
    int cacheLimitGb = 2,
  }) async {
    await ready();
    await stop();
    _speechRate = speechRate;
    _pitch = pitch;
    _voice = TtsVoices.byId(voiceId);
    _preferCloud = preferCloud && !kIsWeb;
    _apiKey = apiKey;
    _baseUrl = baseUrl ?? CloudTtsClient.defaultBaseUrl;
    _comfyUrl = (comfyUrl == null || comfyUrl.trim().isEmpty)
        ? ComfyLocalTtsClient.defaultBaseUrl
        : comfyUrl.trim();
    _cache.limitGb = cacheLimitGb;
    _totalChars = text.length;
    _chunks = TextCleaner.chunkForTts(text);
    _chunkStarts = _computeStarts(text, _chunks);
    _index = _indexForOffset(startOffset);
    _charOffset = startOffset.clamp(0, _totalChars);

    if (!kIsWeb && _voice.isOnDevice) {
      _activeMode = NarrationMode.onDevice;
    } else if (!kIsWeb && _voice.isLocalComfy) {
      _activeMode = NarrationMode.localComfy;
    } else {
      final canCloud = _preferCloud && (_apiKey?.isNotEmpty ?? false);
      _activeMode = canCloud ? NarrationMode.cloud : NarrationMode.system;
    }
    await _applyVoiceSettings();
  }

  Future<void> play() async {
    if (_chunks.isEmpty) {
      onProgress?.call(_totalChars, true);
      return;
    }
    _playing = true;
    while (_playing && _index < _chunks.length) {
      _charOffset = _chunkStarts[_index];
      onProgress?.call(_charOffset, false);
      final chunk = _chunks[_index];

      try {
        if (_activeMode == NarrationMode.onDevice) {
          await _speakOnDevice(chunk);
        } else if (_activeMode == NarrationMode.localComfy) {
          await _speakLocalComfy(chunk);
        } else if (_activeMode == NarrationMode.cloud) {
          await _speakCloud(chunk);
        } else {
          await _speakSystem(chunk);
        }
      } catch (error) {
        debugPrint('TTS chunk failed ($error), fallback to system');
        _activeMode = NarrationMode.system;
        await _applyVoiceSettings();
        await _speakSystem(chunk);
      }

      if (!_playing) break;
      _index++;
      if (_index < _chunks.length) {
        _charOffset = _chunkStarts[_index];
      } else {
        _charOffset = _totalChars;
      }
      onProgress?.call(_charOffset, _index >= _chunks.length);
    }
    _playing = false;
  }

  Future<void> _speakSystem(String chunk) async {
    await _tts.speak(chunk);
    await _done.stream.first;
  }

  Future<void> _speakCloud(String chunk) async {
    final key = _cache.keyFor(
      voiceId: _voice.id,
      text: chunk,
      speechRate: _speechRate,
      pitch: _pitch,
    );
    var file = await _cache.find(key);
    if (file == null) {
      final client = CloudTtsClient(apiKey: _apiKey!, baseUrl: _baseUrl);
      try {
        final bytes = await client.synthesize(
          text: chunk,
          cloudVoiceId: _voice.cloudVoiceId,
        );
        file = await _cache.put(key: key, bytes: bytes, extension: 'mp3');
      } finally {
        client.close();
      }
    }

    await _playCachedFile(file.path);
  }

  Future<void> _speakLocalComfy(String chunk) async {
    final key = _cache.keyFor(
      voiceId: _voice.id,
      text: chunk,
      speechRate: _speechRate,
      pitch: _pitch,
    );
    var file = await _cache.find(key);
    if (file == null) {
      final client = ComfyLocalTtsClient(baseUrl: _comfyUrl);
      try {
        final bytes = await client.synthesize(text: chunk);
        final ext = _audioExtension(bytes);
        file = await _cache.put(key: key, bytes: bytes, extension: ext);
      } finally {
        client.close();
      }
    }

    await _playCachedFile(file.path);
  }

  Future<void> _speakOnDevice(String chunk) async {
    final model = OnDeviceTtsModels.byId(_voice.id);
    if (model == null) {
      throw StateError('No on-device model for ${_voice.id}');
    }
    final key = _cache.keyFor(
      voiceId: _voice.id,
      text: chunk,
      speechRate: _speechRate,
      pitch: _pitch,
    );
    var file = await _cache.find(key);
    if (file == null) {
      final bytes = await _onDevice.synthesize(
        model: model,
        text: chunk,
        speed: _speechRate,
      );
      file = await _cache.put(key: key, bytes: bytes, extension: 'wav');
    }
    await _playCachedFile(file.path);
  }

  Future<void> _playCachedFile(String path) async {
    await _cloudPlayer.setFilePath(path);
    await _cloudPlayer.setSpeed(_speechRate.clamp(0.8, 1.5));
    await _cloudPlayer.setVolume(1);
    unawaited(_cloudPlayer.play());
    await _done.stream.first;
  }

  String _audioExtension(List<int> bytes) {
    if (bytes.length >= 4 &&
        bytes[0] == 0x66 &&
        bytes[1] == 0x4C &&
        bytes[2] == 0x61 &&
        bytes[3] == 0x43) {
      return 'flac';
    }
    if (bytes.length >= 4 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46) {
      return 'wav';
    }
    return 'mp3';
  }

  Future<void> pause() async {
    _playing = false;
    await _tts.stop();
    await _cloudPlayer.pause();
    onProgress?.call(_charOffset, false);
  }

  Future<void> stop() async {
    _playing = false;
    await _tts.stop();
    await _cloudPlayer.stop();
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await _applyVoiceSettings();
  }

  Future<void> setPitch(double pitch) async {
    _pitch = pitch;
    await _applyVoiceSettings();
  }

  Future<void> setVolume(double volume) async {
    final v = volume.clamp(0.0, 1.0);
    await _tts.setVolume(v);
    await _cloudPlayer.setVolume(v);
  }

  Future<void> seekBySeconds(int seconds) async {
    final cps = 14 * _speechRate;
    final delta = (seconds * cps).round();
    await seekToChar((_charOffset + delta).clamp(0, _totalChars));
  }

  Future<void> seekToChar(int offset) async {
    final wasPlaying = _playing;
    await pause();
    _charOffset = offset.clamp(0, _totalChars);
    _index = _indexForOffset(_charOffset);
    onProgress?.call(_charOffset, false);
    if (wasPlaying) {
      unawaited(play());
    }
  }

  Duration estimateDuration() {
    if (_totalChars <= 0) return Duration.zero;
    final cps = 14 * _speechRate;
    return Duration(seconds: (_totalChars / cps).ceil());
  }

  Duration estimatePosition() {
    if (_totalChars <= 0) return Duration.zero;
    final cps = 14 * _speechRate;
    return Duration(milliseconds: ((_charOffset / cps) * 1000).round());
  }

  Future<void> _applyVoiceSettings() async {
    final normalized = (0.35 + (_speechRate - 0.8) * (0.3 / 0.7)).clamp(0.2, 0.8);
    await _tts.setSpeechRate(normalized);
    final pitch = (_pitch * _voice.systemPitch).clamp(0.5, 2.0);
    try {
      await _tts.setPitch(pitch);
    } catch (_) {}
  }

  int _indexForOffset(int offset) {
    if (_chunkStarts.isEmpty) return 0;
    for (var i = _chunkStarts.length - 1; i >= 0; i--) {
      if (_chunkStarts[i] <= offset) return i;
    }
    return 0;
  }

  List<int> _computeStarts(String text, List<String> chunks) {
    final starts = <int>[];
    var cursor = 0;
    for (final chunk in chunks) {
      final idx = text.indexOf(chunk, cursor);
      if (idx >= 0) {
        starts.add(idx);
        cursor = idx + chunk.length;
      } else {
        starts.add(cursor);
        cursor += chunk.length;
      }
    }
    return starts;
  }

  Future<void> dispose() async {
    await stop();
    await _cloudPlayer.dispose();
    _onDevice.dispose();
    await _done.close();
  }
}
