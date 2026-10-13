import 'package:flutter_test/flutter_test.dart';
import 'package:sleeping_radio/data/news/news_episode_composer.dart';
import 'package:sleeping_radio/data/news/rss_models.dart';
import 'package:sleeping_radio/data/recommendations/topic_recommender.dart';
import 'package:sleeping_radio/data/repositories/listen_history_repository.dart';
import 'package:sleeping_radio/data/web/calm_script_composer.dart';
import 'package:sleeping_radio/domain/enums/comment_length.dart';
import 'package:sleeping_radio/domain/enums/news_topic.dart';
import 'package:sleeping_radio/domain/models/listen_history.dart';
import 'package:sleeping_radio/domain/models/user_settings.dart';
import 'package:sleeping_radio/domain/enums/url_read_mode.dart';

void main() {
  group('AI comment injection', () {
    test('CalmScriptComposer uses aiComment when provided', () {
      final result = CalmScriptComposer().compose(
        title: 'Тема',
        articleText:
            'Достаточно длинный текст статьи про науку и вечернее чтение для теста комментария.',
        mode: UrlReadMode.readWithComment,
        commentLength: CommentLength.short,
        aiComment: 'Мягкий локальный комментарий от модели.',
      );
      expect(result.script, contains('Мягкий локальный комментарий от модели.'));
      expect(result.hasCommentBlock, isTrue);
    });

    test('NewsEpisodeComposer uses aiComment when provided', () {
      final result = NewsEpisodeComposer().compose(
        items: const [
          RssItem(
            title: 'Космос и тишина',
            summary: 'Исследователи рассказали о спокойном наблюдении за звёздами вечером.',
          ),
        ],
        topics: const [NewsTopic.science],
        commentLength: CommentLength.short,
        factsOnly: false,
        aiComment: 'Комментарий Ollama.',
      );
      expect(result.script, contains('Комментарий Ollama.'));
    });
  });

  group('TopicRecommender', () {
    test('boosts topics from history and preferences', () {
      final recs = TopicRecommender().recommend(
        settings: const UserSettings(
          newsTopics: [NewsTopic.technology],
        ),
        history: [
          HistoryItem(
            entry: ListenHistoryEntry(
              id: '1',
              episodeId: 'e1',
              startedAt: DateTime(2026, 1, 1),
            ),
            title: 'NASA research space update',
            subtitle: 'Новости',
          ),
        ],
      );
      expect(recs, isNotEmpty);
      expect(recs.any((r) => r.topic == NewsTopic.technology), isTrue);
    });
  });
}
