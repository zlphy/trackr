import 'package:dartz/dartz.dart';
import '../repositories/expense_repository.dart';
import '../../core/errors/failures.dart';

class DeleteExpenseUseCase {
  final ExpenseRepository repository;

  DeleteExpenseUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteExpense(id);
  }
}
