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
    this.duration = Duration.zero,
    this.timerEndsAt,
    this.timerPresetMinutes,
    this.playUntilEnd = false,
    this.state = PlayerState.idle,
    this.title = '',
    this.subtitle = '',
    this.bookId,
    this.chapterId,
    this.isBookMode = false,
  });

  final String? currentEpisodeId;
  final Duration position;
  final Duration duration;
  final DateTime? timerEndsAt;
  final int? timerPresetMinutes;
  final bool playUntilEnd;
  final PlayerState state;
  final String title;
  final String subtitle;
  final String? bookId;
  final String? chapterId;
  final bool isBookMode;

  bool get isPlaying =>
      state == PlayerState.playing || state == PlayerState.fadingOut;

  Duration? get timerRemaining {
    if (playUntilEnd) return null;
    final endsAt = timerEndsAt;
    if (endsAt == null) return null;
    final left = endsAt.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  PlaybackSession copyWith({
    String? currentEpisodeId,
    Duration? position,
    Duration? duration,
    DateTime? timerEndsAt,
    bool clearTimerEndsAt = false,
    int? timerPresetMinutes,
    bool clearTimerPreset = false,
    bool? playUntilEnd,
    PlayerState? state,
    String? title,
    String? subtitle,
    String? bookId,
    String? chapterId,
    bool? isBookMode,
  }) {
    return PlaybackSession(
      currentEpisodeId: currentEpisodeId ?? this.currentEpisodeId,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      timerEndsAt: clearTimerEndsAt ? null : (timerEndsAt ?? this.timerEndsAt),
      timerPresetMinutes: clearTimerPreset
          ? null
          : (timerPresetMinutes ?? this.timerPresetMinutes),
      playUntilEnd: playUntilEnd ?? this.playUntilEnd,
      state: state ?? this.state,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      bookId: bookId ?? this.bookId,
      chapterId: chapterId ?? this.chapterId,
      isBookMode: isBookMode ?? this.isBookMode,
    );
  }
}
