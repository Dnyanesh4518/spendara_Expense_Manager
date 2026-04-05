import 'package:hive_flutter/adapters.dart';
part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final double amount;
  @HiveField(2)
  final String type; // 'income' | 'expense'
  @HiveField(3)
  final String category;
  @HiveField(4)
  final DateTime date;
  @HiveField(5)
  final String notes;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.notes = '',
  });

  TransactionModel copyWith({
    String? id,
    double? amount,
    String? type,
    String? category,
    DateTime? date,
    String? notes,
  }) => TransactionModel(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    type: type ?? this.type,
    category: category ?? this.category,
    date: date ?? this.date,
    notes: notes ?? this.notes,
  );

  bool get isExpense => type == 'expense';
}
