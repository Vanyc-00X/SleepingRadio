import '../../domain/enums/comment_length.dart';
import '../../domain/enums/news_topic.dart';
import 'rss_models.dart';

class ComposedNewsEpisode {
  const ComposedNewsEpisode({
    required this.title,
    required this.script,
    required this.itemCount,
  });

  final String title;
  final String script;
  final int itemCount;
}

/// Локальный пайплайн: факты → (опционально) комментарий. Без LLM.
class NewsEpisodeComposer {
  static const disclaimer =
      'Сводка может содержать неточности; это не официальный СМИ-продукт.';

  ComposedNewsEpisode compose({
    required List<RssItem> items,
    required List<NewsTopic> topics,
    required CommentLength commentLength,
    required bool factsOnly,
    String? aiComment,
  }) {
    final selected = items.take(8).toList();
    if (selected.isEmpty) {
      throw StateError('Нет материалов для выпуска');
    }

    final topicLabel = topics.isEmpty
        ? 'новости'
        : topics.map((t) => t.labelRu).join(', ');
    final title = 'Вечерняя сводка · $topicLabel';

    final buffer = StringBuffer()
      ..writeln(disclaimer)
      ..writeln()
      ..writeln('Факты.')
      ..writeln();

    for (var i = 0; i < selected.length; i++) {
      final item = selected[i];
      final fact = _factLine(item);
      buffer.writeln('${i + 1}. ${item.title.trim()}.');
      if (fact.isNotEmpty) {
        buffer.writeln(fact);
      }
      buffer.writeln();
    }

    if (!factsOnly && commentLength != CommentLength.off) {
      final comment = (aiComment != null && aiComment.trim().isNotEmpty)
          ? aiComment.trim()
          : _comment(selected, commentLength);
      buffer
        ..writeln('Короткий комментарий.')
        ..writeln(comment);
    }

    return ComposedNewsEpisode(
      title: title,
      script: buffer.toString().trim(),
      itemCount: selected.length,
    );
  }

  String _factLine(RssItem item) {
    final summary = item.summary.trim();
    if (summary.isEmpty) return '';
    final sentence = summary
        .split(RegExp(r'(?<=[.!?…])\s+'))
        .map((s) => s.trim())
        .where((s) => s.length > 20)
        .take(2)
        .join(' ');
    if (sentence.isEmpty) {
      return summary.length <= 220
          ? summary
          : '${summary.substring(0, 220).trim()}…';
    }
    return sentence.length <= 280
        ? sentence
        : '${sentence.substring(0, 280).trim()}…';
  }

  String _comment(List<RssItem> items, CommentLength length) {
    final base =
        'На сегодня достаточно короткой картины дня. '
        'Можно отложить детали и просто отметить общий фон — без спешки.';
    final techHint = items.any(
      (i) =>
          i.title.toLowerCase().contains('ai') ||
          i.summary.toLowerCase().contains('технолог'),
    );
    final scienceHint = items.any(
      (i) =>
          i.title.toLowerCase().contains('наук') ||
          i.summary.toLowerCase().contains('space') ||
          i.summary.toLowerCase().contains('research'),
    );

    final hint = scienceHint
        ? ' Если мелькнула наука или космос — пусть это будет лёгким любопытством, а не задачей.'
        : techHint
        ? ' Технологические заголовки лучше слушать спокойно, без ажиотажа.'
        : '';

    return switch (length) {
      CommentLength.off => '',
      CommentLength.short => '$base$hint',
      CommentLength.medium =>
        '$base$hint Завтра можно вернуться к одной теме, которая показалась полезной — без давления.',
    };
  }
}
