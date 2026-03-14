import 'package:dartz/dartz.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';
import '../../core/errors/failures.dart';

class AddExpenseUseCase {
  final ExpenseRepository repository;

  AddExpenseUseCase(this.repository);

  Future<Either<Failure, void>> call(Expense expense) {
    return repository.addExpense(expense);
  }
}
