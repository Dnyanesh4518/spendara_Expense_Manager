import 'package:hive_flutter/hive_flutter.dart';

import '../features/goals/model/goals_model.dart';

class GoalRepository {
  static const _boxName = 'goals';

  Box<GoalModel> get _box => Hive.box<GoalModel>(_boxName);

  static Future<void> init() async {
    await Hive.openBox<GoalModel>(_boxName);
  }

  List<GoalModel> getAll() => _box.values.toList();

  Future<void> add(GoalModel g) => _box.put(g.id, g);

  Future<void> update(GoalModel g) => _box.put(g.id, g);

  Future<void> delete(String id) => _box.delete(id);

  double get totalSaved => _box.values.fold(0.0, (s, g) => s + g.savedAmount);

  double get totalTarget => _box.values.fold(0.0, (s, g) => s + g.targetAmount);
}
