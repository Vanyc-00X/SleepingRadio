import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sleeping_radio/data/web/calm_script_composer.dart';
import 'package:sleeping_radio/data/web/url_extractor.dart';
import 'package:sleeping_radio/domain/enums/comment_length.dart';
import 'package:sleeping_radio/domain/enums/url_read_mode.dart';

void main() {
  group('UrlExtractor', () {
    test('extracts title and paragraphs from article html', () async {
      final client = MockClient((request) async {
        return http.Response(
          '''
<!DOCTYPE html>
<html>
<head>
  <meta property="og:title" content="Тихая статья" />
  <title>Ignore</title>
</head>
<body>
  <nav>Меню</nav>
  <article>
    <h1>Тихая статья</h1>
    <p>Первый абзац достаточно длинный, чтобы пройти порог извлечения текста.</p>
    <p>Второй абзац продолжает мысль и добавляет ещё немного спокойного содержания.</p>
    <p>Третий абзац завершает короткий фрагмент для reader-mode теста экстрактора.</p>
  </article>
  <footer>Подвал</footer>
</body>
</html>
''',
          200,
          headers: {'content-type': 'text/html; charset=utf-8'},
        );
      });

      final article = await UrlExtractor(client: client).extract(
        'example.com/post',
      );
      expect(article.title, 'Тихая статья');
      expect(article.text, contains('Первый абзац'));
      expect(article.text, contains('Третий абзац'));
      expect(article.url, startsWith('https://'));
    });

    test('maps paywall status to friendly error', () async {
      final client = MockClient(
        (_) async => http.Response('denied', 403),
      );
      expect(
        () => UrlExtractor(client: client).extract('https://paywall.example'),
        throwsA(
          isA<UrlExtractException>().having(
            (e) => e.message,
            'message',
            contains('Paywall'),
          ),
        ),
      );
    });

    test('rejects empty url', () async {
      expect(
        () => UrlExtractor().extract('   '),
        throwsA(isA<UrlExtractException>()),
      );
    });
  });

  group('CalmScriptComposer', () {
    const sample =
        'Исследование показывает, что вечернее чтение снижает напряжение. '
        'Учёные отмечают мягкий эффект на засыпание. '
        'Технологии тоже могут помогать, если не перегружать мозг. '
        'Политика здесь не нужна. '
        'Достаточно короткого спокойного фрагмента для теста.';

    test('read mode keeps body without comment', () {
      final result = CalmScriptComposer().compose(
        title: 'Заголовок',
        articleText: sample,
        mode: UrlReadMode.read,
        commentLength: CommentLength.short,
      );
      expect(result.script, sample);
      expect(result.hasCommentBlock, isFalse);
    });

    test('readWithComment appends comment block', () {
      final result = CalmScriptComposer().compose(
        title: 'Заголовок',
        articleText: sample,
        mode: UrlReadMode.readWithComment,
        commentLength: CommentLength.short,
      );
      expect(result.script, contains(sample));
      expect(result.script, contains('Короткий комментарий.'));
      expect(result.hasCommentBlock, isTrue);
    });

    test('summaryWithComment compresses and comments', () {
      final result = CalmScriptComposer().compose(
        title: 'Заголовок',
        articleText: sample,
        mode: UrlReadMode.summaryWithComment,
        commentLength: CommentLength.medium,
      );
      expect(result.script, startsWith('Краткий пересказ.'));
      expect(result.script, contains('Короткий комментарий.'));
      expect(result.hasCommentBlock, isTrue);
    });
  });
}
