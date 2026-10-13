import '../../domain/models/episode.dart';

enum PodcastTargetMinutes {
  five(5),
  ten(10),
  twenty(20);

  const PodcastTargetMinutes(this.minutes);
  final int minutes;

  String get labelRu => '$minutes мин';

  /// Примерный объём спокойной русской речи.
  int get targetChars => minutes * 900;
}

class PodcastSegmentDraft {
  const PodcastSegmentDraft({
    required this.title,
    required this.body,
    this.sourceEpisodeId,
  });

  final String title;
  final String body;
  final String? sourceEpisodeId;
}

class ComposedPodcast {
  const ComposedPodcast({
    required this.title,
    required this.script,
    required this.segmentCount,
    required this.targetMinutes,
  });

  final String title;
  final String script;
  final int segmentCount;
  final int targetMinutes;
}

/// Интро → 1–5 сегментов → аутро.
class PodcastComposer {
  ComposedPodcast compose({
    required List<PodcastSegmentDraft> segments,
    required PodcastTargetMinutes target,
    String? customTitle,
  }) {
    if (segments.isEmpty) {
      throw ArgumentError('Нужен хотя бы один сегмент');
    }
    if (segments.length > 5) {
      throw ArgumentError('Не больше 5 сегментов');
    }

    final budget = target.targetChars;
    final perSegment = (budget * 0.82 / segments.length).round().clamp(
      400,
      6000,
    );

    final buffer = StringBuffer()
      ..writeln('Интро.')
      ..writeln(
        'Добрый вечер. Это короткий спокойный выпуск примерно на ${target.minutes} минут. '
        'Без спешки, мягким голосом.',
      )
      ..writeln();

    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final body = _trimToBudget(segment.body, perSegment);
      buffer
        ..writeln('Сегмент ${i + 1}.')
        ..writeln(segment.title.trim())
        ..writeln(body)
        ..writeln();
    }

    buffer
      ..writeln('Аутро.')
      ..writeln(
        'На сегодня достаточно. Можно отпустить мысли и медленно уходить ко сну. '
        'Спокойной ночи.',
      );

    final title = (customTitle?.trim().isNotEmpty ?? false)
        ? customTitle!.trim()
        : 'Вечерний выпуск · ${target.minutes} мин';

    return ComposedPodcast(
      title: title,
      script: buffer.toString().trim(),
      segmentCount: segments.length,
      targetMinutes: target.minutes,
    );
  }

  List<PodcastSegmentDraft> draftsFromEpisodes(List<Episode> episodes) {
    return episodes.map((e) {
      final body = (e.script ?? '').trim();
      return PodcastSegmentDraft(
        title: e.title,
        body: body,
        sourceEpisodeId: e.id,
      );
    }).toList();
  }

  String _trimToBudget(String text, int maxChars) {
    final cleaned = text.trim();
    if (cleaned.length <= maxChars) return cleaned;

    final cut = cleaned.substring(0, maxChars);
    final sentenceEnd = RegExp(r'[.!?…]').allMatches(cut).toList();
    if (sentenceEnd.isNotEmpty) {
      final end = sentenceEnd.last.end;
      if (end > maxChars * 0.55) {
        return cut.substring(0, end).trim();
      }
    }
    return '${cut.trim()}…';
  }
}
