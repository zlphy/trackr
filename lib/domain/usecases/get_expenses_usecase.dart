import 'package:dartz/dartz.dart';
import '../entities/expense.dart';
import '../entities/expense_category.dart';
import '../repositories/expense_repository.dart';
import '../../core/errors/failures.dart';

class GetExpensesUseCase {
  final ExpenseRepository repository;

  GetExpensesUseCase(this.repository);

  Future<Either<Failure, List<Expense>>> getAllExpenses() {
    return repository.getAllExpenses();
  }

  Future<Either<Failure, List<Expense>>> getExpensesByDateRange(DateTime start, DateTime end) {
    return repository.getExpensesByDateRange(start, end);
  }

  Future<Either<Failure, List<Expense>>> getExpensesByCategory(String categoryId) {
    return repository.getExpensesByCategory(categoryId);
  }

  Future<Either<Failure, Expense?>> getExpenseById(String id) {
    return repository.getExpenseById(id);
  }

  Future<Either<Failure, List<ExpenseCategory>>> getAllCategories() {
    return repository.getAllCategories();
  }

  Future<Either<Failure, double>> getTotalExpensesByDateRange(DateTime start, DateTime end) {
    return repository.getTotalExpensesByDateRange(start, end);
  }

  Future<Either<Failure, Map<String, double>>> getExpensesByCategorySum(DateTime start, DateTime end) {
    return repository.getExpensesByCategorySum(start, end);
  }
}
