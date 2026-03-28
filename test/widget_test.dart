import 'package:flutter_test/flutter_test.dart';

import 'package:resora/main.dart';

void main() {
  testWidgets('Resora onboarding flow becomes visible', (WidgetTester tester) async {
    await tester.pumpWidget(const ResoraApp());
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    expect(find.text('A softer way to hold the day'), findsOneWidget);
  });
}
