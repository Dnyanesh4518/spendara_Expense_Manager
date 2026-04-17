import 'package:Spendara/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../features/insights/cubit/insights_cubit.dart';

class AnomalyAlertCard extends StatelessWidget {
  final AnomalyItem item;

  const AnomalyAlertCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final fmt = CurrencyFormatter.of(context);
    final icon = Constants.categoryIcon(item.category);
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.warning),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 20,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(
                      Constants.expenseCategoryLabel(context, item.category),
                      style: tt.labelLarge?.copyWith(color: AppColors.primary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '⚠️ +${item.pctIncrease.toStringAsFixed(0)}%',
                        style: tt.labelSmall?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${fmt.format(item.currentAmount)}  ${appLocalizations!.spentSoFar} '
                  'vs ${fmt.format(item.avgAmount)} ${appLocalizations.avgLabel}',
                  style: tt.bodySmall?.copyWith(color: AppColors.warning),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
