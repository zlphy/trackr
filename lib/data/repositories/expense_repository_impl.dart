import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_category.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/local/expense_local_datasource.dart';
import '../datasources/remote/llm_remote_datasource.dart';
import '../datasources/local/app_database.dart' as db;
import '../../core/errors/failures.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;
  final LLMRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl(this.localDataSource, this.remoteDataSource);

  @override
  Future<Either<Failure, List<Expense>>> getAllExpenses() async {
    try {
      final expenses = await localDataSource.getAllExpenses();
      return Right(expenses.map((e) => _mapToExpenseEntity(e)).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByDateRange(DateTime start, DateTime end) async {
    try {
      final expenses = await localDataSource.getExpensesByDateRange(start, end);
      return Right(expenses.map((e) => _mapToExpenseEntity(e)).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByCategory(String categoryId) async {
    try {
      final expenses = await localDataSource.getExpensesByCategory(categoryId);
      return Right(expenses.map((e) => _mapToExpenseEntity(e)).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense?>> getExpenseById(String id) async {
    try {
      final expense = await localDataSource.getExpenseById(id);
      return Right(expense != null ? _mapToExpenseEntity(expense) : null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addExpense(Expense expense) async {
    try {
      final expenseCompanion = _mapToExpensesCompanion(expense);
      await localDataSource.insertExpense(expenseCompanion);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateExpense(Expense expense) async {
    try {
      final expenseCompanion = _mapToExpensesCompanion(expense);
      await localDataSource.updateExpense(expenseCompanion);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String id) async {
    try {
      await localDataSource.deleteExpense(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseCategory>>> getAllCategories() async {
    try {
      final categories = await localDataSource.getAllCategories();
      return Right(categories.map((c) => _mapToExpenseCategoryEntity(c)).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseCategory?>> getCategoryById(String id) async {
    try {
      final category = await localDataSource.getCategoryById(id);
      return Right(category != null ? _mapToExpenseCategoryEntity(category) : null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalExpensesByDateRange(DateTime start, DateTime end) async {
    try {
      final total = await localDataSource.getTotalExpensesByDateRange(start, end);
      return Right(total);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getExpensesByCategorySum(DateTime start, DateTime end) async {
    try {
      final categorySums = await localDataSource.getExpensesByCategorySum(start, end);
      return Right(categorySums);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> categorizeExpenseFromText(String receiptText, double amount, String merchantName) async {
    try {
      final result = await remoteDataSource.categorizeExpense(
        receiptText: receiptText,
        amount: amount,
        merchantName: merchantName,
      );
      
      final category = result['category'] as String? ?? 'other';
      return Right(category);
    } catch (e) {
      final raw = e.toString();
      final msg = raw.startsWith('Exception: ') ? raw.substring(11) : raw;
      return Left(NetworkFailure(msg));
    }
  }

  Expense _mapToExpenseEntity(db.Expense expense) {
    return Expense(
      id: expense.id,
      merchantName: expense.merchantName,
      category: expense.category,
      amount: expense.amount,
      date: expense.date,
      receiptImagePath: expense.receiptImagePath,
      receiptText: expense.receiptText,
      notes: expense.notes,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
    );
  }

  ExpenseCategory _mapToExpenseCategoryEntity(db.ExpenseCategory category) {
    return ExpenseCategory(
      id: category.id,
      name: category.name,
      description: category.description,
      icon: category.icon,
      color: category.color,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }

  db.ExpensesCompanion _mapToExpensesCompanion(Expense expense) {
    return db.ExpensesCompanion(
      id: Value(expense.id),
      merchantName: Value(expense.merchantName),
      category: Value(expense.category),
      amount: Value(expense.amount),
      date: Value(expense.date),
      receiptImagePath: Value(expense.receiptImagePath),
      receiptText: Value(expense.receiptText),
      notes: Value(expense.notes),
      createdAt: Value(expense.createdAt),
      updatedAt: Value(expense.updatedAt),
    );
  }
}
