import '../../domain/enums/news_topic.dart';
import '../../domain/models/user_settings.dart';
import '../repositories/listen_history_repository.dart';

class TopicRecommendation {
  const TopicRecommendation({
    required this.topic,
    required this.reason,
    required this.score,
  });

  final NewsTopic topic;
  final String reason;
  final int score;
}

/// Простые персональные рекомендации по истории и текущим темам.
class TopicRecommender {
  List<TopicRecommendation> recommend({
    required UserSettings settings,
    required List<HistoryItem> history,
    int limit = 3,
  }) {
    final scores = <NewsTopic, int>{
      for (final t in NewsTopic.values) t: 0,
    };
    final reasons = <NewsTopic, String>{};

    for (final topic in settings.newsTopics) {
      scores[topic] = (scores[topic] ?? 0) + 3;
      reasons[topic] = 'Уже в ваших предпочтениях';
    }

    for (final item in history.take(30)) {
      final blob = '${item.title} ${item.subtitle}'.toLowerCase();
      for (final topic in NewsTopic.values) {
        final hit = _topicKeywords(topic).any(blob.contains);
        if (hit) {
          scores[topic] = (scores[topic] ?? 0) + 2;
          reasons.putIfAbsent(
            topic,
            () => 'Часто встречается в недавних прослушиваниях',
          );
        }
      }
    }

    // Лёгкий буст «спокойным» темам для ночного режима.
    scores[NewsTopic.science] = (scores[NewsTopic.science] ?? 0) + 1;
    scores[NewsTopic.culture] = (scores[NewsTopic.culture] ?? 0) + 1;
    reasons.putIfAbsent(NewsTopic.science, () => 'Мягко подходит для вечера');
    reasons.putIfAbsent(NewsTopic.culture, () => 'Спокойная вечерняя тема');

    final ranked = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ranked
        .where((e) => e.value > 0)
        .take(limit)
        .map(
          (e) => TopicRecommendation(
            topic: e.key,
            reason: reasons[e.key] ?? 'Может подойти',
            score: e.value,
          ),
        )
        .toList();
  }

  List<String> _topicKeywords(NewsTopic topic) => switch (topic) {
    NewsTopic.politics => ['политик', 'выбор', 'мир', 'world'],
    NewsTopic.technology => ['технолог', 'ai', 'ии', 'gadget', 'software'],
    NewsTopic.science => ['наук', 'космос', 'space', 'research', 'nasa'],
    NewsTopic.culture => ['культур', 'фильм', 'музык', 'книг', 'art'],
    NewsTopic.sport => ['спорт', 'матч', 'football', 'olympic'],
    NewsTopic.local => ['local', 'город', 'регион', 'uk'],
  };
}
