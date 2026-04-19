import 'package:get_it/get_it.dart';
import '../../features/budget/cubit/budget_cubit.dart';
import '../../features/dashboard/cubit/dashboard_cubit.dart';
import '../../features/goals/cubit/goal_cubit.dart';
import '../../features/insights/cubit/insights_cubit.dart';
import '../../features/transaction/cubit/transaction_cubit.dart';
import '../../repository/budget_repository.dart';
import '../../repository/goal_repository.dart';
import '../../repository/transaction_repository.dart';

final getIt = GetIt.instance;

void setupDI() {
  // Repositories — singletons, one instance for entire app lifetime
  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepository(),
  );
  getIt.registerLazySingleton<GoalRepository>(() => GoalRepository());

  // Cubits — factories, new instance per registration call
  getIt.registerFactory<TransactionCubit>(
    () => TransactionCubit(getIt<TransactionRepository>()),
  );
  getIt.registerFactory<GoalCubit>(() => GoalCubit(getIt<GoalRepository>()));
  getIt.registerFactory<DashboardCubit>(
    () =>
        DashboardCubit(getIt<TransactionRepository>(), getIt<GoalRepository>()),
  );
  getIt.registerFactory<InsightsCubit>(
    () => InsightsCubit(getIt<TransactionRepository>()),
  );

  getIt.registerLazySingleton<BudgetRepository>(() => BudgetRepository());
  getIt.registerFactory<BudgetCubit>(
    () => BudgetCubit(getIt<BudgetRepository>()),
  );
}
