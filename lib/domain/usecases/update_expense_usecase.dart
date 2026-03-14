import 'package:dartz/dartz.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';
import '../../core/errors/failures.dart';

class UpdateExpenseUseCase {
  final ExpenseRepository repository;

  UpdateExpenseUseCase(this.repository);

  Future<Either<Failure, void>> call(Expense expense) {
    return repository.updateExpense(expense);
  }
}
