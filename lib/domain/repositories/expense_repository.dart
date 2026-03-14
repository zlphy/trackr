import 'package:dartz/dartz.dart';
import '../entities/expense.dart';
import '../entities/expense_category.dart';
import '../../core/errors/failures.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, List<Expense>>> getAllExpenses();
  Future<Either<Failure, List<Expense>>> getExpensesByDateRange(DateTime start, DateTime end);
  Future<Either<Failure, List<Expense>>> getExpensesByCategory(String categoryId);
  Future<Either<Failure, Expense?>> getExpenseById(String id);
  Future<Either<Failure, void>> addExpense(Expense expense);
  Future<Either<Failure, void>> updateExpense(Expense expense);
  Future<Either<Failure, void>> deleteExpense(String id);
  Future<Either<Failure, List<ExpenseCategory>>> getAllCategories();
  Future<Either<Failure, ExpenseCategory?>> getCategoryById(String id);
  Future<Either<Failure, double>> getTotalExpensesByDateRange(DateTime start, DateTime end);
  Future<Either<Failure, Map<String, double>>> getExpensesByCategorySum(DateTime start, DateTime end);
  Future<Either<Failure, String>> categorizeExpenseFromText(String receiptText, double amount, String merchantName);
}
