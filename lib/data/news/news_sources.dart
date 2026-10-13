import '../../domain/enums/news_topic.dart';

class NewsSource {
  const NewsSource({
    required this.id,
    required this.label,
    required this.feedUrl,
    required this.topic,
  });

  final String id;
  final String label;
  final String feedUrl;
  final NewsTopic topic;
}

/// 1–2 публичных RSS на тему (MVP).
class NewsSources {
  static const List<NewsSource> all = [
    NewsSource(
      id: 'bbc_tech',
      label: 'BBC Technology',
      feedUrl: 'https://feeds.bbci.co.uk/news/technology/rss.xml',
      topic: NewsTopic.technology,
    ),
    NewsSource(
      id: 'hn',
      label: 'Hacker News',
      feedUrl: 'https://hnrss.org/frontpage',
      topic: NewsTopic.technology,
    ),
    NewsSource(
      id: 'bbc_science',
      label: 'BBC Science',
      feedUrl:
          'https://feeds.bbci.co.uk/news/science_and_environment/rss.xml',
      topic: NewsTopic.science,
    ),
    NewsSource(
      id: 'nasa',
      label: 'NASA Breaking News',
      feedUrl: 'https://www.nasa.gov/rss/dyn/breaking_news.rss',
      topic: NewsTopic.science,
    ),
    NewsSource(
      id: 'bbc_world',
      label: 'BBC World',
      feedUrl: 'https://feeds.bbci.co.uk/news/world/rss.xml',
      topic: NewsTopic.politics,
    ),
    NewsSource(
      id: 'bbc_culture',
      label: 'BBC Culture',
      feedUrl:
          'https://feeds.bbci.co.uk/news/entertainment_and_arts/rss.xml',
      topic: NewsTopic.culture,
    ),
    NewsSource(
      id: 'bbc_sport',
      label: 'BBC Sport',
      feedUrl: 'https://feeds.bbci.co.uk/sport/rss.xml',
      topic: NewsTopic.sport,
    ),
    NewsSource(
      id: 'bbc_uk',
      label: 'BBC UK',
      feedUrl: 'https://feeds.bbci.co.uk/news/uk/rss.xml',
      topic: NewsTopic.local,
    ),
  ];

  static List<NewsSource> forTopics(Iterable<NewsTopic> topics) {
    final set = topics.toSet();
    if (set.isEmpty) {
      return all
          .where(
            (s) =>
                s.topic == NewsTopic.technology ||
                s.topic == NewsTopic.science,
          )
          .toList();
    }
    return all.where((s) => set.contains(s.topic)).toList();
  }
}
