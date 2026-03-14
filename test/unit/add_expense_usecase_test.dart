import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trackr/core/errors/failures.dart';
import 'package:trackr/domain/entities/expense.dart';
import 'package:trackr/domain/repositories/expense_repository.dart';
import 'package:trackr/domain/usecases/add_expense_usecase.dart';
import 'package:trackr/domain/usecases/delete_expense_usecase.dart';
import 'package:trackr/domain/usecases/update_expense_usecase.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

void main() {
  late MockExpenseRepository mockRepo;
  late AddExpenseUseCase addExpenseUseCase;
  late DeleteExpenseUseCase deleteExpenseUseCase;
  late UpdateExpenseUseCase updateExpenseUseCase;

  final tExpense = Expense(
    id: 'test-id-1',
    merchantName: 'McDonald\'s',
    category: 'food',
    amount: 150.00,
    date: DateTime(2024, 1, 15),
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime(2024, 1, 15),
  );

  setUp(() {
    mockRepo = MockExpenseRepository();
    addExpenseUseCase = AddExpenseUseCase(mockRepo);
    deleteExpenseUseCase = DeleteExpenseUseCase(mockRepo);
    updateExpenseUseCase = UpdateExpenseUseCase(mockRepo);
    registerFallbackValue(tExpense);
  });

  group('AddExpenseUseCase', () {
    test('should call repository.addExpense and return Right(void) on success',
        () async {
      when(() => mockRepo.addExpense(any()))
          .thenAnswer((_) async => const Right(null));

      final result = await addExpenseUseCase(tExpense);

      expect(result, const Right(null));
      verify(() => mockRepo.addExpense(tExpense)).called(1);
    });

    test('should return Left(DatabaseFailure) when repository throws', () async {
      when(() => mockRepo.addExpense(any()))
          .thenAnswer((_) async => Left(DatabaseFailure('DB error')));

      final result = await addExpenseUseCase(tExpense);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<DatabaseFailure>()),
        (_) => fail('Expected Left'),
      );
      verify(() => mockRepo.addExpense(tExpense)).called(1);
    });

    test('should pass the expense entity to repository unchanged', () async {
      when(() => mockRepo.addExpense(any()))
          .thenAnswer((_) async => const Right(null));

      await addExpenseUseCase(tExpense);

      final captured =
          verify(() => mockRepo.addExpense(captureAny())).captured;
      expect(captured.first, equals(tExpense));
    });
  });

  group('DeleteExpenseUseCase', () {
    test('should call repository.deleteExpense with the correct id', () async {
      when(() => mockRepo.deleteExpense(any()))
          .thenAnswer((_) async => const Right(null));

      final result = await deleteExpenseUseCase('test-id-1');

      expect(result, const Right(null));
      verify(() => mockRepo.deleteExpense('test-id-1')).called(1);
    });

    test('should return Left(DatabaseFailure) on failure', () async {
      when(() => mockRepo.deleteExpense(any()))
          .thenAnswer((_) async => Left(DatabaseFailure('Not found')));

      final result = await deleteExpenseUseCase('bad-id');

      expect(result.isLeft(), true);
    });
  });

  group('UpdateExpenseUseCase', () {
    test('should call repository.updateExpense with the expense entity',
        () async {
      when(() => mockRepo.updateExpense(any()))
          .thenAnswer((_) async => const Right(null));

      final updated = tExpense.copyWith(amount: 200.0);
      final result = await updateExpenseUseCase(updated);

      expect(result, const Right(null));
      verify(() => mockRepo.updateExpense(updated)).called(1);
    });
  });
}
