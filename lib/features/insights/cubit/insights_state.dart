part of 'insights_cubit.dart';

enum InsightsStatus { initial, loading, success, error }

class InsightsState extends Equatable {
  final Map<String, double> expensesByCategory;
  final List<double> thisWeek;
  final List<double> lastWeek;
  final double thisMonthTotal;
  final double lastMonthTotal;
  final int totalTransactions;
  final String mostFrequentCategory;
  final InsightsStatus status;
  final List<String> weekDayLabels;

  const InsightsState({
    this.expensesByCategory = const {},
    this.thisWeek = const [],
    this.lastWeek = const [],
    this.weekDayLabels = const [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ],
    this.thisMonthTotal = 0,
    this.lastMonthTotal = 0,
    this.totalTransactions = 0,
    this.mostFrequentCategory = '—',
    this.status = InsightsStatus.initial,
  });

  // ── Computed getters ───────────────────────────────────────
  String get topCategory =>
      expensesByCategory.isEmpty ? '—' : expensesByCategory.entries.first.key;

  double get topCategoryAmount =>
      expensesByCategory.isEmpty ? 0 : expensesByCategory.entries.first.value;

  double get thisWeekTotal => thisWeek.fold(0, (s, v) => s + v);
  double get lastWeekTotal => lastWeek.fold(0, (s, v) => s + v);
  double get totalExpenses =>
      expensesByCategory.values.fold(0, (s, v) => s + v);

  // Week-over-week: positive = increased spending, negative = decreased
  double get weekOverWeekPct => lastWeekTotal == 0
      ? 0
      : ((thisWeekTotal - lastWeekTotal) / lastWeekTotal) * 100;

  // Month-over-month
  double get monthOverMonthPct => lastMonthTotal == 0
      ? 0
      : ((thisMonthTotal - lastMonthTotal) / lastMonthTotal) * 100;

  bool get isWeekSpendingUp => weekOverWeekPct > 0;
  bool get isMonthSpendingUp => monthOverMonthPct > 0;

  // Biggest single-day spend in current week
  double get peakDaySpend =>
      thisWeek.isEmpty ? 0 : thisWeek.reduce((a, b) => a > b ? a : b);

  int get peakDayIndex => thisWeek.isEmpty ? 0 : thisWeek.indexOf(peakDaySpend);

  InsightsState copyWith({
    Map<String, double>? expensesByCategory,
    List<double>? thisWeek,
    List<double>? lastWeek,
    double? thisMonthTotal,
    double? lastMonthTotal,
    int? totalTransactions,
    String? mostFrequentCategory,
    InsightsStatus? status,
    List<String>? weekDayLabels,
  }) => InsightsState(
    expensesByCategory: expensesByCategory ?? this.expensesByCategory,
    thisWeek: thisWeek ?? this.thisWeek,
    lastWeek: lastWeek ?? this.lastWeek,
    thisMonthTotal: thisMonthTotal ?? this.thisMonthTotal,
    lastMonthTotal: lastMonthTotal ?? this.lastMonthTotal,
    totalTransactions: totalTransactions ?? this.totalTransactions,
    mostFrequentCategory: mostFrequentCategory ?? this.mostFrequentCategory,
    status: status ?? this.status,
    weekDayLabels: weekDayLabels ?? this.weekDayLabels,
  );

  @override
  List<Object?> get props => [
    expensesByCategory,
    thisWeek,
    lastWeek,
    thisMonthTotal,
    lastMonthTotal,
    totalTransactions,
    mostFrequentCategory,
    status,
    weekDayLabels,
  ];
}
