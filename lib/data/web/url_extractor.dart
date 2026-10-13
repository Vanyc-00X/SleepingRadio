import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

class ExtractedArticle {
  const ExtractedArticle({
    required this.title,
    required this.text,
    required this.url,
  });

  final String title;
  final String text;
  final String url;
}

class UrlExtractException implements Exception {
  UrlExtractException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Reader-mode извлечение основного текста страницы.
class UrlExtractor {
  UrlExtractor({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<ExtractedArticle> extract(String rawUrl) async {
    final uri = _normalizeUrl(rawUrl);
    late final http.Response response;
    try {
      response = await _client
          .get(
            uri,
            headers: const {
              'User-Agent':
                  'SleepingRadio/1.0 (reader; +https://example.local)',
              'Accept': 'text/html,application/xhtml+xml',
            },
          )
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      throw UrlExtractException(
        'Не удалось открыть страницу. Проверьте ссылку и интернет.',
      );
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw UrlExtractException(
        'Страница закрыта или требует доступ. Paywall/private контент не озвучиваем.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UrlExtractException(
        'Не удалось прочитать страницу (код ${response.statusCode}).',
      );
    }

    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.contains('html') &&
        !contentType.contains('xml') &&
        contentType.isNotEmpty) {
      throw UrlExtractException(
        'По ссылке не HTML-страница. Откройте обычную статью.',
      );
    }

    final document = html_parser.parse(response.body);
    _removeNoise(document);

    final title = _pickTitle(document);
    final text = _pickBody(document);

    if (text.trim().length < 80) {
      throw UrlExtractException(
        'Не удалось прочитать страницу: мало текста или сложная вёрстка.',
      );
    }

    return ExtractedArticle(title: title, text: text, url: uri.toString());
  }

  Uri _normalizeUrl(String raw) {
    var value = raw.trim();
    if (value.isEmpty) {
      throw UrlExtractException('Вставьте ссылку на статью.');
    }
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      value = 'https://$value';
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasAuthority) {
      throw UrlExtractException('Похоже, ссылка некорректная.');
    }
    return uri;
  }

  void _removeNoise(Document document) {
    for (final tag in [
      'script',
      'style',
      'noscript',
      'svg',
      'iframe',
      'nav',
      'footer',
      'header',
      'aside',
      'form',
    ]) {
      document.querySelectorAll(tag).forEach((e) => e.remove());
    }
  }

  String _pickTitle(Document document) {
    final og = document
        .querySelector('meta[property="og:title"]')
        ?.attributes['content']
        ?.trim();
    if (og != null && og.isNotEmpty) return og;

    final h1 = document.querySelector('h1')?.text.trim();
    if (h1 != null && h1.isNotEmpty) return h1;

    final title = document.querySelector('title')?.text.trim();
    if (title != null && title.isNotEmpty) return title;

    return 'Статья без названия';
  }

  String _pickBody(Document document) {
    final candidates = <Element?>[
      document.querySelector('article'),
      document.querySelector('main'),
      document.querySelector('[role="main"]'),
      document.querySelector('.post-content'),
      document.querySelector('.article-content'),
      document.querySelector('#content'),
      document.querySelector('body'),
    ];

    for (final node in candidates) {
      if (node == null) continue;
      final text = _elementToText(node);
      if (text.length >= 80) return text;
    }
    return '';
  }

  String _elementToText(Element root) {
    final buffer = StringBuffer();
    for (final p in root.querySelectorAll('p, h1, h2, h3, li, blockquote')) {
      final line = p.text.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (line.isEmpty) continue;
      if (line.length < 3) continue;
      buffer.writeln(line);
      buffer.writeln();
    }
    var text = buffer.toString().trim();
    if (text.length < 80) {
      text = root.text.replaceAll(RegExp(r'\s+'), ' ').trim();
    }
    return text;
  }

  void close() => _client.close();
}
