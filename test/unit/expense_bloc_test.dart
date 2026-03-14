import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trackr/core/errors/failures.dart';
import 'package:trackr/domain/entities/expense.dart';
import 'package:trackr/domain/entities/expense_category.dart';
import 'package:trackr/domain/usecases/add_expense_usecase.dart';
import 'package:trackr/domain/usecases/categorize_expense_usecase.dart';
import 'package:trackr/domain/usecases/delete_expense_usecase.dart';
import 'package:trackr/domain/usecases/get_expenses_usecase.dart';
import 'package:trackr/domain/usecases/update_expense_usecase.dart';
import 'package:trackr/presentation/bloc/expense/expense_bloc.dart';

class MockAddExpenseUseCase extends Mock implements AddExpenseUseCase {}
class MockGetExpensesUseCase extends Mock implements GetExpensesUseCase {}
class MockCategorizeExpenseUseCase extends Mock implements CategorizeExpenseUseCase {}
class MockDeleteExpenseUseCase extends Mock implements DeleteExpenseUseCase {}
class MockUpdateExpenseUseCase extends Mock implements UpdateExpenseUseCase {}

void main() {
  late MockAddExpenseUseCase mockAddUseCase;
  late MockGetExpensesUseCase mockGetUseCase;
  late MockCategorizeExpenseUseCase mockCategorizeUseCase;
  late MockDeleteExpenseUseCase mockDeleteUseCase;
  late MockUpdateExpenseUseCase mockUpdateUseCase;

  final tExpense = Expense(
    id: 'e1',
    merchantName: 'Starbucks',
    category: 'food',
    amount: 180.0,
    date: DateTime(2024, 3, 1),
    createdAt: DateTime(2024, 3, 1),
    updatedAt: DateTime(2024, 3, 1),
  );

  final tCategory = ExpenseCategory(
    id: 'food',
    name: 'อาหาร',
    description: 'ค่าอาหารและเครื่องดื่ม',
    icon: 'restaurant',
    color: 0xFFFF5722,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  ExpenseBloc buildBloc() => ExpenseBloc(
        addExpenseUseCase: mockAddUseCase,
        getExpensesUseCase: mockGetUseCase,
        categorizeExpenseUseCase: mockCategorizeUseCase,
        deleteExpenseUseCase: mockDeleteUseCase,
        updateExpenseUseCase: mockUpdateUseCase,
      );

  setUp(() {
    mockAddUseCase = MockAddExpenseUseCase();
    mockGetUseCase = MockGetExpensesUseCase();
    mockCategorizeUseCase = MockCategorizeExpenseUseCase();
    mockDeleteUseCase = MockDeleteExpenseUseCase();
    mockUpdateUseCase = MockUpdateExpenseUseCase();
    registerFallbackValue(tExpense);
  });

  group('LoadExpenses', () {
    blocTest<ExpenseBloc, ExpenseState>(
      'emits [ExpenseLoading, ExpenseLoaded] on success',
      build: buildBloc,
      setUp: () {
        when(() => mockGetUseCase.getAllExpenses())
            .thenAnswer((_) async => Right([tExpense]));
      },
      act: (bloc) => bloc.add(const LoadExpenses()),
      expect: () => [
        const ExpenseLoading(),
        ExpenseLoaded(expenses: [tExpense]),
      ],
    );

    blocTest<ExpenseBloc, ExpenseState>(
      'emits [ExpenseLoading, ExpenseError] on failure',
      build: buildBloc,
      setUp: () {
        when(() => mockGetUseCase.getAllExpenses())
            .thenAnswer((_) async => Left(DatabaseFailure('DB error')));
      },
      act: (bloc) => bloc.add(const LoadExpenses()),
      expect: () => [
        const ExpenseLoading(),
        isA<ExpenseError>(),
      ],
    );
  });

  group('AddExpense', () {
    blocTest<ExpenseBloc, ExpenseState>(
      'emits [ExpenseLoading, ExpenseLoaded] after add succeeds',
      build: buildBloc,
      setUp: () {
        when(() => mockAddUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetUseCase.getAllExpenses())
            .thenAnswer((_) async => Right([tExpense]));
      },
      act: (bloc) => bloc.add(AddExpense(tExpense)),
      expect: () => [
        const ExpenseLoading(),
        ExpenseLoaded(expenses: [tExpense]),
      ],
      verify: (_) {
        verify(() => mockAddUseCase(tExpense)).called(1);
        verify(() => mockGetUseCase.getAllExpenses()).called(1);
      },
    );

    blocTest<ExpenseBloc, ExpenseState>(
      'emits [ExpenseLoading, ExpenseError] when add fails',
      build: buildBloc,
      setUp: () {
        when(() => mockAddUseCase(any()))
            .thenAnswer((_) async => Left(DatabaseFailure('write error')));
      },
      act: (bloc) => bloc.add(AddExpense(tExpense)),
      expect: () => [
        const ExpenseLoading(),
        isA<ExpenseError>(),
      ],
    );
  });

  group('DeleteExpense', () {
    blocTest<ExpenseBloc, ExpenseState>(
      'emits [ExpenseLoading, ExpenseLoaded] after delete succeeds',
      build: buildBloc,
      setUp: () {
        when(() => mockDeleteUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetUseCase.getAllExpenses())
            .thenAnswer((_) async => const Right([]));
      },
      act: (bloc) => bloc.add(const DeleteExpense('e1')),
      expect: () => [
        const ExpenseLoading(),
        const ExpenseLoaded(expenses: []),
      ],
      verify: (_) {
        verify(() => mockDeleteUseCase('e1')).called(1);
      },
    );
  });

  group('CategorizeExpense', () {
    blocTest<ExpenseBloc, ExpenseState>(
      'emits [ExpenseCategorizing, ExpenseCategorized] on success',
      build: buildBloc,
      setUp: () {
        when(() => mockCategorizeUseCase(any(), any(), any()))
            .thenAnswer((_) async => const Right('food'));
      },
      act: (bloc) => bloc.add(const CategorizeExpense(
        receiptText: 'McDonald receipt',
        amount: 150,
        merchantName: 'McDonald',
      )),
      expect: () => [
        const ExpenseCategorizing(),
        const ExpenseCategorized(category: 'food'),
      ],
    );
  });

  group('LoadCategories', () {
    blocTest<ExpenseBloc, ExpenseState>(
      'emits [ExpenseLoading, CategoriesLoaded] with categories',
      build: buildBloc,
      setUp: () {
        when(() => mockGetUseCase.getAllCategories())
            .thenAnswer((_) async => Right([tCategory]));
      },
      act: (bloc) => bloc.add(LoadCategories()),
      expect: () => [
        const ExpenseLoading(),
        CategoriesLoaded(categories: [tCategory]),
      ],
    );
  });
}
