part of 'goal_cubit.dart';

enum GoalStatus { initial, loading, success, error }

class GoalState extends Equatable {
  final List<GoalModel> goals;
  final GoalStatus status;
  final String? errorMessage;

  const GoalState({
    this.goals = const [],
    this.status = GoalStatus.initial,
    this.errorMessage,
  });

  double get totalSaved => goals.fold(0, (s, g) => s + g.savedAmount);
  double get totalTarget => goals.fold(0, (s, g) => s + g.targetAmount);
  double get overallProgress =>
      totalTarget == 0 ? 0 : (totalSaved / totalTarget).clamp(0, 1);

  GoalState copyWith({
    List<GoalModel>? goals,
    GoalStatus? status,
    String? errorMessage,
  }) => GoalState(
    goals: goals ?? this.goals,
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [goals, status, errorMessage];
}
