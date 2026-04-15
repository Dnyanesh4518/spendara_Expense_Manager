import 'dart:math';

import 'package:Spendara/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:Spendara/core/theme/app_colors.dart';

import '../../core/utils/currency_formatter.dart';

class DayHeatmapWidget extends StatelessWidget {
  final List<double> totals; // 7 values, Mon=0..Sun=6

  const DayHeatmapWidget({super.key, required this.totals});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    if (totals.length < 7) return const SizedBox.shrink();
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    final maxVal = totals.reduce(max);
    final fmt = CurrencyFormatter.of(context);
    List<String> days = [
      appLocalizations?.mon ?? 'Mon',
      appLocalizations?.tue ?? 'Tue',
      appLocalizations?.wed ?? 'Wed',
      appLocalizations?.thu ?? 'Thu',
      appLocalizations?.fri ?? 'Fri',
      appLocalizations?.sat ?? 'Sat',
      appLocalizations?.sun ?? 'Sun',
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
            children: List.generate(7, (i) {
              final intensity = maxVal == 0 ? 0.0 : totals[i] / maxVal;
              final isPeak = totals[i] == maxVal && maxVal > 0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _heatColor(intensity, isPeak),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: isPeak
                            ? const Icon(
                                Icons.keyboard_arrow_up,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        days[i],
                        style: tt.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: isPeak
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isPeak ? AppColors.expense : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Wrap(
            runAlignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                '${appLocalizations?.highestLabel} ${days[totals.indexOf(maxVal)]} '
                '(${fmt.compact(maxVal)})',
                style: tt.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.expense,
                ),
              ),
              Row(
                children: [
                  _legendBox(AppColors.expense.withValues(alpha: 0.15)),
                  _legendBox(AppColors.expense.withValues(alpha: 0.45)),
                  _legendBox(AppColors.expense.withValues(alpha: 0.75)),
                  _legendBox(AppColors.expense),
                  const SizedBox(width: 4),
                  Text(
                    appLocalizations!.lowToHigh,
                    style: tt.bodySmall?.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _heatColor(double intensity, bool isPeak) {
    if (isPeak) return AppColors.expense;
    if (intensity > 0.75) return AppColors.expense.withValues(alpha: 0.75);
    if (intensity > 0.5) return AppColors.expense.withValues(alpha: 0.5);
    if (intensity > 0.25) return AppColors.expense.withValues(alpha: 0.3);
    if (intensity > 0) return AppColors.expense.withValues(alpha: 0.12);
    return AppColors.income.withValues(alpha: 0.1);
  }

  Widget _legendBox(Color color) => Container(
    width: 12,
    height: 12,
    margin: const EdgeInsets.only(right: 2),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(3),
    ),
  );
}
