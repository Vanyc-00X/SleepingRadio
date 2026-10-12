enum PlayerState {
  idle,
  loading,
  playing,
  paused,
  fadingOut,
  completed;

  String get storageValue => name;

  static PlayerState fromStorage(String value) {
    return PlayerState.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PlayerState.idle,
    );
  }
}

class PlaybackSession {
  const PlaybackSession({
    this.currentEpisodeId,
    this.position = Duration.zero,
    this.timerEndsAt,
    this.playUntilEnd = false,
    this.state = PlayerState.idle,
  });

  final String? currentEpisodeId;
  final Duration position;
  final DateTime? timerEndsAt;
  final bool playUntilEnd;
  final PlayerState state;
}
