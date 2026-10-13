import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Именованный пресет скорости / высоты / паузы между фразами.
class VoicePreset {
  const VoicePreset({
    required this.id,
    required this.labelRu,
    required this.speechRate,
    required this.pitch,
    required this.pauseMs,
    this.voiceId,
  });

  final String id;
  final String labelRu;
  final double speechRate;
  final double pitch;
  final int pauseMs;
  final String? voiceId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'labelRu': labelRu,
        'speechRate': speechRate,
        'pitch': pitch,
        'pauseMs': pauseMs,
        if (voiceId != null) 'voiceId': voiceId,
      };

  factory VoicePreset.fromJson(Map<String, dynamic> json) {
    return VoicePreset(
      id: json['id'] as String,
      labelRu: json['labelRu'] as String? ?? json['id'] as String,
      speechRate: (json['speechRate'] as num?)?.toDouble() ?? 1,
      pitch: (json['pitch'] as num?)?.toDouble() ?? 1,
      pauseMs: (json['pauseMs'] as num?)?.toInt() ?? 280,
      voiceId: json['voiceId'] as String?,
    );
  }
}

abstract final class BuiltInVoicePresets {
  static const calm = VoicePreset(
    id: 'calm',
    labelRu: 'Спокойно · Денис',
    speechRate: 0.9,
    pitch: 0.98,
    pauseMs: 420,
    voiceId: 'piper_denis',
  );

  static const night = VoicePreset(
    id: 'night',
    labelRu: 'Ночной · Дмитрий',
    speechRate: 0.85,
    pitch: 0.95,
    pauseMs: 520,
    voiceId: 'piper_dmitri',
  );

  static const clear = VoicePreset(
    id: 'clear',
    labelRu: 'Чётче · Денис',
    speechRate: 1.05,
    pitch: 1.0,
    pauseMs: 220,
    voiceId: 'piper_denis',
  );

  static const List<VoicePreset> all = [calm, night, clear];
}

class VoicePresetsStore {
  VoicePresetsStore(this._prefs);

  final SharedPreferences _prefs;

  static const _activeKey = 'voice_preset_active';
  static const _customKey = 'voice_presets_custom_v1';
  static const _pauseKey = 'tts_inter_chunk_pause_ms';

  String? get activePresetId => _prefs.getString(_activeKey);

  Future<void> setActivePresetId(String? id) async {
    if (id == null) {
      await _prefs.remove(_activeKey);
    } else {
      await _prefs.setString(_activeKey, id);
    }
  }

  int get interChunkPauseMs => _prefs.getInt(_pauseKey) ?? 280;

  Future<void> setInterChunkPauseMs(int ms) async {
    await _prefs.setInt(_pauseKey, ms.clamp(0, 2000));
  }

  List<VoicePreset> customPresets() {
    final raw = _prefs.getString(_customKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map>()
          .map((e) => VoicePreset.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  List<VoicePreset> allPresets() => [
        ...BuiltInVoicePresets.all,
        ...customPresets(),
      ];

  VoicePreset? byId(String id) {
    for (final p in allPresets()) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> saveCustom(List<VoicePreset> presets) async {
    await _prefs.setString(
      _customKey,
      jsonEncode(presets.map((e) => e.toJson()).toList()),
    );
  }
}
