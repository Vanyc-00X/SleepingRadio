import 'package:shared_preferences/shared_preferences.dart';

class PlaybackProgressRepository {
  PlaybackProgressRepository(this._prefs);

  final SharedPreferences _prefs;

  static String _key(String mediaId) => 'playback_pos_$mediaId';

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
}
