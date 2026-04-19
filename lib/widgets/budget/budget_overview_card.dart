import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../features/budget/cubit/budget_cubit.dart';
import '../../features/budget/view/budget_details_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/transitions.dart';
import 'empty_budget_card.dart';

class BudgetOverviewCard extends StatelessWidget {
  /// Actual spending per category key for the current month.
  /// Pass `state.expensesByCategory` from TransactionCubit/DashboardCubit.
  final Map<String, double> spentByCategory;

  const BudgetOverviewCard({super.key, required this.spentByCategory});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetCubit, BudgetState>(
      builder: (context, budgetState) {
        final l10n = AppLocalizations.of(context)!;

        if (budgetState is BudgetLoading || budgetState is BudgetInitial) {
          return const SizedBox.shrink();
        }

        final loaded = budgetState as BudgetLoaded;

        // ── Empty state ──────────────────────────────────────
        if (loaded.current == null) {
          return EmptyBudgetCard(month: loaded.month, year: loaded.year);
        }

        final budget = loaded.current!;
        final totalSpent = spentByCategory.values.fold(0.0, (s, v) => s + v);
        final totalProgress = budget.totalBudget > 0
            ? (totalSpent / budget.totalBudget).clamp(0.0, 1.0)
            : 0.0;
        final overallColor = _progressColor(totalProgress);

        // Top 3 by priority (1=High first), then by allocated desc
        final sorted = budget.categoryBudgets.entries.toList()
          ..sort((a, b) {
            final pa = budget.priorities[a.key] ?? 2;
            final pb = budget.priorities[b.key] ?? 2;
            if (pa != pb) return pa.compareTo(pb);
            return b.value.compareTo(a.value);
          });
        final top3 = sorted.take(3).toList();

        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            slideUp(
              BudgetDetailScreen(
                budget: budget,
                spentByCategory: spentByCategory,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 15,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.monthlyBudget,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Text(
                            '${Constants.monthLabels(context)[budget.month - 1]} ${budget.year}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                          ),
                        ],
                      ),
                    ),
                    _PctBadge(progress: totalProgress),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Total spend vs budget ────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.formatter.format(totalSpent),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: overallColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      '/ ${context.formatter.format(budget.totalBudget)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: totalProgress,
                    minHeight: 7,
                    backgroundColor: overallColor.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(overallColor),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Top 3 category bars ──────────────────────
                ...top3.map((entry) {
                  final key = entry.key;
                  final allocated = entry.value;
                  final spent = spentByCategory[key] ?? 0;
                  final progress = allocated > 0
                      ? (spent / allocated).clamp(0.0, 1.0)
                      : 0.0;
                  final color = _progressColor(progress);
                  final prio = budget.priorities[key] ?? 2;
                  final label = Constants.categoryLabel(context, key);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Constants.categoryIcon(key),
                              size: 13,
                              color: color,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                label,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                            _PriorityDot(priority: prio),
                            const SizedBox(width: 6),
                            Text(
                              context.formatter.compact(spent),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor: color.withValues(alpha: 0.12),
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _progressColor(double p) {
    if (p >= 0.9) return AppColors.expense;
    if (p >= 0.7) return AppColors.warning;
    return AppColors.income;
  }
}

// ── Small helpers ───────────────────────────────────────────────
class _PctBadge extends StatelessWidget {
  final double progress;
  const _PctBadge({required this.progress});

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).toInt();
    final color = progress >= 0.9
        ? AppColors.expense
        : progress >= 0.7
        ? AppColors.warning
        : AppColors.income;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$pct%',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  final int priority;
  const _PriorityDot({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      1 => AppColors.expense,
      2 => AppColors.warning,
      _ => AppColors.income,
    };
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
