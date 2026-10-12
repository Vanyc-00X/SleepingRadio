import 'dart:typed_data';

import 'package:epubx/epubx.dart';

import '../../domain/models/book.dart';
import 'text_cleaner.dart';

class EpubBookParser {
  Future<ParsedBook> parse(Uint8List bytes) async {
    final epub = await EpubReader.readBook(bytes);
    final chapters = <ParsedChapter>[];
    _collectChapters(epub.Chapters ?? const [], chapters);

    if (chapters.isEmpty) {
      throw const FormatException('В EPUB не найдено глав с текстом');
    }

    final title = (epub.Title ?? '').trim().isEmpty
        ? 'Без названия'
        : epub.Title!.trim();
    final author = (epub.Author ?? '').trim();

    return ParsedBook(
      title: title,
      author: author.isEmpty ? null : author,
      format: 'epub',
      chapters: chapters,
    );
  }

  void _collectChapters(List<EpubChapter> source, List<ParsedChapter> out) {
    for (final chapter in source) {
      final text = TextCleaner.fromHtml(chapter.HtmlContent);
      final title = (chapter.Title ?? '').trim();
      if (text.isNotEmpty) {
        out.add(
          ParsedChapter(
            title: title.isEmpty ? 'Глава ${out.length + 1}' : title,
            content: text,
          ),
        );
      }
      final subs = chapter.SubChapters;
      if (subs != null && subs.isNotEmpty) {
        _collectChapters(subs, out);
      }
    }
  }
}
