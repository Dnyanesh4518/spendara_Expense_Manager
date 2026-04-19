import 'package:flutter/material.dart';

import '../../constants/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../features/budget/view/create_budget_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/transitions.dart';

// ── Empty state card ────────────────────────────────────────────
class EmptyBudgetCard extends StatelessWidget {
  final int month, year;

  const EmptyBudgetCard({super.key, required this.month, required this.year});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 22,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.noBudgetYet, style: tt.labelLarge),
                const SizedBox(height: 2),
                Text(
                  '${Constants.monthLabels(context)[month - 1]} $year',
                  style: tt.bodySmall,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).push(slideUp(const CreateBudgetScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.createBudget,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
