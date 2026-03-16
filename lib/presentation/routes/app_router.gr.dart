// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter();

  @override
  final Map<String, PageFactory> pagesMap = {
    CameraRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CameraPage(),
      );
    },
    DashboardRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DashboardPage(),
      );
    },
    ExpenseDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<ExpenseDetailsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ExpenseDetailsPage(
          key: args.key,
          expense: args.expense,
        ),
      );
    },
    ExpenseFormRoute.name: (routeData) {
      final args = routeData.argsAs<ExpenseFormRouteArgs>(
          orElse: () => const ExpenseFormRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ExpenseFormPage(
          key: args.key,
          receiptImagePath: args.receiptImagePath,
          merchantName: args.merchantName,
          amount: args.amount,
          extractedText: args.extractedText,
          existingExpense: args.existingExpense,
        ),
      );
    },
    SettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SettingsPage(),
      );
    },
  };
}

/// generated route for
/// [CameraPage]
class CameraRoute extends PageRouteInfo<void> {
  const CameraRoute({List<PageRouteInfo>? children})
      : super(
          CameraRoute.name,
          initialChildren: children,
        );

  static const String name = 'CameraRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [DashboardPage]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
      : super(
          DashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'DashboardRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ExpenseDetailsPage]
class ExpenseDetailsRoute extends PageRouteInfo<ExpenseDetailsRouteArgs> {
  ExpenseDetailsRoute({
    Key? key,
    required Expense expense,
    List<PageRouteInfo>? children,
  }) : super(
          ExpenseDetailsRoute.name,
          args: ExpenseDetailsRouteArgs(
            key: key,
            expense: expense,
          ),
          initialChildren: children,
        );

  static const String name = 'ExpenseDetailsRoute';

  static const PageInfo<ExpenseDetailsRouteArgs> page =
      PageInfo<ExpenseDetailsRouteArgs>(name);
}

class ExpenseDetailsRouteArgs {
  const ExpenseDetailsRouteArgs({
    this.key,
    required this.expense,
  });

  final Key? key;

  final Expense expense;

  @override
  String toString() {
    return 'ExpenseDetailsRouteArgs{key: $key, expense: $expense}';
  }
}

/// generated route for
/// [ExpenseFormPage]
class ExpenseFormRoute extends PageRouteInfo<ExpenseFormRouteArgs> {
  ExpenseFormRoute({
    Key? key,
    String? receiptImagePath,
    String? merchantName,
    double? amount,
    String? extractedText,
    Expense? existingExpense,
    List<PageRouteInfo>? children,
  }) : super(
          ExpenseFormRoute.name,
          args: ExpenseFormRouteArgs(
            key: key,
            receiptImagePath: receiptImagePath,
            merchantName: merchantName,
            amount: amount,
            extractedText: extractedText,
            existingExpense: existingExpense,
          ),
          initialChildren: children,
        );

  static const String name = 'ExpenseFormRoute';

  static const PageInfo<ExpenseFormRouteArgs> page =
      PageInfo<ExpenseFormRouteArgs>(name);
}

class ExpenseFormRouteArgs {
  const ExpenseFormRouteArgs({
    this.key,
    this.receiptImagePath,
    this.merchantName,
    this.amount,
    this.extractedText,
    this.existingExpense,
  });

  final Key? key;

  final String? receiptImagePath;

  final String? merchantName;

  final double? amount;

  final String? extractedText;

  final Expense? existingExpense;

  @override
  String toString() {
    return 'ExpenseFormRouteArgs{key: $key, receiptImagePath: $receiptImagePath, merchantName: $merchantName, amount: $amount, extractedText: $extractedText, existingExpense: $existingExpense}';
  }
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
