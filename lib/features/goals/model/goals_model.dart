import 'package:hive_flutter/adapters.dart';
part 'goals_model.g.dart';

@HiveType(typeId: 1)
class GoalModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final double targetAmount;
  @HiveField(3)
  final double savedAmount;
  @HiveField(4)
  final DateTime deadline;
  @HiveField(5)
  final String iconName; // store icon as string key
  @HiveField(6)
  final int colorValue; // store color as int

  GoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    required this.deadline,
    required this.iconName,
    required this.colorValue,
  });

  double get progress => (savedAmount / targetAmount).clamp(0.0, 1.0);
  double get remaining => targetAmount - savedAmount;

  GoalModel copyWith({
    String? title,
    double? targetAmount,
    double? savedAmount,
    DateTime? deadline,
    String? iconName,
    int? colorValue,
  }) => GoalModel(
    id: id,
    title: title ?? this.title,
    targetAmount: targetAmount ?? this.targetAmount,
    savedAmount: savedAmount ?? this.savedAmount,
    deadline: deadline ?? this.deadline,
    iconName: iconName ?? this.iconName,
    colorValue: colorValue ?? this.colorValue,
  );
}
