abstract final class TextCleaner {
  static final _tagRe = RegExp(r'<[^>]+>', multiLine: true);
  static final _entityRe = RegExp(r'&(#x?[0-9a-fA-F]+|\w+);');
  static final _wsRe = RegExp(r'[ \t]+\n');
  static final _multiNl = RegExp(r'\n{3,}');
  static final _multiSpace = RegExp(r'[ \t]{2,}');

  static String fromHtml(String? html) {
    if (html == null || html.trim().isEmpty) return '';
    var text = html
        .replaceAll(RegExp(r'<script[\s\S]*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<style[\s\S]*?</style>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<(br|BR)\s*/?>'), '\n')
        .replaceAll(RegExp(r'</(p|div|h[1-6]|li|tr)>', caseSensitive: false), '\n')
        .replaceAll(_tagRe, '')
        .replaceAllMapped(_entityRe, _decodeEntity);
    return normalize(text);
  }

  static String normalize(String text) {
    return text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll(_wsRe, '\n')
        .replaceAll(_multiSpace, ' ')
        .replaceAll(_multiNl, '\n\n')
        .trim();
  }

  static String _decodeEntity(Match m) {
    final body = m.group(1)!;
    return switch (body) {
      'nbsp' => ' ',
      'amp' => '&',
      'lt' => '<',
      'gt' => '>',
      'quot' => '"',
      'apos' || '#39' => "'",
      'mdash' || 'ndash' => '—',
      'laquo' => '«',
      'raquo' => '»',
      _ => _decodeNumeric(body) ?? m.group(0)!,
    };
  }

  static String? _decodeNumeric(String body) {
    if (!body.startsWith('#')) return null;
    final raw = body.substring(1);
    final code = raw.startsWith('x') || raw.startsWith('X')
        ? int.tryParse(raw.substring(1), radix: 16)
        : int.tryParse(raw);
    if (code == null) return null;
    return String.fromCharCode(code);
  }

  /// Режет текст на фразы для TTS (~[minLen]–[maxLen] символов).
  static List<String> chunkForTts(
    String text, {
    int minLen = 80,
    int maxLen = 280,
  }) {
    final cleaned = normalize(text);
    if (cleaned.isEmpty) return const [];

    final parts = <String>[];
    final sentences = cleaned.split(RegExp(r'(?<=[.!?…»])\s+'));
    final buffer = StringBuffer();

    void flush() {
      final s = buffer.toString().trim();
      if (s.isNotEmpty) parts.add(s);
      buffer.clear();
    }

    for (final sentence in sentences) {
      if (sentence.length > maxLen) {
        flush();
        for (var i = 0; i < sentence.length; i += maxLen) {
          final end = (i + maxLen).clamp(0, sentence.length);
          parts.add(sentence.substring(i, end).trim());
        }
        continue;
      }
      if (buffer.length + sentence.length + 1 > maxLen && buffer.length >= minLen) {
        flush();
      }
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(sentence.trim());
    }
    flush();
    return parts.where((p) => p.isNotEmpty).toList();
  }
}
