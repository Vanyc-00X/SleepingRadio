import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../data/settings/stage8_prefs.dart';

class Stage8State {
  const Stage8State({
    required this.ambientEnabled,
    required this.ambientVolume,
    required this.voiceVolume,
    required this.autoAdvanceChapters,
    required this.ollamaEnabled,
    required this.ollamaUrl,
    required this.ollamaModel,
  });

  final bool ambientEnabled;
  final double ambientVolume;
  final double voiceVolume;
  final bool autoAdvanceChapters;
  final bool ollamaEnabled;
  final String ollamaUrl;
  final String ollamaModel;

  Stage8State copyWith({
    bool? ambientEnabled,
    double? ambientVolume,
    double? voiceVolume,
    bool? autoAdvanceChapters,
    bool? ollamaEnabled,
    String? ollamaUrl,
    String? ollamaModel,
  }) {
    return Stage8State(
      ambientEnabled: ambientEnabled ?? this.ambientEnabled,
      ambientVolume: ambientVolume ?? this.ambientVolume,
      voiceVolume: voiceVolume ?? this.voiceVolume,
      autoAdvanceChapters: autoAdvanceChapters ?? this.autoAdvanceChapters,
      ollamaEnabled: ollamaEnabled ?? this.ollamaEnabled,
      ollamaUrl: ollamaUrl ?? this.ollamaUrl,
      ollamaModel: ollamaModel ?? this.ollamaModel,
    );
  }
}

final stage8StateProvider =
    NotifierProvider<Stage8Notifier, Stage8State>(Stage8Notifier.new);

class Stage8Notifier extends Notifier<Stage8State> {
  Stage8Prefs get _prefs => ref.read(stage8PrefsProvider);

  @override
  Stage8State build() => _snapshot();

  Stage8State _snapshot() {
    final prefs = _prefs;
    return Stage8State(
      ambientEnabled: prefs.ambientEnabled,
      ambientVolume: prefs.ambientVolume,
      voiceVolume: prefs.voiceVolume,
      autoAdvanceChapters: prefs.autoAdvanceChapters,
      ollamaEnabled: prefs.ollamaEnabled,
      ollamaUrl: prefs.ollamaUrl,
      ollamaModel: prefs.ollamaModel,
    );
  }

  Future<void> setAmbientEnabled(bool value) async {
    await _prefs.setAmbientEnabled(value);
    state = _snapshot();
  }

  Future<void> setAmbientVolume(double value) async {
    await _prefs.setAmbientVolume(value);
    state = _snapshot();
  }

  Future<void> setVoiceVolume(double value) async {
    await _prefs.setVoiceVolume(value);
    state = _snapshot();
  }

  Future<void> setAutoAdvanceChapters(bool value) async {
    await _prefs.setAutoAdvanceChapters(value);
    state = _snapshot();
  }

  Future<void> setOllamaEnabled(bool value) async {
    await _prefs.setOllamaEnabled(value);
    state = _snapshot();
  }

  Future<void> setOllamaUrl(String value) async {
    await _prefs.setOllamaUrl(value);
    state = _snapshot();
  }

  Future<void> setOllamaModel(String value) async {
    await _prefs.setOllamaModel(value);
    state = _snapshot();
  }

  Future<void> applyMap(Map<String, dynamic> map) async {
    await _prefs.applyJson(map);
    state = _snapshot();
  }
}
