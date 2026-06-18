// Basic smoke test for the QuickTurn app.
//
// Verifies that the root [QuickTurnApp] widget builds without throwing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quick_turn_mobile/main.dart';

void main() {
  testWidgets('QuickTurnApp builds smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const QuickTurnApp());
    await tester.pump(const Duration(milliseconds: 400));

    // The root widget should render a MaterialApp.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
