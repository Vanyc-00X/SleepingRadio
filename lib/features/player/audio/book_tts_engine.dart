import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

import '../../../data/books/text_cleaner.dart';

typedef BookTtsProgress = void Function(int charOffset, bool completed);

/// Последовательное чтение текста системным TTS (этап 2; этап 3 — облачный).
class BookTtsEngine {
  BookTtsEngine();

  final FlutterTts _tts = FlutterTts();
  final _done = StreamController<void>.broadcast();

  List<String> _chunks = const [];
  List<int> _chunkStarts = const [];
  int _index = 0;
  int _charOffset = 0;
  int _totalChars = 0;
  bool _playing = false;
  bool _ready = false;
  double _speechRate = 1;
  BookTtsProgress? onProgress;

  bool get isPlaying => _playing;
  int get charOffset => _charOffset;
  int get totalChars => _totalChars;

  Future<void> ready() async {
    if (_ready) return;
    await _tts.setLanguage('ru-RU');
    await _tts.awaitSpeakCompletion(true);
    _tts.setCompletionHandler(() {
      if (!_done.isClosed) _done.add(null);
    });
    _tts.setCancelHandler(() {
      if (!_done.isClosed) _done.add(null);
    });
    _ready = true;
  }

  Future<void> prepare({
    required String text,
    required int startOffset,
    required double speechRate,
  }) async {
    await ready();
    await stop();
    _speechRate = speechRate;
    _totalChars = text.length;
    _chunks = TextCleaner.chunkForTts(text);
    _chunkStarts = _computeStarts(text, _chunks);
    _index = _indexForOffset(startOffset);
    _charOffset = startOffset.clamp(0, _totalChars);
    await _applyRate(_speechRate);
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
      await _tts.speak(chunk);
      await _done.stream.first;
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

  Future<void> pause() async {
    _playing = false;
    await _tts.stop();
    onProgress?.call(_charOffset, false);
  }

  Future<void> stop() async {
    _playing = false;
    await _tts.stop();
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await _applyRate(rate);
  }

  Future<void> setVolume(double volume) => _tts.setVolume(volume.clamp(0, 1));

  /// Перемотка по оценке «символы ≈ секунды * 14 * rate».
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
    final seconds = (_totalChars / cps).ceil();
    return Duration(seconds: seconds);
  }

  Duration estimatePosition() {
    if (_totalChars <= 0) return Duration.zero;
    final cps = 14 * _speechRate;
    final seconds = (_charOffset / cps);
    return Duration(milliseconds: (seconds * 1000).round());
  }

  Future<void> _applyRate(double rate) async {
    // Android: 0.0–1.0 (1 = max). iOS: 0.0–1.0 с другим масштабом.
    // Маппинг 0.8–1.5 → ~0.35–0.65 на Android.
    final normalized = (0.35 + (rate - 0.8) * (0.3 / 0.7)).clamp(0.2, 0.8);
    await _tts.setSpeechRate(normalized);
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
    await _done.close();
  }
}
