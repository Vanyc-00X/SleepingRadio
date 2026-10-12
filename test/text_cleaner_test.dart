import 'package:flutter_test/flutter_test.dart';
import 'package:sleeping_radio/data/books/fb2_book_parser.dart';
import 'package:sleeping_radio/data/books/text_cleaner.dart';
import 'dart:convert';

void main() {
  group('TextCleaner', () {
    test('strips html and entities', () {
      final text = TextCleaner.fromHtml(
        '<p>Привет&nbsp;&laquo;мир&raquo;</p><p>Вторая строка</p>',
      );
      expect(text, contains('Привет'));
      expect(text, contains('«мир»'));
      expect(text, contains('Вторая строка'));
      expect(text.contains('<'), isFalse);
    });

    test('chunks text for tts', () {
      final chunks = TextCleaner.chunkForTts(
        'Один. Два! Три? Четыре — длинное предложение для проверки нарезки текста.',
      );
      expect(chunks, isNotEmpty);
      expect(chunks.join(' '), contains('Один'));
    });
  });

  group('Fb2BookParser', () {
    test('parses simple fiction book', () {
      const xml = '''
<?xml version="1.0" encoding="utf-8"?>
<FictionBook xmlns="http://www.gribuser.ru/xml/fictionbook/2.0">
  <description>
    <title-info>
      <book-title>Тестовая книга</book-title>
      <author>
        <first-name>Иван</first-name>
        <last-name>Тестов</last-name>
      </author>
    </title-info>
  </description>
  <body>
    <section>
      <title><p>Глава 1</p></title>
      <p>Первый абзац главы.</p>
      <p>Второй абзац главы.</p>
    </section>
    <section>
      <title><p>Глава 2</p></title>
      <p>Текст второй главы.</p>
    </section>
  </body>
</FictionBook>
''';
      final parsed = Fb2BookParser().parse(utf8.encode(xml));
      expect(parsed.title, 'Тестовая книга');
      expect(parsed.author, 'Иван Тестов');
      expect(parsed.format, 'fb2');
      expect(parsed.chapters.length, 2);
      expect(parsed.chapters.first.title, 'Глава 1');
      expect(parsed.chapters.first.content, contains('Первый абзац'));
      expect(parsed.chapters.last.content, contains('второй главы'));
    });
  });
}
