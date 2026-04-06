import 'package:Spendara/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../features/insights/cubit/insights_cubit.dart';

class BiggestSpikeDayCard extends StatelessWidget {
  final InsightsState state;

  const BiggestSpikeDayCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final fmt = CurrencyFormatter.of(context);
    AppLocalizations? appLocalizations = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.expenseLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              size: 24,
              color: AppColors.expense,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appLocalizations!.highestSpendDay, style: tt.bodySmall),
                const SizedBox(height: 2),
                Text(
                  state.biggestSpikeDay,
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fmt.format(state.biggestSpikeAmount),
                  style: tt.labelLarge?.copyWith(
                    color: AppColors.expense,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
