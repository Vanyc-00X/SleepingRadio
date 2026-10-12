import '../enums/episode_type.dart';

class Episode {
  const Episode({
    required this.id,
    required this.title,
    required this.type,
    this.script,
    this.audioPath,
    this.duration,
    this.sourceId,
    this.isFavorite = false,
    this.createdAt,
  });

  final String id;
  final String title;
  final EpisodeType type;
  final String? script;
  final String? audioPath;
  final Duration? duration;
  final String? sourceId;
  final bool isFavorite;
  final DateTime? createdAt;
}
