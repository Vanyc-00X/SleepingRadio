import '../../domain/enums/comment_length.dart';
import '../../domain/enums/url_read_mode.dart';

class ComposedScript {
  const ComposedScript({
    required this.title,
    required this.script,
    required this.hasCommentBlock,
  });

  final String title;
  final String script;
  final bool hasCommentBlock;
}

/// Спокойный локальный композитор без обязательного LLM.
class CalmScriptComposer {
  ComposedScript compose({
    required String title,
    required String articleText,
    required UrlReadMode mode,
    required CommentLength commentLength,
    String? aiComment,
  }) {
    final cleaned = articleText.trim();
    final body = switch (mode) {
      UrlReadMode.read => cleaned,
      UrlReadMode.readWithComment => cleaned,
      UrlReadMode.summaryWithComment => _summarize(cleaned),
    };

    final includeComment =
        mode != UrlReadMode.read && commentLength != CommentLength.off;

    if (!includeComment) {
      return ComposedScript(
        title: title,
        script: body,
        hasCommentBlock: false,
      );
    }

    final comment = (aiComment != null && aiComment.trim().isNotEmpty)
        ? aiComment.trim()
        : _comment(cleaned, commentLength);
    final script = StringBuffer()
      ..writeln(body)
      ..writeln()
      ..writeln('Короткий комментарий.')
      ..writeln(comment);

    return ComposedScript(
      title: title,
      script: script.toString().trim(),
      hasCommentBlock: true,
    );
  }

  String _summarize(String text) {
    final sentences = text
        .split(RegExp(r'(?<=[.!?…])\s+'))
        .map((s) => s.trim())
        .where((s) => s.length > 40)
        .take(5)
        .toList();
    if (sentences.isEmpty) {
      return text.length <= 900 ? text : '${text.substring(0, 900).trim()}…';
    }
    final joined = sentences.join(' ');
    return 'Краткий пересказ. $joined';
  }

  String _comment(String text, CommentLength length) {
    final topicHint = _topicHint(text);
    final base =
        'Без спешки можно просто отметить: $topicHint '
        'На ночь достаточно мягко принять информацию и отпустить детали.';

    return switch (length) {
      CommentLength.off => '',
      CommentLength.short => base,
      CommentLength.medium =>
        '$base Если захочется, завтра можно вернуться к одному факту, '
            'который показался полезным — без давления и срочности.',
    };
  }

  String _topicHint(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('наук') || lower.contains('исследован')) {
      return 'в тексте есть научный или исследовательский акцент.';
    }
    if (lower.contains('технолог') || lower.contains('ии') || lower.contains('ai')) {
      return 'речь о технологиях — полезно слушать спокойно, без ажиотажа.';
    }
    if (lower.contains('политик') || lower.contains('выборы')) {
      return 'тема может быть острой; держим нейтральный тон.';
    }
    return 'главное уже сказано в самой статье.';
  }
}
