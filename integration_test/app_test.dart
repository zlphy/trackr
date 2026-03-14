import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trackr/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App E2E Integration Tests', () {
    testWidgets('app launches and shows Dashboard', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('AI Expense Tracker'), findsOneWidget);
    });

    testWidgets('navigate to Camera page via FAB and back',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // FAB is on Dashboard
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      await tester.tap(fab);
      await tester.pumpAndSettle();

      expect(find.text('สแกนใบเสร็จ'), findsOneWidget);

      // Navigate to manual entry form
      await tester.tap(find.text('กรอกข้อมูลเองโดยไม่สแกน'));
      await tester.pumpAndSettle();

      expect(find.text('เพิ่มค่าใช้จ่าย'), findsOneWidget);

      // Pop back
      await tester.pageBack();
      await tester.pumpAndSettle();
    });

    testWidgets('validate form shows errors on empty submit', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Go to camera then manual form
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('กรอกข้อมูลเองโดยไม่สแกน'));
      await tester.pumpAndSettle();

      // Tap save without filling in any field
      await tester.tap(find.text('บันทึก'));
      await tester.pump();

      expect(find.text('กรุณากรอกชื่อร้านค้า'), findsOneWidget);
      expect(find.text('กรุณากรอกจำนวนเงิน'), findsOneWidget);
    });

    testWidgets('navigate to Settings page', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('ตั้งค่า'), findsOneWidget);
      expect(find.text('ธีม'), findsOneWidget);
      expect(find.text('Gemini API Key'), findsOneWidget);
    });

    testWidgets('toggle dark mode in Settings', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Switch state should have changed
      final switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isTrue);
    });
  });
}
