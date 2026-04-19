part of 'budget_cubit.dart';

sealed class BudgetState extends Equatable {
  const BudgetState();
  @override
  List<Object?> get props => [];
}

final class BudgetInitial extends BudgetState {
  const BudgetInitial();
}

final class BudgetLoading extends BudgetState {
  const BudgetLoading();
}

final class BudgetLoaded extends BudgetState {
  final BudgetModel? current;
  final int month;
  final int year;

  const BudgetLoaded({
    required this.current,
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [current, month, year];
}
