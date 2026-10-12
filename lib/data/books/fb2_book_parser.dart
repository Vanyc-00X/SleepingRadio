import 'dart:convert';
import 'dart:typed_data';

import 'package:xml/xml.dart';

import '../../domain/models/book.dart';
import 'text_cleaner.dart';

class Fb2BookParser {
  ParsedBook parse(Uint8List bytes) {
    final xmlText = _decode(bytes);
    final document = XmlDocument.parse(xmlText);
    final root = document.rootElement;

    final titleInfo = root.findAllElements('title-info').firstOrNull;
    final bookTitle = titleInfo
            ?.findElements('book-title')
            .map((e) => e.innerText.trim())
            .firstWhere((t) => t.isNotEmpty, orElse: () => '') ??
        '';
    final author = _readAuthor(titleInfo);

    final bodies = root
        .findAllElements('body')
        .where((body) => body.getAttribute('name') == null)
        .toList();

    final chapters = <ParsedChapter>[];
    for (final body in bodies) {
      final sections = body.findElements('section').toList();
      if (sections.isEmpty) {
        final text = TextCleaner.normalize(_sectionText(body));
        if (text.isNotEmpty) {
          chapters.add(ParsedChapter(title: 'Текст', content: text));
        }
        continue;
      }
      _collectSections(sections, chapters);
    }

    if (chapters.isEmpty) {
      throw const FormatException('В FB2 не найдено текста');
    }

    return ParsedBook(
      title: bookTitle.isEmpty ? 'Без названия' : bookTitle,
      author: author,
      format: 'fb2',
      chapters: chapters,
    );
  }

  void _collectSections(List<XmlElement> sections, List<ParsedChapter> out) {
    for (final section in sections) {
      final nested = section.findElements('section').toList();
      final title = _sectionTitle(section);
      final ownText = TextCleaner.normalize(_sectionOwnText(section));

      if (ownText.isNotEmpty) {
        out.add(
          ParsedChapter(
            title: title.isEmpty ? 'Глава ${out.length + 1}' : title,
            content: ownText,
          ),
        );
      }

      if (nested.isNotEmpty) {
        _collectSections(nested, out);
      } else if (ownText.isEmpty && title.isNotEmpty) {
        // Пустая секция-заголовок без текста — пропускаем.
      }
    }
  }

  String _sectionTitle(XmlElement section) {
    final titleNode = section.findElements('title').firstOrNull;
    if (titleNode == null) return '';
    return TextCleaner.normalize(
      titleNode.descendants
          .whereType<XmlText>()
          .map((t) => t.value)
          .join(' '),
    );
  }

  String _sectionOwnText(XmlElement section) {
    final buffer = StringBuffer();
    for (final child in section.children.whereType<XmlElement>()) {
      final name = child.name.local.toLowerCase();
      if (name == 'section' || name == 'title' || name == 'epigraph') {
        continue;
      }
      if (name == 'p' || name == 'v' || name == 'text-author' || name == 'subtitle') {
        buffer.writeln(child.innerText);
      } else if (name == 'empty-line') {
        buffer.writeln();
      } else if (name == 'poem' || name == 'cite' || name == 'stanza') {
        buffer.writeln(child.innerText);
      }
    }
    return buffer.toString();
  }

  String _sectionText(XmlElement section) {
    final buffer = StringBuffer();
    for (final p in section.findAllElements('p')) {
      buffer.writeln(p.innerText);
    }
    return buffer.toString();
  }

  String? _readAuthor(XmlElement? titleInfo) {
    if (titleInfo == null) return null;
    final author = titleInfo.findElements('author').firstOrNull;
    if (author == null) return null;
    final parts = [
      author.findElements('first-name').firstOrNull?.innerText.trim(),
      author.findElements('middle-name').firstOrNull?.innerText.trim(),
      author.findElements('last-name').firstOrNull?.innerText.trim(),
      author.findElements('nickname').firstOrNull?.innerText.trim(),
    ].whereType<String>().where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    return parts.join(' ');
  }

  String _decode(Uint8List bytes) {
    // FB2 часто в UTF-8; пробуем utf8, затем latin1 как fallback.
    try {
      final text = utf8.decode(bytes);
      return text.replaceFirst(RegExp(r'^.*?<FictionBook', dotAll: true), '<FictionBook');
    } catch (_) {
      final text = latin1.decode(bytes);
      return text.replaceFirst(RegExp(r'^.*?<FictionBook', dotAll: true), '<FictionBook');
    }
  }
}
