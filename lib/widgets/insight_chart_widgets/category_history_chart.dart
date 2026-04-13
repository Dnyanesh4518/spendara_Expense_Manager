import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../features/insights/cubit/insights_cubit.dart';
import '../../l10n/generated/app_localizations.dart';
import 'empty_box.dart';

class CategoryHistoryChart extends StatelessWidget {
  final InsightsState state;

  const CategoryHistoryChart({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final history = state.top5CategoryHistory;
    final labels = state.historyPeriodLabels;
    final cats = history.keys.toList();
    final colors = AppColors.categoryColors;
    AppLocalizations? appLocalizations = AppLocalizations.of(context);

    if (history.isEmpty || labels.isEmpty) {
      return emptyBox(context, appLocalizations!.notEnoughHistoryYet);
    }

    final allValues = history.values.expand((l) => l).where((v) => v > 0);
    final maxY = allValues.isEmpty ? 100.0 : allValues.reduce(max) * 1.3;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 10),
            child: Wrap(
              spacing: 12,
              runSpacing: 4,
              children: cats
                  .asMap()
                  .entries
                  .map(
                    (e) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colors[e.key % colors.length],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          Constants.expenseCategoryLabel(context, e.value),
                          // e.value.split(' ').first,
                          style: tt.bodySmall?.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                groupsSpace: 10,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.primary,
                    getTooltipItem: (group, _, rod, rodIndex) => BarTooltipItem(
                      '${cats[rodIndex].split(' ').first}\n'
                      '${CurrencyFormatter.fallback().compact(rod.toY)}',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
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
                      reservedSize: 28,
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            labels[i],
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
                barGroups: List.generate(labels.length, (periodIdx) {
                  return BarChartGroupData(
                    x: periodIdx,
                    barRods: cats.asMap().entries.map((e) {
                      final data = history[e.value];
                      final val = (data != null && periodIdx < data.length)
                          ? data[periodIdx]
                          : 0.0;
                      return BarChartRodData(
                        toY: val,
                        width: max(4.0, 44.0 / cats.length - 2),
                        color: colors[e.key % colors.length],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
