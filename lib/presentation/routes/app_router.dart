import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/expense.dart';
import '../pages/dashboard/dashboard_page.dart';
import '../pages/camera/camera_page.dart';
import '../pages/expense/expense_details_page.dart';
import '../pages/expense/expense_form_page.dart';
import '../pages/settings/settings_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: DashboardRoute.page, initial: true),
    CustomRoute(
      page: CameraRoute.page,
      transitionsBuilder: TransitionsBuilders.slideBottom,
      durationInMilliseconds: 350,
    ),
    CustomRoute(
      page: ExpenseDetailsRoute.page,
      transitionsBuilder: TransitionsBuilders.slideRight,
      durationInMilliseconds: 300,
    ),
    CustomRoute(
      page: ExpenseFormRoute.page,
      transitionsBuilder: TransitionsBuilders.slideBottom,
      durationInMilliseconds: 350,
    ),
    CustomRoute(
      page: SettingsRoute.page,
      transitionsBuilder: TransitionsBuilders.slideRight,
      durationInMilliseconds: 300,
    ),
  ];
}
