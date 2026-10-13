import 'dart:convert';
import 'dart:typed_data';

import '../../domain/models/book.dart';
import 'text_cleaner.dart';

class TxtBookParser {
  ParsedBook parse(Uint8List bytes, {String? fileName}) {
    final text = TextCleaner.normalize(_decode(bytes));
    if (text.trim().length < 20) {
      throw FormatException('В текстовом файле слишком мало содержимого.');
    }

    final title = _titleFromName(fileName) ?? _titleFromText(text);
    final chapters = _splitChapters(text);

    return ParsedBook(
      title: title,
      format: 'txt',
      chapters: chapters,
    );
  }

  String _decode(Uint8List bytes) {
    try {
      return utf8.decode(bytes);
    } catch (_) {
      return latin1.decode(bytes, allowInvalid: true);
    }
  }

  String? _titleFromName(String? fileName) {
    if (fileName == null || fileName.isEmpty) return null;
    final base = fileName.replaceAll(RegExp(r'\.[^.]+$'), '').trim();
    return base.isEmpty ? null : base;
  }

  String _titleFromText(String text) {
    final first = text
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .firstWhere((l) => l.isNotEmpty, orElse: () => 'Текст');
    return first.length > 80 ? '${first.substring(0, 80).trim()}…' : first;
  }

  List<ParsedChapter> _splitChapters(String text) {
    final parts = text.split(RegExp(r'\n{2,}'));
    if (parts.length < 3 || text.length < 4000) {
      return [ParsedChapter(title: 'Текст', content: text)];
    }

    const chunkSize = 3500;
    final chapters = <ParsedChapter>[];
    var buffer = StringBuffer();
    var index = 1;

    void flush() {
      final content = buffer.toString().trim();
      if (content.isEmpty) return;
      chapters.add(ParsedChapter(title: 'Часть $index', content: content));
      index++;
      buffer = StringBuffer();
    }

    for (final part in parts) {
      if (buffer.length + part.length > chunkSize && buffer.isNotEmpty) {
        flush();
      }
      if (buffer.isNotEmpty) buffer.writeln();
      buffer.writeln(part.trim());
    }
    flush();

    return chapters.isEmpty
        ? [ParsedChapter(title: 'Текст', content: text)]
        : chapters;
  }
}
