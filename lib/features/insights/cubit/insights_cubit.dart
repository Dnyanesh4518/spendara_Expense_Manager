import 'dart:math';
import 'package:Spendara/constants/constants.dart';
import 'package:Spendara/core/crashlytics/crashlytics_keys.dart';
import 'package:Spendara/l10n/generated/app_localizations.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/analytics/analytics_keys.dart';
import '../../../repository/transaction_repository.dart';
import '../../transaction/model/transaction_model.dart';

part 'insights_state.dart';

class InsightsCubit extends Cubit<InsightsState> {
  final TransactionRepository _repo;
  AppLocalizations? _l10n;

  static const _prefTimeRange = 'insights_time_range';
  static const _prefViewMode = 'insights_view_mode';

  InsightsCubit(this._repo) : super(const InsightsState());

  // ── Restore persisted filter on app open ─────────────────────────────────
  Future<void> restoreAndLoad({AppLocalizations? l10n}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ri = prefs.getInt(_prefTimeRange) ?? 0;
      final mi = prefs.getInt(_prefViewMode) ?? 0;
      load(
        timeRange: TimeRange.values[ri.clamp(0, TimeRange.values.length - 1)],
        viewMode: ViewMode.values[mi.clamp(0, ViewMode.values.length - 1)],
        l10n: l10n,
      );
    } catch (_) {
      load(l10n: l10n);
    }
  }

  // ── Switch view mode without reloading data ───────────────────────────────
  Future<void> changeViewMode(ViewMode mode) async {
    emit(state.copyWith(viewMode: mode));
    FirebaseAnalytics.instance.logEvent(
      name: "${AnalyticsKeys.viewMode}_$mode",
    );
    _persistFilter(state.timeRange, mode);
  }

  void selectCategory(String? category) {
    if (category == null) {
      emit(
        state.copyWith(clearSelectedCategory: true, drillDownTransactions: []),
      );
      return;
    }

    // normalizeKey handles any legacy English names gracefully
    // e.g. 'Food & Dining' → 'food_dining'
    final normalizedKey = Constants.normalizeKey(category);

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
              Constants.normalizeKey(t.category) == normalizedKey,
        )
        .toList();

    // selectedCategory stored as STORAGE KEY
    // Display in Widget: Constants.expenseCategoryLabel(context, state.selectedCategory)
    emit(
      state.copyWith(
        selectedCategory: normalizedKey,
        drillDownTransactions: txns,
      ),
    );
  }

  // ── Main load ─────────────────────────────────────────────────────────────
  //
  // [l10n] — pass AppLocalizations.of(context)! from your Widget so chart
  //           labels, smart summary, and month names are localized.
  //           The cubit caches it internally; calls without l10n reuse last value.
  //
  void load({
    TimeRange? timeRange,
    ViewMode? viewMode,
    DateTime? customStart,
    DateTime? customEnd,
    AppLocalizations? l10n,
  }) {
    if (l10n != null) _l10n = l10n;

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

      // ── Period bounds ────────────────────────────────────────────────────
      final (curStart, curEnd) = _periodBounds(range, now, cStart, cEnd);
      final (prevStart, prevEnd) = _prevPeriodBounds(range, now, cStart, cEnd);

      final curTxns = _txnsInRange(allTxns, curStart, curEnd);
      final prevTxns = _txnsInRange(allTxns, prevStart, prevEnd);

      // ── Core financials ──────────────────────────────────────────────────
      final curExp = _totalExpenses(curTxns);
      final prevExp = _totalExpenses(prevTxns);
      final curInc = _totalIncome(curTxns);
      final prevInc = _totalIncome(prevTxns);
      final curSav = _savingsRate(curInc, curExp);
      final prevSav = _savingsRate(prevInc, prevExp);

      // Keys in these maps are STORAGE KEYS — widgets localize via Constants
      final curByCat = _expensesByCategory(curTxns);
      final prevByCat = _expensesByCategory(prevTxns);

      // ── Existing weekly/monthly fields ───────────────────────────────────
      final thisMonthStart = DateTime(now.year, now.month, 1);
      final lastMonthStart = DateTime(now.year, now.month - 1, 1);
      final thisMonthEnd = DateTime(now.year, now.month + 1, 1);

      final freqMap = <String, int>{};
      for (final t in allTxns.where((t) => t.isExpense)) {
        freqMap[Constants.normalizeKey(t.category)] =
            (freqMap[Constants.normalizeKey(t.category)] ?? 0) + 1;
      }
      // Stored as STORAGE KEY — localize in widget:
      // Constants.expenseCategoryLabel(context, state.mostFrequentCategory)
      final mostFrequent = freqMap.isEmpty
          ? '—'
          : (freqMap.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value)))
                .first
                .key;

      // ── Advanced computations ────────────────────────────────────────────
      final (spikeDay, spikeAmt) = _biggestSpikeDay(curTxns);
      final (sRateTrend, sRateLbls) = _savingsRateTrend(allTxns, now);
      final (top5Hist, histLbls) = _top5CategoryHistory(allTxns, range, now);
      final localizedWeekLabels = _localizedWeekLabels(
        _repo.last7DayLabels,
        _l10n,
      );

      _persistFilter(range, mode);

      emit(
        state.copyWith(
          status: InsightsStatus.success,
          timeRange: range,
          viewMode: mode,
          customStart: cStart,
          customEnd: cEnd,
          // ── Existing fields ──
          expensesByCategory: curByCat, // map keys = STORAGE KEYS
          thisWeek: _repo.last7DaysExpenses,
          lastWeek: _repo.prev7DaysExpenses,
          weekDayLabels: localizedWeekLabels,
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
          mostFrequentCategory: mostFrequent, // STORAGE KEY
          // ── New / advanced fields ──
          currentPeriodExpenses: curExp,
          prevPeriodExpenses: prevExp,
          currentPeriodIncome: curInc,
          savingsRate: curSav,
          prevSavingsRate: prevSav,
          spendingVelocity: _spendingVelocity(curTxns, curStart, range),
          dayOfWeekTotals: _dayOfWeekTotals(curTxns),
          anomalies: _detectAnomalies(curByCat, allTxns),
          savingsRateTrend: sRateTrend,
          savingsRateLabels: sRateLbls, // localized month abbrs
          biggestSpikeDay: spikeDay, // localized "15 Jan" / "15 जन"
          biggestSpikeAmount: spikeAmt,
          thisYearMonthly: _yearlyMonthly(allTxns, now.year),
          lastYearMonthly: _yearlyMonthly(allTxns, now.year - 1),
          top5CategoryHistory: top5Hist, // keys = STORAGE KEYS
          historyPeriodLabels: histLbls, // localized month/date labels
          alertCategories: _alertCategories(curByCat, prevByCat),
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: InsightsStatus.error));
      FirebaseCrashlytics.instance.log(CrashlyticsKeys.insightsLoad);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // LOCALIZATION HELPERS (private — used only inside InsightsCubit)
  // ──────────────────────────────────────────────────────────────────────────
  List<String> _monthAbbr() {
    final l = _l10n;
    if (l == null) {
      return const [
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
    }
    return [
      l.jan,
      l.feb,
      l.mar,
      l.apr,
      l.may,
      l.jun,
      l.jul,
      l.aug,
      l.sep,
      l.oct,
      l.nov,
      l.dec,
    ];
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PERIOD BOUNDS
  // ──────────────────────────────────────────────────────────────────────────

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

  // ──────────────────────────────────────────────────────────────────────────
  // DATA HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  List<TransactionModel> _txnsInRange(
    List<TransactionModel> all,
    DateTime start,
    DateTime end,
  ) => all
      .where((t) => !t.date.isBefore(start) && t.date.isBefore(end))
      .toList();

  /// Returns {STORAGE_KEY → totalAmount}, sorted descending.
  /// normalizeKey is applied so legacy English-named transactions still group correctly.
  Map<String, double> _expensesByCategory(List<TransactionModel> txns) {
    final map = <String, double>{};
    for (final t in txns.where((t) => t.isExpense)) {
      final key = Constants.normalizeKey(t.category);
      map[key] = (map[key] ?? 0) + t.amount;
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

  // ──────────────────────────────────────────────────────────────────────────
  // TREND COMPUTATIONS
  // ──────────────────────────────────────────────────────────────────────────

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
    return (_totalExpenses(txns) / daysElapsed) * totalDays;
  }

  List<double> _dayOfWeekTotals(List<TransactionModel> txns) {
    final totals = List.filled(7, 0.0);
    for (final t in txns.where((t) => t.isExpense)) {
      totals[t.date.weekday - 1] += t.amount;
    }
    return totals;
  }

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
            .where(
              (t) =>
                  t.isExpense &&
                  Constants.normalizeKey(t.category) == entry.key,
            ) // key vs key
            .fold(0.0, (sum, t) => sum + t.amount);
      }
      final avg = total / lookback;
      if (avg > 0 && entry.value > avg * 1.2) {
        items.add(
          AnomalyItem(
            category: entry.key, // STORAGE KEY
            currentAmount: entry.value,
            avgAmount: avg,
            pctIncrease: ((entry.value - avg) / avg) * 100,
          ),
        );
      }
    }
    return items..sort((a, b) => b.pctIncrease.compareTo(a.pctIncrease));
  }

  /// Savings rate for the last 12 calendar months.
  /// Labels use localized month abbreviations.
  (List<double>, List<String>) _savingsRateTrend(
    List<TransactionModel> allTxns,
    DateTime now,
  ) {
    final abbr = _monthAbbr(); // ← localized
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
  ///
  /// Internally groups by ISO date string (YYYY-MM-DD) — completely
  /// language-neutral so comparisons never break.
  /// The returned display label uses a localized month abbreviation.
  (String, double) _biggestSpikeDay(List<TransactionModel> txns) {
    final map = <String, double>{}; // key = 'YYYY-MM-DD'

    for (final t in txns.where((t) => t.isExpense)) {
      final isoKey =
          '${t.date.year}-'
          '${t.date.month.toString().padLeft(2, '0')}-'
          '${t.date.day.toString().padLeft(2, '0')}';
      map[isoKey] = (map[isoKey] ?? 0) + t.amount;
    }

    if (map.isEmpty) return ('—', 0);

    final peak = map.entries.reduce((a, b) => a.value > b.value ? a : b);
    final parts = peak.key.split('-');
    final day = int.parse(parts[2]);
    final month = int.parse(parts[1]);

    // Localized display label: "15 Jan" / "15 जन" / "15 ม.ค."
    final displayLabel = '$day ${_monthAbbr()[month - 1]}';
    return (displayLabel, peak.value);
  }

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

  /// Top 5 categories by all-time spend, with 6-period history each.
  /// Map keys = STORAGE KEYS; labels = localized month/date strings.
  (Map<String, List<double>>, List<String>) _top5CategoryHistory(
    List<TransactionModel> allTxns,
    TimeRange range,
    DateTime now,
  ) {
    final abbr = _monthAbbr();

    // ✅ Step 1: Pre-compute the 6 period bounds + labels first
    final periodBounds = <(DateTime, DateTime)>[];
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
      periodBounds.add((pStart, pEnd));
      labels.add(label);
    }

    // ✅ Step 2: Sum spending PER CATEGORY across only those 6 displayed periods
    final totalAcrossPeriods = <String, double>{};
    for (final (pStart, pEnd) in periodBounds) {
      for (final t in _txnsInRange(
        allTxns,
        pStart,
        pEnd,
      ).where((t) => t.isExpense)) {
        final key = Constants.normalizeKey(t.category);
        totalAcrossPeriods[key] = (totalAcrossPeriods[key] ?? 0) + t.amount;
      }
    }

    // ✅ Step 3: Pick top 5 sorted by highest total spend in those 6 periods
    final top5 =
        (totalAcrossPeriods.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .take(5)
            .map((e) => e.key)
            .toList();

    if (top5.isEmpty) return ({}, labels);

    // ✅ Step 4: Build per-period history for only those top 5
    final history = <String, List<double>>{for (final c in top5) c: []};
    for (final (pStart, pEnd) in periodBounds) {
      final pTxns = _txnsInRange(allTxns, pStart, pEnd);
      for (final cat in top5) {
        history[cat]!.add(
          pTxns
              .where(
                (t) => t.isExpense && Constants.normalizeKey(t.category) == cat,
              )
              .fold(0.0, (s, t) => s + t.amount),
        );
      }
    }

    return (history, labels);
  }

  List<String> _localizedWeekLabels(
    List<String> labels,
    AppLocalizations? l10n,
  ) {
    return labels.map((label) {
      switch (label) {
        case 'Mon':
          return l10n?.mon ?? 'Mon';
        case 'Tue':
          return l10n?.tue ?? 'Tue';
        case 'Wed':
          return l10n?.wed ?? 'Wed';
        case 'Thu':
          return l10n?.thu ?? 'Thu';
        case 'Fri':
          return l10n?.fri ?? 'Fri';
        case 'Sat':
          return l10n?.sat ?? 'Sat';
        case 'Sun':
          return l10n?.sun ?? 'Sun';
        default:
          return label;
      }
    }).toList();
  }

  /// Categories where current period > previous period × 1.2.
  /// Returns a Set of STORAGE KEYS.
  Set<String> _alertCategories(
    Map<String, double> current,
    Map<String, double> prev,
  ) {
    final alerts = <String>{};
    for (final e in current.entries) {
      final p = prev[e.key] ?? 0;
      if (p > 0 && e.value > p * 1.2) alerts.add(e.key); // key vs key ✅
    }
    return alerts;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PERSISTENCE
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _persistFilter(TimeRange range, ViewMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefTimeRange, range.index);
      await prefs.setInt(_prefViewMode, mode.index);
    } catch (_) {}
  }
}
