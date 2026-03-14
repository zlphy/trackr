import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/expense.dart';
import '../../../domain/entities/expense_category.dart';
import '../../../domain/usecases/add_expense_usecase.dart';
import '../../../domain/usecases/get_expenses_usecase.dart';
import '../../../domain/usecases/categorize_expense_usecase.dart';
import '../../../domain/usecases/delete_expense_usecase.dart';
import '../../../domain/usecases/update_expense_usecase.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final AddExpenseUseCase addExpenseUseCase;
  final GetExpensesUseCase getExpensesUseCase;
  final CategorizeExpenseUseCase categorizeExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;
  final UpdateExpenseUseCase updateExpenseUseCase;

  ExpenseBloc({
    required this.addExpenseUseCase,
    required this.getExpensesUseCase,
    required this.categorizeExpenseUseCase,
    required this.deleteExpenseUseCase,
    required this.updateExpenseUseCase,
  }) : super(const ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<CategorizeExpense>(_onCategorizeExpense);
    on<LoadCategories>(_onLoadCategories);
    on<FilterExpensesByDate>(_onFilterExpensesByDate);
    on<FilterExpensesByCategory>(_onFilterExpensesByCategory);
    on<LoadDashboardStats>(_onLoadDashboardStats);
    on<LoadDashboardStatsWithFilters>(_onLoadDashboardStatsWithFilters);
  }

  Future<void> _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());
    
    final result = await getExpensesUseCase.getAllExpenses();
    
    result.fold(
      (failure) => emit(ExpenseError(failure.toString())),
      (expenses) => emit(ExpenseLoaded(expenses: expenses)),
    );
  }

  Future<void> _onAddExpense(AddExpense event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());
    final result = await addExpenseUseCase(event.expense);
    if (result.isLeft()) {
      result.fold((f) => emit(ExpenseError(f.toString())), (_) {});
      return;
    }
    final expensesResult = await getExpensesUseCase.getAllExpenses();
    expensesResult.fold(
      (f) => emit(ExpenseError(f.toString())),
      (expenses) => emit(ExpenseLoaded(expenses: expenses)),
    );
  }

  Future<void> _onUpdateExpense(UpdateExpense event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());
    final result = await updateExpenseUseCase(event.expense);
    if (result.isLeft()) {
      result.fold((f) => emit(ExpenseError(f.toString())), (_) {});
      return;
    }
    final expensesResult = await getExpensesUseCase.getAllExpenses();
    expensesResult.fold(
      (f) => emit(ExpenseError(f.toString())),
      (expenses) => emit(ExpenseLoaded(expenses: expenses)),
    );
  }

  Future<void> _onDeleteExpense(DeleteExpense event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());
    final result = await deleteExpenseUseCase(event.expenseId);
    if (result.isLeft()) {
      result.fold((f) => emit(ExpenseError(f.toString())), (_) {});
      return;
    }
    final expensesResult = await getExpensesUseCase.getAllExpenses();
    expensesResult.fold(
      (f) => emit(ExpenseError(f.toString())),
      (expenses) => emit(ExpenseLoaded(expenses: expenses)),
    );
  }

  Future<void> _onCategorizeExpense(CategorizeExpense event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseCategorizing());
    
    final result = await categorizeExpenseUseCase(
      event.receiptText,
      event.amount,
      event.merchantName,
    );
    
    result.fold(
      (failure) => emit(ExpenseError(failure.toString())),
      (category) => emit(ExpenseCategorized(category: category)),
    );
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());
    
    final result = await getExpensesUseCase.getAllCategories();
    
    result.fold(
      (failure) => emit(ExpenseError(failure.toString())),
      (categories) => emit(CategoriesLoaded(categories: categories)),
    );
  }

  Future<void> _onFilterExpensesByDate(FilterExpensesByDate event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());
    
    final result = await getExpensesUseCase.getExpensesByDateRange(event.startDate, event.endDate);
    
    result.fold(
      (failure) => emit(ExpenseError(failure.toString())),
      (expenses) => emit(ExpenseLoaded(expenses: expenses)),
    );
  }

  Future<void> _onFilterExpensesByCategory(FilterExpensesByCategory event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());

    final result = await getExpensesUseCase.getExpensesByCategory(event.categoryId);

    result.fold(
      (failure) => emit(ExpenseError(failure.toString())),
      (expenses) => emit(ExpenseLoaded(expenses: expenses)),
    );
  }

  Future<void> _onLoadDashboardStats(
      LoadDashboardStats event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    // Last month dates
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final startOfLastMonth = DateTime(lastMonth.year, lastMonth.month, 1);
    final endOfLastMonth = DateTime(lastMonth.year, lastMonth.month + 1, 0, 23, 59, 59);

    // Get current month expenses only
    final expensesResult = await getExpensesUseCase
        .getExpensesByDateRange(startOfMonth, endOfMonth);
    final currentTotalResult = await getExpensesUseCase
        .getTotalExpensesByDateRange(startOfMonth, endOfMonth);
    final lastTotalResult = await getExpensesUseCase
        .getTotalExpensesByDateRange(startOfLastMonth, endOfLastMonth);
    final categoriesResult = await getExpensesUseCase.getAllCategories();

    expensesResult.fold(
      (failure) => emit(ExpenseError(failure.toString())),
      (expenses) {
        final currentTotal = currentTotalResult.fold((_) => 0.0, (t) => t);
        final lastTotal = lastTotalResult.fold((_) => 0.0, (t) => t);

        // Compute category breakdown from current month expenses
        final categoryMap = <String, double>{};
        for (final e in expenses) {
          categoryMap[e.category] = (categoryMap[e.category] ?? 0.0) + e.amount;
        }

        final categories = categoriesResult.fold((_) => <ExpenseCategory>[], (c) => c);
        emit(DashboardLoaded(
          expenses: expenses, // now only current month expenses
          monthlyTotal: currentTotal,
          lastMonthTotal: lastTotal,
          categoryBreakdown: categoryMap,
          categories: categories,
        ));
      },
    );
  }

  Future<void> _onLoadDashboardStatsWithFilters(
      LoadDashboardStatsWithFilters event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());

    final month = event.month;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    
    // Last month dates
    final lastMonth = DateTime(month.year, month.month - 1, 1);
    final startOfLastMonth = DateTime(lastMonth.year, lastMonth.month, 1);
    final endOfLastMonth = DateTime(lastMonth.year, lastMonth.month + 1, 0, 23, 59, 59);

    // Get current month expenses only
    final expensesResult = await getExpensesUseCase
        .getExpensesByDateRange(startOfMonth, endOfMonth);
    final currentTotalResult = await getExpensesUseCase
        .getTotalExpensesByDateRange(startOfMonth, endOfMonth);
    final lastTotalResult = await getExpensesUseCase
        .getTotalExpensesByDateRange(startOfLastMonth, endOfLastMonth);
    final categoriesResult = await getExpensesUseCase.getAllCategories();

    expensesResult.fold(
      (failure) => emit(ExpenseError(failure.toString())),
      (expenses) {
        final currentTotal = currentTotalResult.fold((_) => 0.0, (t) => t);
        final lastTotal = lastTotalResult.fold((_) => 0.0, (t) => t);

        // Sort expenses based on criteria
        List<Expense> sortedExpenses = List.from(expenses);
        switch (event.sortBy) {
          case 'date':
            sortedExpenses.sort((a, b) => event.sortDescending 
                ? b.date.compareTo(a.date)
                : a.date.compareTo(b.date));
            break;
          case 'amount':
            sortedExpenses.sort((a, b) => event.sortDescending
                ? b.amount.compareTo(a.amount)
                : a.amount.compareTo(b.amount));
            break;
          case 'merchant':
            sortedExpenses.sort((a, b) => event.sortDescending
                ? b.merchantName.compareTo(a.merchantName)
                : a.merchantName.compareTo(b.merchantName));
            break;
        }

        // Compute category breakdown from current month expenses
        final categoryMap = <String, double>{};
        for (final e in sortedExpenses) {
          categoryMap[e.category] = (categoryMap[e.category] ?? 0.0) + e.amount;
        }

        final categories = categoriesResult.fold((_) => <ExpenseCategory>[], (c) => c);
        emit(DashboardLoaded(
          expenses: sortedExpenses,
          monthlyTotal: currentTotal,
          lastMonthTotal: lastTotal,
          categoryBreakdown: categoryMap,
          categories: categories,
        ));
      },
    );
  }
}
