import 'package:Spendara/core/crashlytics/crashlytics_keys.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../features/transaction/model/transaction_model.dart';

class TransactionRepository {
  static const _boxName = 'transactions';

  Box<TransactionModel> get _box => Hive.box<TransactionModel>(_boxName);

  static Future<void> init() async {
    await Hive.openBox<TransactionModel>(_boxName);
  }

  // ── CRUD ─────────────────────────────────────────────────
  List<TransactionModel> getAll() {
    try {
      return _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      FirebaseCrashlytics.instance.log(CrashlyticsKeys.transactionFetchAll);
      rethrow;
    }
  }

  void add(TransactionModel t) {
    try {
      _box.put(t.id, t);
    } catch (e) {
      FirebaseCrashlytics.instance.log(CrashlyticsKeys.transactionAdd);
      rethrow;
    }
  }

  void update(TransactionModel t) {
    try {
      _box.put(t.id, t);
    } catch (e) {
      FirebaseCrashlytics.instance.log(CrashlyticsKeys.transactionUpdate);
      rethrow;
    }
  }

  void delete(String id) {
    try {
      _box.delete(id);
    } catch (e) {
      FirebaseCrashlytics.instance.log(CrashlyticsKeys.transactionDelete);
      rethrow;
    }
  }

  TransactionModel? getById(String id) {
    try {
      return _box.get(id);
    } catch (e) {
      FirebaseCrashlytics.instance.log(CrashlyticsKeys.transactionFetchById);
      rethrow;
    }
  }

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
    final expenseTxns = _box.values.where((t) => t.isExpense).toList();

    if (expenseTxns.isEmpty) {
      return List<double>.empty();
    }

    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return expenseTxns
          .where(
            (t) =>
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
