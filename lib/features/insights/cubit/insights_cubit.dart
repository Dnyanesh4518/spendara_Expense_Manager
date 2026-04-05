import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../repository/transaction_repository.dart';

part 'insights_state.dart';

class InsightsCubit extends Cubit<InsightsState> {
  final TransactionRepository _repo;

  InsightsCubit(this._repo)
    : super(InsightsState(weekDayLabels: _repo.last7DayLabels));

  void load() {
    emit(state.copyWith(status: InsightsStatus.loading));
    try {
      final now = DateTime.now();
      final allTxns = _repo.getAll();

      // ── Month totals ───────────────────────────────────────
      final thisMonth = allTxns.where(
        (t) =>
            t.isExpense && t.date.year == now.year && t.date.month == now.month,
      );

      final lastMonthDate = DateTime(now.year, now.month - 1);
      final lastMonth = allTxns.where(
        (t) =>
            t.isExpense &&
            t.date.year == lastMonthDate.year &&
            t.date.month == lastMonthDate.month,
      );

      // ── Most frequent category ─────────────────────────────
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

      emit(
        state.copyWith(
          expensesByCategory: _repo.expensesByCategory,
          thisWeek: _repo.last7DaysExpenses,
          lastWeek: _repo.prev7DaysExpenses,
          thisMonthTotal: thisMonth.fold(0.0, (s, t) => s! + t.amount),
          lastMonthTotal: lastMonth.fold(0.0, (s, t) => s! + t.amount),
          totalTransactions: allTxns.length,
          mostFrequentCategory: mostFrequent,
          status: InsightsStatus.success,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: InsightsStatus.error));
    }
  }
}
