part of 'insights_cubit.dart';

enum TimeRange { week, month, year, custom }

enum ViewMode { overview, category, trends, forecast }

enum InsightsStatus { initial, loading, success, error }

// ── Anomaly data model ──────────────────────────────────────────
class AnomalyItem extends Equatable {
  final String category;
  final double currentAmount;
  final double avgAmount;
  final double pctIncrease;

  const AnomalyItem({
    required this.category,
    required this.currentAmount,
    required this.avgAmount,
    required this.pctIncrease,
  });

  @override
  List<Object?> get props => [category, currentAmount, avgAmount, pctIncrease];
}

// ──────────────────────────────────────────────────────────────────
class InsightsState extends Equatable {
  // ── Filter ───────────────────────────────────────────────────
  final TimeRange timeRange;
  final ViewMode viewMode;
  final DateTime? customStart;
  final DateTime? customEnd;

  // ── Status ───────────────────────────────────────────────────
  final InsightsStatus status;

  // ── Existing fields (unchanged — all widgets that use these still work) ──
  final Map<String, double> expensesByCategory;
  final List<double> thisWeek;
  final List<double> lastWeek;
  final double thisMonthTotal;
  final double lastMonthTotal;
  final int totalTransactions;
  final String mostFrequentCategory;
  final List<String> weekDayLabels;

  // ── Period-aware financials ───────────────────────────────────
  final double currentPeriodExpenses;
  final double prevPeriodExpenses;
  final double currentPeriodIncome;
  final double savingsRate;
  final double prevSavingsRate;

  // ── Trend data ────────────────────────────────────────────────
  final double spendingVelocity; // projected full-month spend
  final List<double> dayOfWeekTotals; // 7 values, Mon=0..Sun=6
  final List<AnomalyItem> anomalies; // categories >20% above 3-month avg
  final List<double> savingsRateTrend; // 12 monthly rates
  final List<String> savingsRateLabels; // 12 month abbreviations
  final String biggestSpikeDay;
  final double biggestSpikeAmount;

  // ── Year view ─────────────────────────────────────────────────
  final List<double> thisYearMonthly; // 12 monthly totals
  final List<double> lastYearMonthly;

  // ── Category view ─────────────────────────────────────────────
  final Map<String, List<double>> top5CategoryHistory; // cat → 6 periods
  final List<String> historyPeriodLabels;
  final Set<String> alertCategories; // cats with >20% spike vs prev period
  final String? selectedCategory; // drill-down selection
  final List<TransactionModel> drillDownTransactions;

  const InsightsState({
    this.timeRange = TimeRange.week,
    this.viewMode = ViewMode.overview,
    this.customStart,
    this.customEnd,
    this.status = InsightsStatus.initial,
    this.expensesByCategory = const {},
    this.thisWeek = const [],
    this.lastWeek = const [],
    this.thisMonthTotal = 0,
    this.lastMonthTotal = 0,
    this.totalTransactions = 0,
    this.mostFrequentCategory = '—',
    this.weekDayLabels = const [],
    this.currentPeriodExpenses = 0,
    this.prevPeriodExpenses = 0,
    this.currentPeriodIncome = 0,
    this.savingsRate = 0,
    this.prevSavingsRate = 0,
    this.spendingVelocity = 0,
    this.dayOfWeekTotals = const [],
    this.anomalies = const [],
    this.savingsRateTrend = const [],
    this.savingsRateLabels = const [],
    this.biggestSpikeDay = '',
    this.biggestSpikeAmount = 0,
    this.thisYearMonthly = const [],
    this.lastYearMonthly = const [],
    this.top5CategoryHistory = const {},
    this.historyPeriodLabels = const [],
    this.alertCategories = const {},
    this.selectedCategory,
    this.drillDownTransactions = const [],
  });

  // ── Existing computed getters (unchanged) ─────────────────────
  String get topCategory =>
      expensesByCategory.isEmpty ? '—' : expensesByCategory.entries.first.key;

  double get topCategoryAmount =>
      expensesByCategory.isEmpty ? 0 : expensesByCategory.entries.first.value;

  double get thisWeekTotal => thisWeek.fold(0, (s, v) => s + v);
  double get lastWeekTotal => lastWeek.fold(0, (s, v) => s + v);

  double get totalExpenses =>
      expensesByCategory.values.fold(0, (s, v) => s + v);

  double get weekOverWeekPct => lastWeekTotal == 0
      ? 0
      : ((thisWeekTotal - lastWeekTotal) / lastWeekTotal) * 100;

  double get monthOverMonthPct => lastMonthTotal == 0
      ? 0
      : ((thisMonthTotal - lastMonthTotal) / lastMonthTotal) * 100;

  bool get isWeekSpendingUp => weekOverWeekPct > 0;
  bool get isMonthSpendingUp => monthOverMonthPct > 0;

  double get peakDaySpend =>
      thisWeek.isEmpty ? 0 : thisWeek.reduce((a, b) => a > b ? a : b);

  int get peakDayIndex => thisWeek.isEmpty ? 0 : thisWeek.indexOf(peakDaySpend);

