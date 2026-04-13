import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../constants/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../features/insights/cubit/insights_cubit.dart';
import '../../l10n/generated/app_localizations.dart';
import 'empty_box.dart';

class YearlyCompareChart extends StatelessWidget {
  final InsightsState state;

  const YearlyCompareChart({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final now = DateTime.now();
    final thisY = state.thisYearMonthly;
    final lastY = state.lastYearMonthly;
    final months = Constants.monthLabels(context);
    AppLocalizations? appLocalizations = AppLocalizations.of(context);

    if (thisY.isEmpty) {
      return emptyBox(context, appLocalizations!.noYearlyDataYet);
    }

    final allVals = [...thisY, ...lastY].where((v) => v > 0);
    final maxY = allVals.isEmpty ? 100.0 : allVals.reduce(max) * 1.3;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              children: [
                _legendDot(AppColors.primary, '${now.year}', tt),
                const SizedBox(width: 14),
                _legendDot(
                  AppColors.primary.withValues(alpha: 0.3),
                  '${now.year - 1}',
                  tt,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: maxY,
                groupsSpace: 4,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i >= months.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            months[i],
                            style: tt.bodySmall?.copyWith(fontSize: 9),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.15),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(12, (i) {
                  final isCurrentMonth = i == now.month - 1;
                  return BarChartGroupData(
                    barsSpace: 0,
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: thisY[i],
                        width: 8,
                        gradient: LinearGradient(
                          colors: isCurrentMonth
                              ? [AppColors.primary, const Color(0xFF4A43D4)]
                              : [
                                  AppColors.primary.withValues(alpha: 0.7),
                                  AppColors.primary.withValues(alpha: 0.4),
                                ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                      ),
                      BarChartRodData(
                        toY: lastY.isNotEmpty ? lastY[i] : 0,
                        width: 8,
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label, TextTheme tt) => Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 5),
      Text(label, style: tt.bodySmall?.copyWith(fontSize: 11)),
    ],
  );
}
