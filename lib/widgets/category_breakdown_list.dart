import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency_formatter.dart';
import '../features/insights/cubit/insights_cubit.dart';
import '../l10n/generated/app_localizations.dart';

class CategoryBreakdownList extends StatelessWidget {
  final InsightsState state;
  const CategoryBreakdownList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final entries = state.expensesByCategory.entries.toList();
    final total = state.totalExpenses;
    final colors = AppColors.categoryColors;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: entries.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.25),
        ),
        itemBuilder: (_, i) {
          final e = entries[i];
          final pct = total > 0 ? e.value / total : 0.0;
          final color = colors[i % colors.length];
          final icon = Constants.categoryIcon(e.key);

          final categoryLabel = Constants.expenseCategoryLabel(context, e.key);
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                // Rank badge
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: i == 0
                        ? color.withValues(alpha: 0.15)
                        : Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: tt.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: i == 0 ? color : null,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Icon
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 15),
                ),
                const SizedBox(width: 12),
                // Label + bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(categoryLabel, style: tt.labelLarge),
                          Text(
                            context.formatter.format(e.value),
                            style: tt.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Stack(
                        children: [
                          Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: pct,
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(pct * 100).toStringAsFixed(1)} ${appLocalizations!.percentOfTotalSpending}',
                        style: tt.bodySmall?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
