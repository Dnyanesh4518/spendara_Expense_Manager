part of 'dashboard_cubit.dart';

enum DashboardStatus { initial, loading, success, error }

class DashboardState extends Equatable {
  final double balance;
  final double totalIncome;
  final double totalExpenses;
  final List<double> weeklySpending; // 7 values, Mon→Sun
  final List<String> weekDayLabels; // 7 values, Mon→Sun
  final List<TransactionModel> recentTransactions;
  final double savingsProgress;
  final DashboardStatus status;
  final String userName;
  final String userEmail;
  final Map<String, double> expensesByCategory;

  const DashboardState({
    this.balance = 0,
    this.totalIncome = 0,
    this.totalExpenses = 0,
    this.weeklySpending = const [],
    this.weekDayLabels = const [],
    this.recentTransactions = const [],
    this.savingsProgress = 0,
    this.status = DashboardStatus.initial,
    this.userName = '',
    this.userEmail = '',
    this.expensesByCategory = const {},
  });

  DashboardState copyWith({
    double? balance,
    double? totalIncome,
    double? totalExpenses,
    List<double>? weeklySpending,
    List<String>? weekDayLabels,
    List<TransactionModel>? recentTransactions,
    double? savingsProgress,
    DashboardStatus? status,
    String? userName,
    String? userEmail,
    Map<String, double>? expensesByCategory,
  }) => DashboardState(
    balance: balance ?? this.balance,
    totalIncome: totalIncome ?? this.totalIncome,
    totalExpenses: totalExpenses ?? this.totalExpenses,
    weeklySpending: weeklySpending ?? this.weeklySpending,
    weekDayLabels: weekDayLabels ?? this.weekDayLabels,
    recentTransactions: recentTransactions ?? this.recentTransactions,
    savingsProgress: savingsProgress ?? this.savingsProgress,
    status: status ?? this.status,
    userName: userName ?? this.userName,
    userEmail: userEmail ?? this.userEmail,
    expensesByCategory: expensesByCategory ?? this.expensesByCategory,
  );

  @override
  List<Object?> get props => [
    balance,
    totalIncome,
    totalExpenses,
    weeklySpending,
    recentTransactions,
    savingsProgress,
    status,
    userName,
    userEmail,
    weekDayLabels,
    expensesByCategory,
  ];
}
