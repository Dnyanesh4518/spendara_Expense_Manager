import 'package:hive_flutter/hive_flutter.dart';
import '../features/budget/model/budget_model.dart';

class BudgetRepository {
  static const _boxName = 'budgetBox';

  Box<BudgetModel> get _box => Hive.box<BudgetModel>(_boxName);

  static Future<void> init() async {
    await Hive.openBox<BudgetModel>(_boxName);
  }

  // ── CRUD ────────────────────────────────────────────────────
  Future<void> save(BudgetModel b) => _box.put(b.id, b);

  Future<void> delete(String id) => _box.delete(id);

  BudgetModel? getForMonth(int month, int year) {
    try {
      return _box.values.firstWhere((b) => b.month == month && b.year == year);
    } catch (_) {
      return null;
    }
  }

  List<BudgetModel> getAll() => _box.values.toList()
    ..sort((a, b) {
      final aDate = DateTime(a.year, a.month);
      final bDate = DateTime(b.year, b.month);
      return bDate.compareTo(aDate); // newest first
    });
}
