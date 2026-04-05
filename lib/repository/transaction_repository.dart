import 'package:hive_flutter/hive_flutter.dart';
import '../features/transaction/model/transaction_model.dart';

class TransactionRepository {
  static const _boxName = 'transactions';

  Box<TransactionModel> get _box => Hive.box<TransactionModel>(_boxName);

  static Future<void> init() async {
    await Hive.openBox<TransactionModel>(_boxName);
  }

  // ── CRUD ─────────────────────────────────────────────────
  List<TransactionModel> getAll() =>
      _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));

  Future<void> add(TransactionModel t) => _box.put(t.id, t);

  Future<void> update(TransactionModel t) => _box.put(t.id, t);

  Future<void> delete(String id) => _box.delete(id);

  TransactionModel? getById(String id) => _box.get(id);

  // ── Aggregates ────────────────────────────────────────────
  double get totalIncome => _box.values
      .where((t) => t.type == 'income')
      .fold(0.0, (s, t) => s + t.amount);

  double get totalExpenses => _box.values
      .where((t) => t.type == 'expense')
      .fold(0.0, (s, t) => s + t.amount);

  double get balance => totalIncome - totalExpenses;

  // Group by category — for insights
  Map<String, double> get expensesByCategory {
    final map = <String, double>{};
    for (final t in _box.values.where((t) => t.isExpense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    // sort descending
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  // Last 7 days daily totals
  List<double> get last7DaysExpenses {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return _box.values
          .where(
            (t) =>
                t.isExpense &&
                t.date.year == day.year &&
                t.date.month == day.month &&
                t.date.day == day.day,
          )
          .fold(0.0, (s, t) => s + t.amount);
    });
  }

  // Previous 7 days (for week-over-week comparison)
  List<double> get prev7DaysExpenses {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 13 - i));
      return _box.values
          .where(
            (t) =>
                t.isExpense &&
                t.date.year == day.year &&
                t.date.month == day.month &&
                t.date.day == day.day,
          )
          .fold(0.0, (s, t) => s + t.amount);
    });
  }

  List<String> get last7DayLabels {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return days[day.weekday - 1];
    });
  }
}