  // ── New computed getters ───────────────────────────────────────
  double get periodChangeAmt => currentPeriodExpenses - prevPeriodExpenses;
  bool get isPeriodSpendingUp => periodChangeAmt > 0;
  double get periodChangePct => prevPeriodExpenses == 0
      ? 0
      : (periodChangeAmt.abs() / prevPeriodExpenses) * 100;

  String get timeRangeLabel => switch (timeRange) {
    TimeRange.week => 'Week',
    TimeRange.month => 'Month',
    TimeRange.year => 'Year',
    TimeRange.custom => 'Custom',
  };

  InsightsState copyWith({
    TimeRange? timeRange,
    ViewMode? viewMode,
    DateTime? customStart,
    DateTime? customEnd,
    InsightsStatus? status,
    Map<String, double>? expensesByCategory,
    List<double>? thisWeek,
    List<double>? lastWeek,
    double? thisMonthTotal,
    double? lastMonthTotal,
    int? totalTransactions,
    String? mostFrequentCategory,
    List<String>? weekDayLabels,
    String? smartSummary,
    double? currentPeriodExpenses,
    double? prevPeriodExpenses,
    double? currentPeriodIncome,
    double? savingsRate,
    double? prevSavingsRate,
    double? spendingVelocity,
    List<double>? dayOfWeekTotals,
    List<AnomalyItem>? anomalies,
    List<double>? savingsRateTrend,
    List<String>? savingsRateLabels,
    String? biggestSpikeDay,
    double? biggestSpikeAmount,
    List<double>? thisYearMonthly,
    List<double>? lastYearMonthly,
    Map<String, List<double>>? top5CategoryHistory,
    List<String>? historyPeriodLabels,
    Set<String>? alertCategories,
    String? selectedCategory,
    List<TransactionModel>? drillDownTransactions,
    bool clearSelectedCategory = false,
  }) => InsightsState(
    timeRange: timeRange ?? this.timeRange,
    viewMode: viewMode ?? this.viewMode,
    customStart: customStart ?? this.customStart,
    customEnd: customEnd ?? this.customEnd,
    status: status ?? this.status,
    expensesByCategory: expensesByCategory ?? this.expensesByCategory,
    thisWeek: thisWeek ?? this.thisWeek,
    lastWeek: lastWeek ?? this.lastWeek,
    thisMonthTotal: thisMonthTotal ?? this.thisMonthTotal,
    lastMonthTotal: lastMonthTotal ?? this.lastMonthTotal,
    totalTransactions: totalTransactions ?? this.totalTransactions,
    mostFrequentCategory: mostFrequentCategory ?? this.mostFrequentCategory,
    weekDayLabels: weekDayLabels ?? this.weekDayLabels,
    currentPeriodExpenses: currentPeriodExpenses ?? this.currentPeriodExpenses,
    prevPeriodExpenses: prevPeriodExpenses ?? this.prevPeriodExpenses,
    currentPeriodIncome: currentPeriodIncome ?? this.currentPeriodIncome,
    savingsRate: savingsRate ?? this.savingsRate,
    prevSavingsRate: prevSavingsRate ?? this.prevSavingsRate,
    spendingVelocity: spendingVelocity ?? this.spendingVelocity,
    dayOfWeekTotals: dayOfWeekTotals ?? this.dayOfWeekTotals,
    anomalies: anomalies ?? this.anomalies,
    savingsRateTrend: savingsRateTrend ?? this.savingsRateTrend,
    savingsRateLabels: savingsRateLabels ?? this.savingsRateLabels,
    biggestSpikeDay: biggestSpikeDay ?? this.biggestSpikeDay,
    biggestSpikeAmount: biggestSpikeAmount ?? this.biggestSpikeAmount,
    thisYearMonthly: thisYearMonthly ?? this.thisYearMonthly,
    lastYearMonthly: lastYearMonthly ?? this.lastYearMonthly,
    top5CategoryHistory: top5CategoryHistory ?? this.top5CategoryHistory,
    historyPeriodLabels: historyPeriodLabels ?? this.historyPeriodLabels,
    alertCategories: alertCategories ?? this.alertCategories,
    selectedCategory: clearSelectedCategory
        ? null
        : (selectedCategory ?? this.selectedCategory),
    drillDownTransactions: drillDownTransactions ?? this.drillDownTransactions,
  );

  @override
  List<Object?> get props => [
    timeRange,
    viewMode,
    customStart,
    customEnd,
    status,
    expensesByCategory,
    thisWeek,
    lastWeek,
    thisMonthTotal,
    lastMonthTotal,
    totalTransactions,
    mostFrequentCategory,
    weekDayLabels,
    currentPeriodExpenses,
    prevPeriodExpenses,
    currentPeriodIncome,
    savingsRate,
    prevSavingsRate,
    spendingVelocity,
    dayOfWeekTotals,
    anomalies,
    savingsRateTrend,
    savingsRateLabels,
    biggestSpikeDay,
    biggestSpikeAmount,
    thisYearMonthly,
    lastYearMonthly,
    top5CategoryHistory,
    historyPeriodLabels,
    alertCategories,
    selectedCategory,
    drillDownTransactions,
  ];
}
