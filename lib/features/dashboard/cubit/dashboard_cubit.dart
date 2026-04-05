import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';

import '../../../data/models/user_model.dart';
import '../../../repository/goal_repository.dart';
import '../../../repository/transaction_repository.dart';
import '../../transaction/model/transaction_model.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final TransactionRepository _txnRepo;
  final GoalRepository _goalRepo;

  DashboardCubit(this._txnRepo, this._goalRepo) : super(const DashboardState());

  void load() {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final allTxns = _txnRepo.getAll();
      final recent = allTxns.take(5).toList();
      final weekly = _txnRepo.last7DaysExpenses;
      final totalGoal = _goalRepo.totalTarget;
      final totalSaved = _goalRepo.totalSaved;
      final savingsPct = totalGoal == 0
          ? 0.0
          : (totalSaved / totalGoal).clamp(0.0, 1.0);

      final userBox = Hive.box<UserModel>('userBox');
      final user = userBox.get('current_user');
      emit(
        state.copyWith(
          balance: _txnRepo.balance,
          totalIncome: _txnRepo.totalIncome,
          totalExpenses: _txnRepo.totalExpenses,
          weeklySpending: weekly,
          recentTransactions: recent,
          savingsProgress: savingsPct,
          status: DashboardStatus.success,
          userName: user?.name ?? '',
          userEmail: user?.email ?? '',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: DashboardStatus.error));
    }
  }

  Future<void> updateUser({required String name, required String email}) async {
    final userBox = Hive.box<UserModel>('userBox');
    await userBox.put('current_user', UserModel(name: name, email: email));
    emit(state.copyWith(userName: name, userEmail: email));
  }
}
