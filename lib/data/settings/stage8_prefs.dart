import 'package:shared_preferences/shared_preferences.dart';

/// Настройки этапа 8 (без миграции Drift).
class Stage8Prefs {
  Stage8Prefs(this._prefs);

  final SharedPreferences _prefs;

  static const _ambientEnabled = 's8_ambient_enabled';
  static const _ambientVolume = 's8_ambient_volume';
  static const _ollamaEnabled = 's8_ollama_enabled';
  static const _ollamaUrl = 's8_ollama_url';
  static const _ollamaModel = 's8_ollama_model';

  static const defaultOllamaUrl = 'http://127.0.0.1:11434';
  static const defaultOllamaModel = 'llama3.2';

  bool get ambientEnabled => _prefs.getBool(_ambientEnabled) ?? false;

  Future<void> setAmbientEnabled(bool value) =>
      _prefs.setBool(_ambientEnabled, value);

  /// Тихая подложка: 0.04–0.22.
  double get ambientVolume {
    final v = _prefs.getDouble(_ambientVolume) ?? 0.12;
    return v.clamp(0.04, 0.22);
  }

  Future<void> setAmbientVolume(double value) =>
      _prefs.setDouble(_ambientVolume, value.clamp(0.04, 0.22));

  bool get ollamaEnabled => _prefs.getBool(_ollamaEnabled) ?? false;

  Future<void> setOllamaEnabled(bool value) =>
      _prefs.setBool(_ollamaEnabled, value);

  String get ollamaUrl {
    final saved = _prefs.getString(_ollamaUrl)?.trim();
    if (saved != null && saved.isNotEmpty) return saved;
    return defaultOllamaUrl;
  }

  Future<void> setOllamaUrl(String? url) async {
    final trimmed = url?.trim() ?? '';
    if (trimmed.isEmpty) {
      await _prefs.remove(_ollamaUrl);
    } else {
      await _prefs.setString(_ollamaUrl, trimmed);
    }
  }

  String get ollamaModel {
    final saved = _prefs.getString(_ollamaModel)?.trim();
    if (saved != null && saved.isNotEmpty) return saved;
    return defaultOllamaModel;
  }

  Future<void> setOllamaModel(String? model) async {
    final trimmed = model?.trim() ?? '';
    if (trimmed.isEmpty) {
      await _prefs.remove(_ollamaModel);
    } else {
      await _prefs.setString(_ollamaModel, trimmed);
    }
  }

  Map<String, Object?> toJson() => {
    'ambientEnabled': ambientEnabled,
    'ambientVolume': ambientVolume,
    'ollamaEnabled': ollamaEnabled,
    'ollamaUrl': ollamaUrl,
    'ollamaModel': ollamaModel,
  };

  Future<void> applyJson(Map<String, dynamic> json) async {
    if (json['ambientEnabled'] is bool) {
      await setAmbientEnabled(json['ambientEnabled'] as bool);
    }
    if (json['ambientVolume'] is num) {
      await setAmbientVolume((json['ambientVolume'] as num).toDouble());
    }
    if (json['ollamaEnabled'] is bool) {
      await setOllamaEnabled(json['ollamaEnabled'] as bool);
    }
    if (json['ollamaUrl'] is String) {
      await setOllamaUrl(json['ollamaUrl'] as String);
    }
    if (json['ollamaModel'] is String) {
      await setOllamaModel(json['ollamaModel'] as String);
    }
  }
}
