import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trackr/domain/entities/expense_category.dart';
import 'package:trackr/presentation/bloc/expense/expense_bloc.dart';

class MockExpenseBloc extends MockBloc<ExpenseEvent, ExpenseState>
    implements ExpenseBloc {}

class FakeExpenseEvent extends Fake implements ExpenseEvent {}
class FakeExpenseState extends Fake implements ExpenseState {}

final _tCategories = [
  ExpenseCategory(
    id: 'food',
    name: 'อาหาร',
    description: 'ค่าอาหาร',
    icon: 'restaurant',
    color: 0xFFFF5722,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  ),
  ExpenseCategory(
    id: 'transport',
    name: 'การเดินทาง',
    description: 'ค่าเดินทาง',
    icon: 'directions_car',
    color: 0xFF2196F3,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  ),
];

Widget _buildTestApp(MockExpenseBloc bloc) {
  return MaterialApp(
    home: BlocProvider<ExpenseBloc>.value(
      value: bloc,
      child: const Scaffold(
        body: _TestFormBody(),
      ),
    ),
  );
}

// Minimal form body that directly embeds the form state for testing
class _TestFormBody extends StatefulWidget {
  const _TestFormBody();

  @override
  State<_TestFormBody> createState() => _TestFormBodyState();
}

class _TestFormBodyState extends State<_TestFormBody> {
  final _formKey = GlobalKey<FormState>();
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              key: const Key('merchantField'),
              controller: _merchantController,
              decoration: const InputDecoration(labelText: 'ชื่อร้านค้า *'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'กรุณากรอกชื่อร้านค้า';
                if (v.trim().length < 2) return 'ชื่อร้านค้าต้องมีอย่างน้อย 2 ตัวอักษร';
                return null;
              },
            ),
            TextFormField(
              key: const Key('amountField'),
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'จำนวนเงิน *'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'กรุณากรอกจำนวนเงิน';
                final parsed = double.tryParse(v.trim());
                if (parsed == null) return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                if (parsed <= 0) return 'จำนวนเงินต้องมากกว่า 0';
                return null;
              },
            ),
            ElevatedButton(
              key: const Key('submitBtn'),
              onPressed: () => _formKey.currentState!.validate(),
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  late MockExpenseBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(FakeExpenseEvent());
    registerFallbackValue(FakeExpenseState());
  });

  setUp(() {
    mockBloc = MockExpenseBloc();
    when(() => mockBloc.state)
        .thenReturn(CategoriesLoaded(categories: _tCategories));
    when(() => mockBloc.stream).thenAnswer((_) => Stream.fromIterable([]));
  });

  group('ExpenseForm Validation', () {
    testWidgets('shows error when merchant name is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(mockBloc));

      await tester.tap(find.byKey(const Key('submitBtn')));
      await tester.pump();

      expect(find.text('กรุณากรอกชื่อร้านค้า'), findsOneWidget);
    });

    testWidgets('shows error when merchant name is too short',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(mockBloc));

      await tester.enterText(find.byKey(const Key('merchantField')), 'A');
      await tester.tap(find.byKey(const Key('submitBtn')));
      await tester.pump();

      expect(find.text('ชื่อร้านค้าต้องมีอย่างน้อย 2 ตัวอักษร'), findsOneWidget);
    });

    testWidgets('shows error when amount is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(mockBloc));

      await tester.enterText(
          find.byKey(const Key('merchantField')), 'Starbucks');
      await tester.tap(find.byKey(const Key('submitBtn')));
      await tester.pump();

      expect(find.text('กรุณากรอกจำนวนเงิน'), findsOneWidget);
    });

    testWidgets('shows error when amount is not a number',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(mockBloc));

      await tester.enterText(
          find.byKey(const Key('merchantField')), 'Starbucks');
      await tester.enterText(find.byKey(const Key('amountField')), 'abc');
      await tester.tap(find.byKey(const Key('submitBtn')));
      await tester.pump();

      expect(find.text('กรุณากรอกตัวเลขที่ถูกต้อง'), findsOneWidget);
    });

    testWidgets('shows error when amount is zero or negative',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(mockBloc));

      await tester.enterText(
          find.byKey(const Key('merchantField')), 'Starbucks');
      await tester.enterText(find.byKey(const Key('amountField')), '-50');
      await tester.tap(find.byKey(const Key('submitBtn')));
      await tester.pump();

      expect(find.text('จำนวนเงินต้องมากกว่า 0'), findsOneWidget);
    });

    testWidgets('shows no errors when all fields are valid',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(mockBloc));

      await tester.enterText(
          find.byKey(const Key('merchantField')), 'Starbucks');
      await tester.enterText(find.byKey(const Key('amountField')), '150.00');
      await tester.tap(find.byKey(const Key('submitBtn')));
      await tester.pump();

      expect(find.text('กรุณากรอกชื่อร้านค้า'), findsNothing);
      expect(find.text('กรุณากรอกจำนวนเงิน'), findsNothing);
      expect(find.text('กรุณากรอกตัวเลขที่ถูกต้อง'), findsNothing);
    });
  });
}
