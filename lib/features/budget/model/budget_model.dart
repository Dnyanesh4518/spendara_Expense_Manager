import 'package:hive_flutter/adapters.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 2)
class BudgetModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final int month; // 1–12
  @HiveField(2)
  final int year;
  @HiveField(3)
  final double totalBudget;
  @HiveField(4)
  final Map<String, double> categoryBudgets; // key → allocated
  @HiveField(5)
  final Map<String, int> priorities; // key → 1/2/3

  BudgetModel({
    required this.id,
    required this.month,
    required this.year,
    required this.totalBudget,
    required this.categoryBudgets,
    required this.priorities,
  });

  BudgetModel copyWith({
    double? totalBudget,
    Map<String, double>? categoryBudgets,
    Map<String, int>? priorities,
  }) => BudgetModel(
    id: id,
    month: month,
    year: year,
    totalBudget: totalBudget ?? this.totalBudget,
    categoryBudgets: categoryBudgets ?? this.categoryBudgets,
    priorities: priorities ?? this.priorities,
  );

  double get totalAllocated =>
      categoryBudgets.values.fold(0.0, (s, v) => s + v);

  bool get isOverAllocated => totalAllocated > totalBudget;
}
