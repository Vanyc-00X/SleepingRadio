import 'package:flutter_test/flutter_test.dart';
import 'package:sleeping_radio/data/news/news_episode_composer.dart';
import 'package:sleeping_radio/domain/enums/comment_length.dart';
import 'package:sleeping_radio/domain/enums/news_topic.dart';
import 'package:sleeping_radio/data/news/rss_models.dart';

void main() {
  test('MVP acceptance: news script has facts then optional comment', () {
    final script = NewsEpisodeComposer()
        .compose(
          items: const [
            RssItem(
              title: 'Тихий заголовок',
              summary: 'Достаточно длинное описание новости для сводки вечером.',
            ),
          ],
          topics: const [NewsTopic.science],
          commentLength: CommentLength.short,
          factsOnly: false,
        )
        .script;

    final factsAt = script.indexOf('Факты.');
    final commentAt = script.indexOf('Короткий комментарий.');
    expect(factsAt, greaterThanOrEqualTo(0));
    expect(commentAt, greaterThan(factsAt));
    expect(script, contains(NewsEpisodeComposer.disclaimer));
  });
}
