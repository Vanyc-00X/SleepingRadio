import 'dart:convert';
import 'dart:typed_data';

import '../../domain/models/book.dart';
import 'text_cleaner.dart';

/// Простой extractor для текстовых PDF без сложной вёрстки.
class SimplePdfTextExtractor {
  ParsedBook parse(Uint8List bytes, {String? fileName}) {
    final raw = latin1.decode(bytes, allowInvalid: true);
    final extracted = _extract(raw);
    final text = TextCleaner.normalize(extracted);

    if (text.trim().length < 40) {
      throw FormatException(
        'Не удалось прочитать PDF. Сохраните файл как .txt или выберите простой текстовый PDF.',
      );
    }

    final title = (fileName ?? '')
        .replaceAll(RegExp(r'\.[^.]+$'), '')
        .trim();

    return ParsedBook(
      title: title.isEmpty ? _titleFromText(text) : title,
      format: 'pdf',
      chapters: [ParsedChapter(title: 'Текст', content: text)],
    );
  }

  String _extract(String raw) {
    final buffer = StringBuffer();

    // Literal strings: (Hello) Tj / TJ
    final literal = RegExp(r'\((?:\\.|[^\\)])*\)');
    for (final match in literal.allMatches(raw)) {
      final chunk = _unescapePdfString(match.group(0)!);
      if (_looksLikeText(chunk)) {
        buffer.write(chunk);
        buffer.write(' ');
      }
    }

    // Hex strings: <FEFF...>
    final hex = RegExp(r'<([0-9A-Fa-f \r\n]+)>');
    for (final match in hex.allMatches(raw)) {
      final decoded = _decodeHex(match.group(1)!);
      if (_looksLikeText(decoded)) {
        buffer.write(decoded);
        buffer.write(' ');
      }
    }

    return buffer.toString();
  }

  String _unescapePdfString(String raw) {
    var s = raw;
    if (s.startsWith('(') && s.endsWith(')')) {
      s = s.substring(1, s.length - 1);
    }
    return s
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\r', '\r')
        .replaceAll(r'\t', '\t')
        .replaceAll(r'\(', '(')
        .replaceAll(r'\)', ')')
        .replaceAll(r'\\', r'\');
  }

  String _decodeHex(String hex) {
    final cleaned = hex.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length < 4 || cleaned.length.isOdd) return '';
    final bytes = <int>[];
    for (var i = 0; i < cleaned.length; i += 2) {
      bytes.add(int.parse(cleaned.substring(i, i + 2), radix: 16));
    }
    if (bytes.length >= 2 && bytes[0] == 0xfe && bytes[1] == 0xff) {
      final codeUnits = <int>[];
      for (var i = 2; i + 1 < bytes.length; i += 2) {
        codeUnits.add((bytes[i] << 8) | bytes[i + 1]);
      }
      return String.fromCharCodes(codeUnits);
    }
    try {
      return utf8.decode(bytes, allowMalformed: true);
    } catch (_) {
      return latin1.decode(bytes, allowInvalid: true);
    }
  }

  bool _looksLikeText(String value) {
    final trimmed = value.trim();
    if (trimmed.length < 2) return false;
    final letters = RegExp(r'[A-Za-zА-Яа-яЁё]').allMatches(trimmed).length;
    return letters >= 2;
  }

  String _titleFromText(String text) {
    final first = text
        .split(RegExp(r'\s+'))
        .take(8)
        .join(' ')
        .trim();
    return first.isEmpty ? 'PDF документ' : first;
  }
}
