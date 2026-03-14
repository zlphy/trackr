import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MaterialApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('AI Expense Tracker')),
        ),
      ),
    );
    expect(find.text('AI Expense Tracker'), findsOneWidget);
  });
}
