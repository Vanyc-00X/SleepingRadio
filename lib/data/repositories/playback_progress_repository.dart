import 'package:shared_preferences/shared_preferences.dart';

class PlaybackProgressRepository {
  PlaybackProgressRepository(this._prefs);

  final SharedPreferences _prefs;

  static String _key(String mediaId) => 'playback_pos_$mediaId';
  static String _charKey(String mediaId) => 'playback_char_$mediaId';

  Future<void> save({
    required String mediaId,
    required Duration position,
  }) async {
    await _prefs.setInt(_key(mediaId), position.inMilliseconds);
  }

  Future<Duration> load(String mediaId) async {
    final ms = _prefs.getInt(_key(mediaId));
    if (ms == null || ms < 0) return Duration.zero;
    return Duration(milliseconds: ms);
  }

  Future<void> saveCharOffset({
    required String mediaId,
    required int charOffset,
  }) async {
    await _prefs.setInt(_charKey(mediaId), charOffset.clamp(0, 1 << 30));
  }

  Future<int> loadCharOffset(String mediaId) async {
    final v = _prefs.getInt(_charKey(mediaId));
    if (v == null || v < 0) return 0;
    return v;
  }

  Future<void> clearCharOffset(String mediaId) async {
    await _prefs.remove(_charKey(mediaId));
  }
}
