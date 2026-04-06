import 'dart:math';
import 'package:Spendara/constants/constants.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../repository/transaction_repository.dart';
import '../../transaction/model/transaction_model.dart';

part 'insights_state.dart';

class InsightsCubit extends Cubit<InsightsState> {
  final TransactionRepository _repo;

  static const _prefTimeRange = 'insights_time_range';
  static const _prefViewMode = 'insights_view_mode';

  InsightsCubit(this._repo) : super(const InsightsState());

  // ── Restore persisted filter on app open ─────────────────────
  // Call this instead of plain load() from AppShell tab switch
  Future<void> restoreAndLoad() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ri = prefs.getInt(_prefTimeRange) ?? 0;
      final mi = prefs.getInt(_prefViewMode) ?? 0;
      load(
        timeRange: TimeRange.values[ri.clamp(0, TimeRange.values.length - 1)],
        viewMode: ViewMode.values[mi.clamp(0, ViewMode.values.length - 1)],
      );
    } catch (_) {
      load();
    }
  }

  // ── Switch view mode without reloading data from Hive ─────────
  Future<void> changeViewMode(ViewMode mode) async {
    emit(state.copyWith(viewMode: mode));
    _persistFilter(state.timeRange, mode);
  }

  // ── Select / deselect a category for drill-down ───────────────
  void selectCategory(String? category, BuildContext context) {
    if (category == null) {
      emit(
        state.copyWith(clearSelectedCategory: true, drillDownTransactions: []),
      );
      return;
    }
    final now = DateTime.now();
    final (start, end) = _periodBounds(
      state.timeRange,
      now,
      state.customStart,
      state.customEnd,
    );
    final txns = _txnsInRange(_repo.getAll(), start, end)
        .where(
          (t) =>
              t.isExpense &&
              Constants.expenseCategoryLabel(context, t.category) == category,
        )
        .toList();
    emit(
      state.copyWith(selectedCategory: category, drillDownTransactions: txns),
    );
  }

  // ── Main load — called on tab switch or filter change ─────────
  void load({
    TimeRange? timeRange,
    ViewMode? viewMode,
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    final range = timeRange ?? state.timeRange;
    final mode = viewMode ?? state.viewMode;
    final cStart = customStart ?? state.customStart;
    final cEnd = customEnd ?? state.customEnd;

    emit(
      state.copyWith(
        status: InsightsStatus.loading,
        timeRange: range,
        viewMode: mode,
        customStart: cStart,
        customEnd: cEnd,
      ),
    );

    try {
      final allTxns = _repo.getAll();
      final now = DateTime.now();

      // ── Period bounds ──────────────────────────────────────────
      final (curStart, curEnd) = _periodBounds(range, now, cStart, cEnd);
      final (prevStart, prevEnd) = _prevPeriodBounds(range, now, cStart, cEnd);

      final curTxns = _txnsInRange(allTxns, curStart, curEnd);
      final prevTxns = _txnsInRange(allTxns, prevStart, prevEnd);

      // ── Core financials ────────────────────────────────────────
      final curExp = _totalExpenses(curTxns);
      final prevExp = _totalExpenses(prevTxns);
      final curInc = _totalIncome(curTxns);
      final prevInc = _totalIncome(prevTxns);
      final curSav = _savingsRate(curInc, curExp);
      final prevSav = _savingsRate(prevInc, prevExp);
      final curByCat = _expensesByCategory(curTxns);
      final prevByCat = _expensesByCategory(prevTxns);

      // ── Existing weekly/monthly fields (always computed) ───────
      final thisMonthStart = DateTime(now.year, now.month, 1);
      final lastMonthStart = DateTime(now.year, now.month - 1, 1);
      final thisMonthEnd = DateTime(now.year, now.month + 1, 1);

      final freqMap = <String, int>{};
      for (final t in allTxns.where((t) => t.isExpense)) {
        freqMap[t.category] = (freqMap[t.category] ?? 0) + 1;
      }
      final mostFrequent = freqMap.isEmpty
          ? '—'
          : (freqMap.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value)))
                .first
                .key;

      // ── Advanced computations ──────────────────────────────────
      final (spikeDay, spikeAmt) = _biggestSpikeDay(curTxns);
      final (sRateTrend, sRateLabels) = _savingsRateTrend(allTxns, now);
      final (top5Hist, histLabels) = _top5CategoryHistory(allTxns, range, now);

      _persistFilter(range, mode);

      emit(
        state.copyWith(
          status: InsightsStatus.success,
          timeRange: range,
          viewMode: mode,
          customStart: cStart,
          customEnd: cEnd,
          // ── Existing fields ──
          expensesByCategory: curByCat,
          thisWeek: _repo.last7DaysExpenses,
          lastWeek: _repo.prev7DaysExpenses,
          weekDayLabels: _repo.last7DayLabels,
          thisMonthTotal: _txnsInRange(
            allTxns,
            thisMonthStart,
            thisMonthEnd,
          ).where((t) => t.isExpense).fold(0.0, (s, t) => s! + t.amount),
          lastMonthTotal: _txnsInRange(
            allTxns,
            lastMonthStart,
            thisMonthStart,
          ).where((t) => t.isExpense).fold(0.0, (s, t) => s! + t.amount),
          totalTransactions: allTxns.length,
          mostFrequentCategory: mostFrequent,
          // ── New fields ──
          smartSummary: _buildSmartSummary(
            curExp,
            prevExp,
            curInc,
            curByCat,
            prevByCat,
            curSav,
            prevSav,
            range,
          ),
          currentPeriodExpenses: curExp,
          prevPeriodExpenses: prevExp,
          currentPeriodIncome: curInc,
          savingsRate: curSav,
          prevSavingsRate: prevSav,
          spendingVelocity: _spendingVelocity(curTxns, curStart, range),
          dayOfWeekTotals: _dayOfWeekTotals(curTxns),
          anomalies: _detectAnomalies(curByCat, allTxns),
          savingsRateTrend: sRateTrend,
          savingsRateLabels: sRateLabels,
          biggestSpikeDay: spikeDay,
          biggestSpikeAmount: spikeAmt,
          thisYearMonthly: _yearlyMonthly(allTxns, now.year),
          lastYearMonthly: _yearlyMonthly(allTxns, now.year - 1),
          top5CategoryHistory: top5Hist,
          historyPeriodLabels: histLabels,
          alertCategories: _alertCategories(curByCat, prevByCat),
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: InsightsStatus.error));
    }
  }

  // ──────────────────────────────────────────────────────────────
  // PERIOD BOUNDS
  // ──────────────────────────────────────────────────────────────

  (DateTime, DateTime) _periodBounds(
    TimeRange range,
    DateTime now,
    DateTime? cStart,
    DateTime? cEnd,
  ) {
    switch (range) {
      case TimeRange.week:
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final s = DateTime(monday.year, monday.month, monday.day);
        return (s, s.add(const Duration(days: 7)));
      case TimeRange.month:
        return (
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 1),
        );
      case TimeRange.year:
        return (DateTime(now.year, 1, 1), DateTime(now.year + 1, 1, 1));
      case TimeRange.custom:
        final s = cStart ?? now.subtract(const Duration(days: 30));
        final e = cEnd ?? now;
        return (s, DateTime(e.year, e.month, e.day + 1));
    }
  }

  (DateTime, DateTime) _prevPeriodBounds(
    TimeRange range,
    DateTime now,
    DateTime? cStart,
    DateTime? cEnd,
  ) {
    switch (range) {
      case TimeRange.week:
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final s = DateTime(
          monday.year,
          monday.month,
          monday.day,
        ).subtract(const Duration(days: 7));
        return (s, s.add(const Duration(days: 7)));
      case TimeRange.month:
        return (
          DateTime(now.year, now.month - 1, 1),
          DateTime(now.year, now.month, 1),
        );
      case TimeRange.year:
        return (DateTime(now.year - 1, 1, 1), DateTime(now.year, 1, 1));
      case TimeRange.custom:
        final s = cStart ?? now.subtract(const Duration(days: 30));
        final e = cEnd ?? now;
        final dur = e.difference(s);
        return (s.subtract(dur), s);
    }
  }

  // ──────────────────────────────────────────────────────────────
  // DATA HELPERS
  // ──────────────────────────────────────────────────────────────

  List<TransactionModel> _txnsInRange(
    List<TransactionModel> all,
    DateTime start,
    DateTime end,
  ) => all
      .where((t) => !t.date.isBefore(start) && t.date.isBefore(end))
      .toList();

  Map<String, double> _expensesByCategory(List<TransactionModel> txns) {
    final map = <String, double>{};
    for (final t in txns.where((t) => t.isExpense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  double _totalExpenses(List<TransactionModel> txns) =>
      txns.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount);

  double _totalIncome(List<TransactionModel> txns) =>
      txns.where((t) => !t.isExpense).fold(0.0, (s, t) => s + t.amount);

  double _savingsRate(double income, double expenses) =>
      income <= 0 ? 0 : ((income - expenses) / income * 100).clamp(0, 100);

  // ──────────────────────────────────────────────────────────────
  // TREND COMPUTATIONS
  // ──────────────────────────────────────────────────────────────

  /// Linear projection: if you keep spending at today's rate,
  /// how much will you spend by end of month?
  double _spendingVelocity(
    List<TransactionModel> txns,
    DateTime periodStart,
    TimeRange range,
  ) {
    if (range != TimeRange.month) return 0;
    final now = DateTime.now();
    final daysElapsed = max(1, now.difference(periodStart).inDays + 1);
    final totalDays = max(
      1,
      DateTime(now.year, now.month + 1, 1).difference(periodStart).inDays,
    );
    final spent = _totalExpenses(txns);
    return (spent / daysElapsed) * totalDays;
  }

  /// Sum all expenses per day-of-week.
  /// Returns list of 7 values: index 0 = Monday, index 6 = Sunday.
  List<double> _dayOfWeekTotals(List<TransactionModel> txns) {
    final totals = List.filled(7, 0.0);
    for (final t in txns.where((t) => t.isExpense)) {
      totals[t.date.weekday - 1] += t.amount;
    }
    return totals;
  }

  /// Compare current period per category to 3-month average.
  /// Flags any category where current > avg * 1.2 (>20% higher).
  List<AnomalyItem> _detectAnomalies(
    Map<String, double> curByCat,
    List<TransactionModel> allTxns,
  ) {
    final now = DateTime.now();
    const lookback = 3;
    final items = <AnomalyItem>[];

    for (final entry in curByCat.entries) {
      double total = 0;
      for (int i = 1; i <= lookback; i++) {
        final s = DateTime(now.year, now.month - i, 1);
        final e = DateTime(now.year, now.month - i + 1, 1);
        total += _txnsInRange(allTxns, s, e)
            .where((t) => t.isExpense && t.category == entry.key)
            .fold(0.0, (sum, t) => sum + t.amount);
      }
      final avg = total / lookback;
      if (avg > 0 && entry.value > avg * 1.2) {
        items.add(
          AnomalyItem(
            category: entry.key,
            currentAmount: entry.value,
            avgAmount: avg,
            pctIncrease: ((entry.value - avg) / avg) * 100,
          ),
        );
      }
    }
    return items..sort((a, b) => b.pctIncrease.compareTo(a.pctIncrease));
  }

  /// Savings rate % for the last 12 calendar months.
  (List<double>, List<String>) _savingsRateTrend(
    List<TransactionModel> allTxns,
    DateTime now,
  ) {
    const abbr = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final rates = <double>[];
    final labels = <String>[];
    for (int i = 11; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      final s = DateTime(d.year, d.month, 1);
      final e = DateTime(d.year, d.month + 1, 1);
      final m = _txnsInRange(allTxns, s, e);
      rates.add(_savingsRate(_totalIncome(m), _totalExpenses(m)));
      labels.add(abbr[d.month - 1]);
    }
    return (rates, labels);
  }

  /// The single day with the highest total expense in the period.
  (String, double) _biggestSpikeDay(List<TransactionModel> txns) {
    final map = <String, double>{};
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    for (final t in txns.where((t) => t.isExpense)) {
      final key = '${t.date.day} ${months[t.date.month]}';
      map[key] = (map[key] ?? 0) + t.amount;
    }
    if (map.isEmpty) return ('—', 0);
    final peak = map.entries.reduce((a, b) => a.value > b.value ? a : b);
    return (peak.key, peak.value);
  }

  /// Monthly expense totals for all 12 months of a given year.
  List<double> _yearlyMonthly(List<TransactionModel> allTxns, int year) =>
      List.generate(12, (i) {
        final s = DateTime(year, i + 1, 1);
        final e = DateTime(year, i + 2, 1);
        return _txnsInRange(
          allTxns,
          s,
          e,
        ).where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount);
      });

  /// Top 5 categories by all-time spend, with 6 period history each.
  (Map<String, List<double>>, List<String>) _top5CategoryHistory(
    List<TransactionModel> allTxns,
    TimeRange range,
    DateTime now,
  ) {
    const abbr = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final allByCat = _expensesByCategory(allTxns);
    final top5 = allByCat.keys.take(5).toList();
    final history = <String, List<double>>{for (final c in top5) c: []};
    final labels = <String>[];

    for (int i = 5; i >= 0; i--) {
      late DateTime pStart, pEnd;
      late String label;
      switch (range) {
        case TimeRange.week:
        case TimeRange.custom:
          final d = now.subtract(Duration(days: now.weekday - 1 + i * 7));
          pStart = DateTime(d.year, d.month, d.day);
          pEnd = pStart.add(const Duration(days: 7));
          label = '${pStart.day} ${abbr[pStart.month - 1]}';
          break;
        case TimeRange.month:
        case TimeRange.year:
          pStart = DateTime(now.year, now.month - i, 1);
          pEnd = DateTime(now.year, now.month - i + 1, 1);
          label = abbr[(pStart.month - 1) % 12];
          break;
      }
      labels.add(label);
      final pTxns = _txnsInRange(allTxns, pStart, pEnd);
      for (final cat in top5) {
        history[cat]!.add(
          pTxns
              .where((t) => t.isExpense && t.category == cat)
              .fold(0.0, (s, t) => s + t.amount),
        );
      }
    }
    return (history, labels);
  }

  /// Categories where current period > previous period * 1.2.
  Set<String> _alertCategories(
    Map<String, double> current,
    Map<String, double> prev,
  ) {
    final alerts = <String>{};
    for (final e in current.entries) {
      final p = prev[e.key] ?? 0;
      if (p > 0 && e.value > p * 1.2) alerts.add(e.key);
    }
    return alerts;
  }

  // ──────────────────────────────────────────────────────────────
  // SMART SUMMARY — template-based, no AI
  // ──────────────────────────────────────────────────────────────

  String _buildSmartSummary(
    double curExp,
    double prevExp,
    double curInc,
    Map<String, double> curByCat,
    Map<String, double> prevByCat,
    double savingsRate,
    double prevSavingsRate,
    TimeRange range,
  ) {
    String compact(double v) {
      if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
      if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(1)}K';
      return '₹${v.toStringAsFixed(0)}';
    }

    final label = switch (range) {
      TimeRange.week => 'week',
      TimeRange.month => 'month',
      TimeRange.year => 'year',
      TimeRange.custom => 'period',
    };

    final diff = curExp - prevExp;
    String body;

    if (prevExp == 0) {
      body = 'You spent ${compact(curExp)} this $label.';
    } else if (diff > 0) {
      final drivers = <String>[];
      for (final e in curByCat.entries) {
        final p = prevByCat[e.key] ?? 0;
        if (e.value > p && drivers.length < 2) {
          drivers.add('${e.key.split(' ').first} (+${compact(e.value - p)})');
        }
      }
      body = 'This $label you spent ${compact(diff)} more than last $label.';
      if (drivers.isNotEmpty) {
        body += ' ${drivers.join(' and ')} drove the increase.';
      }
    } else if (diff < 0) {
      body =
          'Great job! You spent ${compact(diff.abs())} less than last $label. 🎉';
    } else {
      body = 'Your spending this $label matches last $label.';
    }

    if (curInc > 0) {
      final savChange = savingsRate - prevSavingsRate;
      body += ' Saving ${savingsRate.toStringAsFixed(0)}% of income';
      if (savChange > 2) {
        body +=
            ' — up from ${prevSavingsRate.toStringAsFixed(0)}% last $label. 🎉';
      } else if (savChange < -2) {
        body +=
            ' — down from ${prevSavingsRate.toStringAsFixed(0)}% last $label.';
      } else {
        body += '.';
      }
    }

    return body;
  }

  Future<void> _persistFilter(TimeRange range, ViewMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefTimeRange, range.index);
      await prefs.setInt(_prefViewMode, mode.index);
    } catch (_) {}
  }
}
