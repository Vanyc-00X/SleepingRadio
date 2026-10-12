import 'package:flutter_test/flutter_test.dart';
import 'package:sleeping_radio/features/player/audio/sleep_timer_math.dart';

void main() {
  group('computeFadeVolume', () {
    test('full volume before fade window', () {
      expect(
        computeFadeVolume(
          remaining: const Duration(minutes: 5),
          fadeFor: const Duration(seconds: 45),
        ),
        1,
      );
    });

    test('zero at timer end', () {
      expect(
        computeFadeVolume(
          remaining: Duration.zero,
          fadeFor: const Duration(seconds: 45),
        ),
        0,
      );
    });

    test('half at midpoint of fade', () {
      expect(
        computeFadeVolume(
          remaining: const Duration(milliseconds: 22500),
          fadeFor: const Duration(seconds: 45),
        ),
        closeTo(0.5, 0.001),
      );
    });
  });
}
