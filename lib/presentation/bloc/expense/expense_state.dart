part of 'expense_bloc.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object> get props => [];
}

class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();

  @override
  List<Object> get props => [];
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();

  @override
  List<Object> get props => [];
}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;

  const ExpenseLoaded({required this.expenses});

  @override
  List<Object> get props => [expenses];
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object> get props => [message];
}

class ExpenseCategorizing extends ExpenseState {
  const ExpenseCategorizing();

  @override
  List<Object> get props => [];
}

class ExpenseCategorized extends ExpenseState {
  final String category;

  const ExpenseCategorized({required this.category});

  @override
  List<Object> get props => [category];
}

class CategoriesLoaded extends ExpenseState {
  final List<ExpenseCategory> categories;

  const CategoriesLoaded({required this.categories});

  @override
  List<Object> get props => [categories];
}

class DashboardLoaded extends ExpenseState {
  final List<Expense> expenses;
  final double monthlyTotal;
  final double lastMonthTotal;
  final Map<String, double> categoryBreakdown;
  final List<ExpenseCategory> categories;

  const DashboardLoaded({
    required this.expenses,
    required this.monthlyTotal,
    required this.lastMonthTotal,
    required this.categoryBreakdown,
    required this.categories,
  });

  @override
  List<Object> get props =>
      [expenses, monthlyTotal, lastMonthTotal, categoryBreakdown, categories];
}

class ExpenseActionSuccess extends ExpenseState {
  final String message;

  const ExpenseActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}
