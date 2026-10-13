import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import 'rss_models.dart';

class RssFetchException implements Exception {
  RssFetchException(this.message);
  final String message;

  @override
  String toString() => message;
}

class RssClient {
  RssClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<RssFeed> fetch(String feedUrl) async {
    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(feedUrl),
            headers: const {
              'User-Agent': 'SleepingRadio/1.0 (news; +https://example.local)',
              'Accept': 'application/rss+xml, application/xml, text/xml, */*',
            },
          )
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      throw RssFetchException(
        'Не удалось загрузить ленту новостей. Проверьте интернет.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RssFetchException(
        'Лента недоступна (код ${response.statusCode}).',
      );
    }

    try {
      return _parse(response.body);
    } catch (error) {
      if (error is RssFetchException) rethrow;
      throw RssFetchException('Не удалось разобрать RSS-ленту.');
    }
  }

  RssFeed _parse(String body) {
    final document = XmlDocument.parse(body);
    final channels = document.findAllElements('channel').toList();
    if (channels.isNotEmpty) {
      return _parseRss2(channels.first);
    }

    final feeds = document.findAllElements('feed').toList();
    if (feeds.isNotEmpty) {
      return _parseAtom(feeds.first);
    }

    throw RssFetchException('Неизвестный формат ленты.');
  }

  RssFeed _parseRss2(XmlElement channel) {
    final title = _text(channel, 'title') ?? 'Новости';
    final items = <RssItem>[];
    for (final item in channel.findElements('item')) {
      final description = _text(item, 'description') ?? '';
      String? encoded;
      for (final child in item.childElements) {
        if (child.name.local == 'encoded') {
          encoded = child.innerText.trim();
          break;
        }
      }
      final content = (encoded != null && encoded.isNotEmpty)
          ? encoded
          : description;
      final itemTitle = (_text(item, 'title') ?? 'Без заголовка').trim();
      if (itemTitle.isEmpty) continue;
      items.add(
        RssItem(
          title: itemTitle,
          summary: _stripHtml(content),
          link: _text(item, 'link')?.trim(),
          publishedAt: _parseDate(_text(item, 'pubDate')),
        ),
      );
    }

    return RssFeed(title: title, items: items);
  }

  RssFeed _parseAtom(XmlElement feed) {
    final title = _text(feed, 'title') ?? 'Новости';
    final items = <RssItem>[];
    for (final entry in feed.findElements('entry')) {
      final summary =
          _text(entry, 'summary') ?? _text(entry, 'content') ?? '';
      String? link;
      for (final node in entry.findElements('link')) {
        final href = node.getAttribute('href');
        if (href != null && href.isNotEmpty) {
          link = href;
          break;
        }
      }
      final itemTitle = (_text(entry, 'title') ?? 'Без заголовка').trim();
      if (itemTitle.isEmpty) continue;
      items.add(
        RssItem(
          title: itemTitle,
          summary: _stripHtml(summary),
          link: link?.trim(),
          publishedAt:
              _parseDate(_text(entry, 'updated')) ??
              _parseDate(_text(entry, 'published')),
        ),
      );
    }

    return RssFeed(title: title, items: items);
  }

  String? _text(XmlElement parent, String name) {
    final local = name.contains(':') ? name.split(':').last : name;
    for (final child in parent.childElements) {
      if (child.name.local == local) {
        final value = child.innerText.trim();
        if (value.isNotEmpty) return value;
      }
    }
    return null;
  }

  String _stripHtml(String raw) {
    return raw
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  void close() => _client.close();
}
