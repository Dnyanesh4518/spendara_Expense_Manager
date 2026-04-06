import 'package:flutter/material.dart';
import 'package:Spendara/core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../features/insights/cubit/insights_cubit.dart';

class SpendingVelocityCard extends StatelessWidget {
  final InsightsState state;

  const SpendingVelocityCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final fmt = CurrencyFormatter.of(context);

    final progress = state.spendingVelocity == 0
        ? 0.0
        : (state.currentPeriodExpenses / state.spendingVelocity).clamp(
            0.0,
            1.0,
          );

    final isOverBudget =
        state.spendingVelocity > state.prevPeriodExpenses &&
        state.prevPeriodExpenses > 0;
    final barColor = isOverBudget ? AppColors.expense : AppColors.income;

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
              Icon(Icons.speed_rounded, size: 18, color: barColor),
              const SizedBox(width: 8),
              Text('Projected this month', style: tt.labelLarge),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            fmt.format(state.spendingVelocity),
            style: tt.headlineLarge?.copyWith(
              color: barColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on ${fmt.format(state.currentPeriodExpenses)} spent so far',
            style: tt.bodySmall,
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: barColor.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 8),
          if (state.prevPeriodExpenses > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isOverBudget ? '⚠️ Exceeds last month' : '✓ Under last month',
                  style: tt.bodySmall?.copyWith(
                    color: isOverBudget ? AppColors.warning : AppColors.income,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Last month: ${fmt.format(state.prevPeriodExpenses)}',
                  style: tt.bodySmall,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
