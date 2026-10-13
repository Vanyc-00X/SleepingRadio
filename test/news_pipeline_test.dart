import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sleeping_radio/data/news/news_episode_composer.dart';
import 'package:sleeping_radio/data/news/rss_client.dart';
import 'package:sleeping_radio/data/news/rss_models.dart';
import 'package:sleeping_radio/domain/enums/comment_length.dart';
import 'package:sleeping_radio/domain/enums/news_topic.dart';

void main() {
  group('RssClient', () {
    test('parses rss 2.0 items', () async {
      const xml = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Demo Feed</title>
    <item>
      <title>Первая новость</title>
      <link>https://example.com/1</link>
      <description>Короткое описание первой новости для теста парсера.</description>
      <pubDate>2024-01-02T10:00:00Z</pubDate>
    </item>
    <item>
      <title>Вторая новость</title>
      <description><![CDATA[<p>HTML описание второй новости.</p>]]></description>
    </item>
  </channel>
</rss>
''';
      final client = MockClient(
        (_) async => http.Response.bytes(
          utf8.encode(xml),
          200,
          headers: {'content-type': 'application/rss+xml; charset=utf-8'},
        ),
      );

      final feed = await RssClient(client: client).fetch(
        'https://example.com/rss.xml',
      );
      expect(feed.title, 'Demo Feed');
      expect(feed.items.length, 2);
      expect(feed.items.first.title, 'Первая новость');
      expect(feed.items.last.summary, contains('HTML описание'));
      expect(feed.items.last.summary.contains('<p>'), isFalse);
    });
  });

  group('NewsEpisodeComposer', () {
    final items = [
      const RssItem(
        title: 'Учёные открыли спокойный способ засыпать',
        summary:
            'Исследование показывает мягкий эффект вечернего чтения. '
            'Участники засыпали быстрее обычного.',
      ),
      const RssItem(
        title: 'Новый чип ускоряет AI-задачи',
        summary:
            'Компания представила процессор для нейросетей. '
            'Эксперты советуют не поддаваться ажиотажу.',
      ),
      const RssItem(
        title: 'Культурный фестиваль открылся вечером',
        summary: 'Гости слушали тихую музыку и читали стихи.',
      ),
    ];

    test('keeps disclaimer and facts block', () {
      final episode = NewsEpisodeComposer().compose(
        items: items,
        topics: const [NewsTopic.science, NewsTopic.technology],
        commentLength: CommentLength.short,
        factsOnly: false,
      );

      expect(episode.script, contains(NewsEpisodeComposer.disclaimer));
      expect(episode.script, contains('Факты.'));
      expect(episode.script, contains('Короткий комментарий.'));
      expect(episode.title, contains('Наука'));
      expect(episode.itemCount, 3);
    });

    test('factsOnly omits comment', () {
      final episode = NewsEpisodeComposer().compose(
        items: items,
        topics: const [NewsTopic.technology],
        commentLength: CommentLength.medium,
        factsOnly: true,
      );

      expect(episode.script, contains('Факты.'));
      expect(episode.script.contains('Короткий комментарий.'), isFalse);
    });
  });
}
