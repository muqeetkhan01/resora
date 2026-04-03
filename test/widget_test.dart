import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:resora/main.dart';

void main() {
  testWidgets('Resora splash screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ResoraApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('resora'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
