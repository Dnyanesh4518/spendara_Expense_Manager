import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency_formatter.dart';
import '../features/insights/cubit/insights_cubit.dart';
import '../l10n/generated/app_localizations.dart';

class StatCardsRow extends StatelessWidget {
  final InsightsState state;
  const StatCardsRow({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    final wowPct = state.weekOverWeekPct;
    final wowUp = state.isWeekSpendingUp;
    final wowColor = wowUp ? AppColors.expense : AppColors.income;
    final wowBg = wowUp ? AppColors.expenseLight : AppColors.incomeLight;
    final wowIcon = wowUp ? Icons.trending_up : Icons.trending_down;
    final wowLabel =
        '${wowUp ? '+' : ''}${wowPct.toStringAsFixed(1)}${appLocalizations?.vsLastWeek}';

    return Column(
      children: [
        // Row 1 — top category + week trend
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Constants.categoryIcon(state.topCategory),
                iconColor: AppColors.expense,
                iconBg: AppColors.expenseLight,
                label: appLocalizations?.topCategory ?? 'Top category',
                value:
                    Constants.expenseCategoryLabel(
                          context,
                          state.topCategory,
                        ) ==
                        '—'
                    ? '—'
                    : Constants.expenseCategoryLabel(
                        context,
                        state.topCategory,
                      ),
                sub:
                    Constants.expenseCategoryLabel(
                          context,
                          state.topCategory,
                        ) ==
                        '—'
                    ? appLocalizations?.noExpensesYet ?? 'No expenses yet'
                    : context.formatter.format(state.topCategoryAmount),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: wowIcon,
                iconColor: wowColor,
                iconBg: wowBg,
                label: appLocalizations?.thisWeek ?? 'This week',
                value: context.formatter.compact(state.thisWeekTotal),
                sub: state.lastWeekTotal == 0
                    ? appLocalizations?.noPriorWeekData ?? 'No prior week data'
                    : wowLabel,
                subColor: wowColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Row 2 — frequent category + total transactions
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.repeat_rounded,
                iconColor: AppColors.primary,
                iconBg: AppColors.primaryLight,
                label: appLocalizations?.mostFrequent ?? 'Most frequent',
                value: Constants.expenseCategoryLabel(
                  context,
                  state.mostFrequentCategory,
                ),
                sub:
                    appLocalizations?.byTransactionCount ??
                    'By transaction count',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.receipt_long_outlined,
                iconColor: AppColors.warning,
                iconBg: AppColors.warningLight,
                label: appLocalizations?.allTransactions ?? 'All transactions',
                value: '${state.totalTransactions}',
                sub: appLocalizations?.totalRecorded ?? 'Total recorded',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String label, value, sub;
  final Color? subColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.sub,
    this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 10),
          Text(label, style: tt.bodySmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: tt.bodySmall?.copyWith(
              color: subColor,
              fontWeight: subColor != null ? FontWeight.w600 : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
