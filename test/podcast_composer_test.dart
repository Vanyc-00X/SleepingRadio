import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sleeping_radio/data/books/txt_book_parser.dart';
import 'package:sleeping_radio/data/podcast/podcast_composer.dart';

void main() {
  group('PodcastComposer', () {
    test('builds intro segments outro within segment limit', () {
      final composed = PodcastComposer().compose(
        target: PodcastTargetMinutes.ten,
        customTitle: 'Тест',
        segments: [
          const PodcastSegmentDraft(
            title: 'Тема один',
            body: 'Первый сегмент с достаточным количеством спокойного текста для вечернего выпуска. '
                'Ещё одно предложение, чтобы было что читать.',
          ),
          const PodcastSegmentDraft(
            title: 'Тема два',
            body: 'Второй сегмент продолжает мягкую сводку без резких акцентов и лишней спешки.',
          ),
        ],
      );

      expect(composed.title, 'Тест');
      expect(composed.script, contains('Интро.'));
      expect(composed.script, contains('Сегмент 1.'));
      expect(composed.script, contains('Сегмент 2.'));
      expect(composed.script, contains('Аутро.'));
      expect(composed.script, contains('Спокойной ночи'));
      expect(composed.segmentCount, 2);
      expect(composed.targetMinutes, 10);
    });

    test('rejects empty segments', () {
      expect(
        () => PodcastComposer().compose(
          segments: const [],
          target: PodcastTargetMinutes.five,
        ),
        throwsArgumentError,
      );
    });
  });

  group('TxtBookParser', () {
    test('parses utf8 text file', () {
      final bytes = utf8.encode(
        'Заголовок вечера\n\n'
        'Первый абзац достаточно длинный для импорта.\n\n'
        'Второй абзац продолжает историю спокойным тоном.',
      );
      final parsed = TxtBookParser().parse(bytes, fileName: 'night.txt');
      expect(parsed.format, 'txt');
      expect(parsed.title, 'night');
      expect(parsed.chapters, isNotEmpty);
      expect(parsed.chapters.first.content, contains('Первый абзац'));
    });
  });
}
