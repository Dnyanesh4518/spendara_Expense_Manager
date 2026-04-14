import 'package:Spendara/core/crashlytics/crashlytics_keys.dart';
import 'package:Spendara/l10n/generated/app_localizations.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
  AppLocalizations? _l10n;

  DashboardCubit(this._txnRepo, this._goalRepo) : super(const DashboardState());

  void load({AppLocalizations? l10n}) {
    if (l10n != null) _l10n = l10n;
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final allTxns = _txnRepo.getAll();
      final recent = allTxns.take(5).toList();
      final weekly = _txnRepo.last7DaysExpenses;
      final daysLabels = _localizedWeekLabels(_txnRepo.last7DayLabels, _l10n);
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
          weekDayLabels: daysLabels,
          recentTransactions: recent,
          savingsProgress: savingsPct,
          status: DashboardStatus.success,
          userName: user?.name ?? '',
          userEmail: user?.email ?? '',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: DashboardStatus.error));
      FirebaseCrashlytics.instance.log(CrashlyticsKeys.dashboardLoad);
    }
  }

  Future<void> updateUser({required String name, required String email}) async {
    final userBox = Hive.box<UserModel>('userBox');
    await userBox.put('current_user', UserModel(name: name, email: email));
    emit(state.copyWith(userName: name, userEmail: email));
  }

  List<String> _localizedWeekLabels(
    List<String> labels,
    AppLocalizations? l10n,
  ) {
    return labels.map((label) {
      switch (label) {
        case 'Mon':
          return l10n?.mon ?? 'Mon';
        case 'Tue':
          return l10n?.tue ?? 'Tue';
        case 'Wed':
          return l10n?.wed ?? 'Wed';
        case 'Thu':
          return l10n?.thu ?? 'Thu';
        case 'Fri':
          return l10n?.fri ?? 'Fri';
        case 'Sat':
          return l10n?.sat ?? 'Sat';
        case 'Sun':
          return l10n?.sun ?? 'Sun';
        default:
          return label;
      }
    }).toList();
  }
}
