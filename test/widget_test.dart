import 'package:flutter_test/flutter_test.dart';
import 'package:sleeping_radio/core/constants/app_constants.dart';

void main() {
  test('app brand constant', () {
    expect(AppConstants.appName, 'Сонный радиоприёмник');
    expect(AppConstants.timerPresetsMinutes, containsAll([15, 30, 45, 60, 90]));
    expect(AppConstants.fadeOutSecondsDefault, inInclusiveRange(30, 60));
  });
}
