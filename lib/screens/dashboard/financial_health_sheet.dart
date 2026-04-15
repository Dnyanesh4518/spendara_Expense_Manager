import 'package:Spendara/screens/dashboard/state_chip.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../features/dashboard/cubit/dashboard_cubit.dart';
import '../../l10n/generated/app_localizations.dart';

class FinancialHealthSheet extends StatelessWidget {
  final DashboardState state;
  final AppLocalizations? l10n;

  const FinancialHealthSheet({
    super.key,
    required this.state,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final fmt = context.formatter;

    // Derive health score (simple logic — no AI)
    final savingsRate = state.savingsProgress * 100;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Text(
              l10n?.financialOverview ?? 'Financial overview',
              style: tt.headlineMedium,
            ),
            const SizedBox(height: 20),
            // ── 3 stat chips in a row ──────────────────────────
            Row(
              children: [
                StatChip(
                  label: l10n?.balance ?? 'Balance',
                  value: fmt.compact(state.balance),
                  color: AppColors.primary,
                  bgColor: AppColors.primaryLight,
                ),
                const SizedBox(width: 8),
                StatChip(
                  label: l10n?.income ?? 'Income',
                  value: fmt.compact(state.totalIncome),
                  color: AppColors.income,
                  bgColor: AppColors.incomeLight,
                ),
                const SizedBox(width: 8),
                StatChip(
                  label: l10n?.youSpent ?? 'You Spent',
                  value: fmt.compact(state.totalExpenses),
                  color: AppColors.expense,
                  bgColor: AppColors.expenseLight,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Savings progress bar ───────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n?.savingsGoalProgress ?? 'Savings goal progress',
                  style: tt.bodyMedium,
                ),
                Text(
                  '${savingsRate.toStringAsFixed(0)}%',
                  style: tt.labelLarge?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: state.savingsProgress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 20),
            // ── Action buttons ─────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, 'transactions');
                    },
                    icon: const Icon(Icons.receipt_long_outlined, size: 16),
                    label: Text(l10n?.seeAll ?? 'see all'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, 'insights');
                    },
                    icon: const Icon(Icons.insights_outlined, size: 16),
                    label: Text(
                      l10n?.fullInsights ?? 'Full insights',
                      style: TextStyle(overflow: TextOverflow.ellipsis),
                      maxLines: 1,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
