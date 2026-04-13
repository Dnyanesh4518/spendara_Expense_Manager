import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/currency_formatter.dart';
import '../features/insights/cubit/insights_cubit.dart';
import '../l10n/generated/app_localizations.dart';

class MonthCompareCard extends StatelessWidget {
  final InsightsState state;
  const MonthCompareCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final pct = state.monthOverMonthPct;
    final isUp = state.isMonthSpendingUp;
    final color = isUp ? AppColors.expense : AppColors.income;
    final bg = isUp ? AppColors.expenseLight : AppColors.incomeLight;
    final arrow = isUp ? '↑' : '↓';
    final hasData = state.lastMonthTotal > 0;

    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  appLocalizations?.monthOverview ?? 'Month overview',
                  style: tt.labelLarge,
                ),
              ),
              if (hasData)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$arrow ${pct.abs().toStringAsFixed(1)}${appLocalizations?.vsLastMonth}',
                    style: tt.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              Expanded(
                child: _MonthBar(
                  label: appLocalizations?.thisMonth ?? 'This month',
                  amount: state.thisMonthTotal,
                  maxAmount: hasData
                      ? [
                          state.thisMonthTotal,
                          state.lastMonthTotal,
                        ].reduce((a, b) => a > b ? a : b)
                      : state.thisMonthTotal,
                  color: AppColors.barBackground,
                ),
              ),

              Expanded(
                child: _MonthBar(
                  label: appLocalizations?.lastMonth ?? 'Last month',
                  amount: state.lastMonthTotal,
                  maxAmount: hasData
                      ? [
                          state.thisMonthTotal,
                          state.lastMonthTotal,
                        ].reduce((a, b) => a > b ? a : b)
                      : state.lastMonthTotal,
                  color: AppColors.barBackground.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          if (!hasData) ...[
            const SizedBox(height: 12),
            Text(
              appLocalizations?.lastMonthDataInfo ??
                  'Last month data will appear once you have transactions from the previous month.',
              style: tt.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _MonthBar extends StatelessWidget {
  final String label;
  final double amount, maxAmount;
  final Color color;

  const _MonthBar({
    required this.label,
    required this.amount,
    required this.maxAmount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final progress = maxAmount == 0
        ? 0.0
        : (amount / maxAmount).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tt.bodySmall),
        const SizedBox(height: 6),
        Text(
          context.formatter.format(amount),
          style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.8),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
