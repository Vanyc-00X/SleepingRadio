import '../../domain/enums/news_language.dart';
import '../../domain/enums/news_topic.dart';

class NewsSource {
  const NewsSource({
    required this.id,
    required this.label,
    required this.feedUrl,
    required this.topic,
    this.priority = 50,
    this.language = NewsLanguage.en,
  });

  final String id;
  final String label;
  final String feedUrl;
  final NewsTopic topic;
  final int priority;
  final NewsLanguage language;
}

/// Встроенные RSS по темам и языкам.
class NewsSources {
  static const List<NewsSource> all = [
    NewsSource(
      id: 'bbc_tech',
      label: 'BBC Technology',
      feedUrl: 'https://feeds.bbci.co.uk/news/technology/rss.xml',
      topic: NewsTopic.technology,
      language: NewsLanguage.en,
    ),
    NewsSource(
      id: 'hn',
      label: 'Hacker News',
      feedUrl: 'https://hnrss.org/frontpage',
      topic: NewsTopic.technology,
      language: NewsLanguage.en,
    ),
    NewsSource(
      id: 'bbc_science',
      label: 'BBC Science',
      feedUrl:
          'https://feeds.bbci.co.uk/news/science_and_environment/rss.xml',
      topic: NewsTopic.science,
      language: NewsLanguage.en,
    ),
    NewsSource(
      id: 'nasa',
      label: 'NASA Breaking News',
      feedUrl: 'https://www.nasa.gov/rss/dyn/breaking_news.rss',
      topic: NewsTopic.science,
      language: NewsLanguage.en,
    ),
    NewsSource(
      id: 'bbc_world',
      label: 'BBC World',
      feedUrl: 'https://feeds.bbci.co.uk/news/world/rss.xml',
      topic: NewsTopic.politics,
      language: NewsLanguage.en,
    ),
    NewsSource(
      id: 'bbc_culture',
      label: 'BBC Culture',
      feedUrl:
          'https://feeds.bbci.co.uk/news/entertainment_and_arts/rss.xml',
      topic: NewsTopic.culture,
      language: NewsLanguage.en,
    ),
    NewsSource(
      id: 'bbc_sport',
      label: 'BBC Sport',
      feedUrl: 'https://feeds.bbci.co.uk/sport/rss.xml',
      topic: NewsTopic.sport,
      language: NewsLanguage.en,
    ),
    NewsSource(
      id: 'bbc_uk',
      label: 'BBC UK',
      feedUrl: 'https://feeds.bbci.co.uk/news/uk/rss.xml',
      topic: NewsTopic.local,
      language: NewsLanguage.en,
    ),
  ];

  static List<NewsSource> forTopics(
    Iterable<NewsTopic> topics, {
    NewsLanguage? language,
  }) {
    final set = topics.toSet();
    var list = all.where((s) {
      if (language != null && s.language != language) return false;
      if (set.isEmpty) {
        return s.topic == NewsTopic.technology || s.topic == NewsTopic.science;
      }
      return set.contains(s.topic);
    }).toList();
    return list;
  }
}
