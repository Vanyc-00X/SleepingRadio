class ListenHistoryEntry {
  const ListenHistoryEntry({
    required this.id,
    required this.episodeId,
    required this.startedAt,
    this.endedAt,
    this.listened = Duration.zero,
  });

  final String id;
  final String episodeId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final Duration listened;
}
