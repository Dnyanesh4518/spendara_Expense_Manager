import 'package:Spendara/core/crashlytics/crashlytics_keys.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../features/goals/model/goals_model.dart';

class GoalRepository {
  static const _boxName = 'goals';

  Box<GoalModel> get _box => Hive.box<GoalModel>(_boxName);

  static Future<void> init() async {
    await Hive.openBox<GoalModel>(_boxName);
  }

  List<GoalModel> getAll() {
    try {
      return _box.values.toList();
    } catch (e) {
      FirebaseCrashlytics.instance.log(CrashlyticsKeys.goalFetchAll);
      rethrow;
    }
  }

  void add(GoalModel g) {
    try {
      _box.put(g.id, g);
    } catch (e) {
      FirebaseCrashlytics.instance.log(CrashlyticsKeys.goalAdd);
      rethrow;
    }
  }

  void update(GoalModel g) {
    try {
      _box.put(g.id, g);
    } catch (e) {
      FirebaseCrashlytics.instance.log(CrashlyticsKeys.goalUpdate);
      rethrow;
    }
  }

  void delete(String id) {
    try {
      _box.delete(id);
    } catch (e) {
      FirebaseCrashlytics.instance.log(CrashlyticsKeys.goalDelete);
      rethrow;
    }
  }

  double get totalSaved => _box.values.fold(0.0, (s, g) => s + g.savedAmount);

  double get totalTarget => _box.values.fold(0.0, (s, g) => s + g.targetAmount);
}
