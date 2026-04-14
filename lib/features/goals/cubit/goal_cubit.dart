import 'package:Spendara/core/crashlytics/crashlytics_keys.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../repository/goal_repository.dart';
import '../model/goals_model.dart';

part 'goal_state.dart';

class GoalCubit extends Cubit<GoalState> {
  final GoalRepository _repo;

  GoalCubit(this._repo) : super(const GoalState());

  void load() {
    emit(state.copyWith(status: GoalStatus.loading));
    try {
      final goals = _repo.getAll();
      emit(state.copyWith(goals: goals, status: GoalStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: GoalStatus.error, errorMessage: e.toString()),
      );
      FirebaseCrashlytics.instance.log(CrashlyticsKeys.goalCubitLoad);
      rethrow;
    }
  }

  Future<void> addGoal(GoalModel g) async {
    _repo.add(g);
    load();
  }

  Future<void> updateGoal(GoalModel g) async {
    _repo.update(g);
    load();
  }

  Future<void> deleteGoal(String id) async {
    _repo.delete(id);
    load();
  }

  // Add money toward a goal
  Future<void> deposit(String id, double amount) async {
    try {
      final goal = _repo.getAll().firstWhere((g) => g.id == id);
      final updated = goal.copyWith(
        savedAmount: (goal.savedAmount + amount).clamp(0, goal.targetAmount),
      );
      _repo.update(updated);
      load();
    } catch (e) {
      FirebaseCrashlytics.instance.log(CrashlyticsKeys.goalCubitDeposit);
      rethrow;
    }
  }
}
