import 'app_database.dart' as db;

abstract class ExpenseLocalDataSource {
  Future<List<db.Expense>> getAllExpenses();
  Future<List<db.Expense>> getExpensesByDateRange(DateTime start, DateTime end);
  Future<List<db.Expense>> getExpensesByCategory(String categoryId);
  Future<db.Expense?> getExpenseById(String id);
  Future<void> insertExpense(db.ExpensesCompanion entry);
  Future<void> updateExpense(db.ExpensesCompanion entry);
  Future<void> deleteExpense(String id);
  Future<List<db.ExpenseCategory>> getAllCategories();
  Future<db.ExpenseCategory?> getCategoryById(String id);
  Future<double> getTotalExpensesByDateRange(DateTime start, DateTime end);
  Future<Map<String, double>> getExpensesByCategorySum(DateTime start, DateTime end);
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  final db.AppDatabase database;

  ExpenseLocalDataSourceImpl(this.database);

  @override
  Future<List<db.Expense>> getAllExpenses() => database.getAllExpenses();

  @override
  Future<List<db.Expense>> getExpensesByDateRange(DateTime start, DateTime end) =>
      database.getExpensesByDateRange(start, end);

  @override
  Future<List<db.Expense>> getExpensesByCategory(String categoryId) =>
      database.getExpensesByCategory(categoryId);

  @override
  Future<db.Expense?> getExpenseById(String id) => database.getExpenseById(id);

  @override
  Future<void> insertExpense(db.ExpensesCompanion entry) => database.insertExpense(entry);

  @override
  Future<void> updateExpense(db.ExpensesCompanion entry) => database.updateExpense(entry);

  @override
  Future<void> deleteExpense(String id) => database.deleteExpense(id);

  @override
  Future<List<db.ExpenseCategory>> getAllCategories() => database.getAllCategories();
  
  @override
  Future<db.ExpenseCategory?> getCategoryById(String id) => database.getCategoryById(id);

  @override
  Future<double> getTotalExpensesByDateRange(DateTime start, DateTime end) =>
      database.getTotalExpensesByDateRange(start, end);

  @override
  Future<Map<String, double>> getExpensesByCategorySum(DateTime start, DateTime end) =>
      database.getExpensesByCategorySum(start, end);
}
