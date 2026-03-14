part of 'expense_bloc.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object> get props => [];
}

class LoadExpenses extends ExpenseEvent {
  const LoadExpenses();

  @override
  List<Object> get props => [];
}

class AddExpense extends ExpenseEvent {
  final Expense expense;

  const AddExpense(this.expense);

  @override
  List<Object> get props => [expense];
}

class UpdateExpense extends ExpenseEvent {
  final Expense expense;

  const UpdateExpense(this.expense);

  @override
  List<Object> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  final String expenseId;

  const DeleteExpense(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}

class CategorizeExpense extends ExpenseEvent {
  final String receiptText;
  final double amount;
  final String merchantName;

  const CategorizeExpense({
    required this.receiptText,
    required this.amount,
    required this.merchantName,
  });

  @override
  List<Object> get props => [receiptText, amount, merchantName];
}

class LoadCategories extends ExpenseEvent {
  const LoadCategories();

  @override
  List<Object> get props => [];
}

class FilterExpensesByDate extends ExpenseEvent {
  final DateTime startDate;
  final DateTime endDate;

  const FilterExpensesByDate({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}

class FilterExpensesByCategory extends ExpenseEvent {
  final String categoryId;

  const FilterExpensesByCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class LoadDashboardStats extends ExpenseEvent {
  const LoadDashboardStats();

  @override
  List<Object> get props => [];
}

class LoadDashboardStatsWithFilters extends ExpenseEvent {
  final DateTime month;
  final String sortBy;
  final bool sortDescending;

  const LoadDashboardStatsWithFilters({
    required this.month,
    required this.sortBy,
    required this.sortDescending,
  });

  @override
  List<Object> get props => [month, sortBy, sortDescending];
}
