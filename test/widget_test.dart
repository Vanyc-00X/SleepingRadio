import 'package:flutter_test/flutter_test.dart';
import 'package:sleeping_radio/app.dart';
import 'package:sleeping_radio/core/constants/app_constants.dart';

void main() {
  testWidgets('Home shows app brand', (tester) async {
    await tester.pumpWidget(const SleepingRadioRoot());
    await tester.pumpAndSettle();

    expect(find.text(AppConstants.appName), findsOneWidget);
  });
}
