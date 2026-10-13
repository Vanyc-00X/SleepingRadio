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

/// Режим умного таймера сна.
enum SleepTimerMode {
  /// Обычный обратный отсчёт (с fade).
  countdown,

  /// Остановить после текущего чанка TTS / конца трека.
  afterSegment,

  /// Остановить в конце текущей главы / скрипта.
  afterChapter,
}

class PlaybackSession {
  const PlaybackSession({
    this.currentEpisodeId,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.timerEndsAt,
    this.timerPresetMinutes,
    this.playUntilEnd = false,
    this.timerMode = SleepTimerMode.countdown,
    this.state = PlayerState.idle,
    this.title = '',
    this.subtitle = '',
    this.bookId,
    this.chapterId,
    this.isBookMode = false,
    this.scriptText = '',
    this.chunks = const [],
    this.chunkStarts = const [],
    this.currentChunkIndex = 0,
    this.charOffset = 0,
    this.voiceId = 'piper_denis',
    this.voiceVolume = 1.0,
    this.ambientVolume = 0.12,
    this.autoAdvanceChapters = true,
  });

  final String? currentEpisodeId;
  final Duration position;
  final Duration duration;
  final DateTime? timerEndsAt;
  final int? timerPresetMinutes;
  final bool playUntilEnd;
  final SleepTimerMode timerMode;
  final PlayerState state;
  final String title;
  final String subtitle;
  final String? bookId;
  final String? chapterId;
  final bool isBookMode;

  /// Полный текст озвучки (для караоке).
  final String scriptText;
  final List<String> chunks;
  final List<int> chunkStarts;
  final int currentChunkIndex;
  final int charOffset;
  final String voiceId;
  final double voiceVolume;
  final double ambientVolume;
  final bool autoAdvanceChapters;

  bool get isPlaying =>
      state == PlayerState.playing || state == PlayerState.fadingOut;

  bool get hasKaraoke => isBookMode && scriptText.isNotEmpty && chunks.isNotEmpty;

  Duration? get timerRemaining {
    if (playUntilEnd ||
        timerMode == SleepTimerMode.afterChapter ||
        timerMode == SleepTimerMode.afterSegment) {
      return null;
    }
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
    SleepTimerMode? timerMode,
    PlayerState? state,
    String? title,
    String? subtitle,
    String? bookId,
    bool clearBookId = false,
    String? chapterId,
    bool clearChapterId = false,
    bool? isBookMode,
    String? scriptText,
    List<String>? chunks,
    List<int>? chunkStarts,
    int? currentChunkIndex,
    int? charOffset,
    String? voiceId,
    double? voiceVolume,
    double? ambientVolume,
    bool? autoAdvanceChapters,
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
      timerMode: timerMode ?? this.timerMode,
      state: state ?? this.state,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      bookId: clearBookId ? null : (bookId ?? this.bookId),
      chapterId: clearChapterId ? null : (chapterId ?? this.chapterId),
      isBookMode: isBookMode ?? this.isBookMode,
      scriptText: scriptText ?? this.scriptText,
      chunks: chunks ?? this.chunks,
      chunkStarts: chunkStarts ?? this.chunkStarts,
      currentChunkIndex: currentChunkIndex ?? this.currentChunkIndex,
      charOffset: charOffset ?? this.charOffset,
      voiceId: voiceId ?? this.voiceId,
      voiceVolume: voiceVolume ?? this.voiceVolume,
      ambientVolume: ambientVolume ?? this.ambientVolume,
      autoAdvanceChapters: autoAdvanceChapters ?? this.autoAdvanceChapters,
    );
  }
}
