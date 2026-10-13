import 'package:shared_preferences/shared_preferences.dart';

import 'comfy_local_tts_client.dart';

class TtsApiKeyStore {
  TtsApiKeyStore(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'tts_api_key';
  static const _baseUrlKey = 'tts_base_url';
  static const _comfyUrlKey = 'comfy_tts_url';

  String? loadKey() {
    final value = _prefs.getString(_key);
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  Future<void> saveKey(String? key) async {
    final trimmed = key?.trim() ?? '';
    if (trimmed.isEmpty) {
      await _prefs.remove(_key);
    } else {
      await _prefs.setString(_key, trimmed);
    }
  }

  String loadBaseUrl() {
    return _prefs.getString(_baseUrlKey) ?? CloudTtsDefaults.baseUrl;
  }

  Future<void> saveBaseUrl(String? url) async {
    final trimmed = url?.trim() ?? '';
    if (trimmed.isEmpty) {
      await _prefs.remove(_baseUrlKey);
    } else {
      await _prefs.setString(_baseUrlKey, trimmed);
    }
  }

  String loadComfyUrl() {
    final saved = _prefs.getString(_comfyUrlKey)?.trim();
    if (saved != null && saved.isNotEmpty) return saved;
    if (ComfyTtsDefaults.envUrl.isNotEmpty) return ComfyTtsDefaults.envUrl;
    return ComfyLocalTtsClient.defaultBaseUrl;
  }

  Future<void> saveComfyUrl(String? url) async {
    final trimmed = url?.trim() ?? '';
    if (trimmed.isEmpty) {
      await _prefs.remove(_comfyUrlKey);
    } else {
      await _prefs.setString(_comfyUrlKey, trimmed);
    }
  }
}

abstract final class CloudTtsDefaults {
  static const baseUrl = 'https://api.openai.com/v1';

  /// Compile-time override: `--dart-define=TTS_API_KEY=...`
  static const envApiKey = String.fromEnvironment('TTS_API_KEY');
  static const envBaseUrl = String.fromEnvironment(
    'TTS_BASE_URL',
    defaultValue: baseUrl,
  );
}

abstract final class ComfyTtsDefaults {
  /// Compile-time override: `--dart-define=COMFY_TTS_URL=http://192.168.0.10:8188`
  static const envUrl = String.fromEnvironment('COMFY_TTS_URL');
}
