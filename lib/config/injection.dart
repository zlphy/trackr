import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/dio_client.dart';
import '../core/network/api_service.dart';
import '../core/network/gemini_client.dart';
import '../data/datasources/local/app_database.dart';
import '../data/datasources/local/expense_local_datasource.dart';
import '../data/datasources/local/hive_cache_datasource.dart';
import '../data/datasources/remote/llm_remote_datasource.dart';
import '../data/repositories/expense_repository_impl.dart';
import '../domain/repositories/expense_repository.dart';
import '../domain/usecases/add_expense_usecase.dart';
import '../domain/usecases/get_expenses_usecase.dart';
import '../domain/usecases/categorize_expense_usecase.dart';
import '../domain/usecases/delete_expense_usecase.dart';
import '../domain/usecases/update_expense_usecase.dart';
import '../presentation/bloc/expense/expense_bloc.dart';
import '../presentation/bloc/settings/settings_bloc.dart';
import '../services/ml_kit_service.dart';
import '../services/camera_service.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Core
  sl.registerLazySingleton<DioClient>(() => DioClient(prefs: sl()));
  sl.registerLazySingleton<ApiService>(() => ApiService(sl()));
  sl.registerLazySingleton<GeminiClient>(
    () => GeminiClient(prefs: sl()),
  );

  // Database
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
  sl.registerLazySingleton<ExpenseLocalDataSource>(
    () => ExpenseLocalDataSourceImpl(sl()),
  );

  // Hive cache
  final hiveCache = await HiveCacheDataSourceImpl.create();
  sl.registerLazySingleton<HiveCacheDataSource>(() => hiveCache);

  // Remote data sources
  sl.registerLazySingleton<LLMRemoteDataSource>(
    () => LLMRemoteDataSourceImpl(sl(), sl()),
  );

  // Repositories
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(sl(), sl()),
  );

  // Use cases
  sl.registerLazySingleton<AddExpenseUseCase>(
    () => AddExpenseUseCase(sl()),
  );
  sl.registerLazySingleton<GetExpensesUseCase>(
    () => GetExpensesUseCase(sl()),
  );
  sl.registerLazySingleton<CategorizeExpenseUseCase>(
    () => CategorizeExpenseUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteExpenseUseCase>(
    () => DeleteExpenseUseCase(sl()),
  );
  sl.registerLazySingleton<UpdateExpenseUseCase>(
    () => UpdateExpenseUseCase(sl()),
  );

  // Services
  sl.registerLazySingleton<MLKitService>(() => MLKitService());
  sl.registerLazySingleton<CameraService>(() => CameraService());

  // BLoC
  sl.registerFactory<ExpenseBloc>(
    () => ExpenseBloc(
      addExpenseUseCase: sl(),
      getExpensesUseCase: sl(),
      categorizeExpenseUseCase: sl(),
      deleteExpenseUseCase: sl(),
      updateExpenseUseCase: sl(),
    ),
  );
  sl.registerFactory<SettingsBloc>(() => SettingsBloc(sl()));
}
