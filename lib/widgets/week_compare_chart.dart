import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/currency_formatter.dart';
import '../features/insights/cubit/insights_cubit.dart';
import '../l10n/generated/app_localizations.dart';

class WeekCompareChart extends StatefulWidget {
  final InsightsState state;
  const WeekCompareChart({super.key, required this.state});

  @override
  State<WeekCompareChart> createState() => _WeekCompareChartState();
}

class _WeekCompareChartState extends State<WeekCompareChart> {
  @override
  Widget build(BuildContext context) {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    List<String> labels = widget.state.weekDayLabels;
    final thisW = widget.state.thisWeek;
    final lastW = widget.state.lastWeek;

    // Guard: need both lists populated
    if (thisW.isEmpty) {
      return _emptyChart(
        context,
        appLocalizations?.noSpendingDataThisWeek ??
            'No spending data this week',
      );
    }

    final allValues = [...thisW, ...lastW].where((v) => v > 0);
    final maxY = allValues.isEmpty
        ? 100.0
        : allValues.reduce((a, b) => a > b ? a : b) * 1.3;

    // Index of today = last element
    final todayIdx = thisW.length - 1;

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
          // ── Legend ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              children: [
                _dot(AppColors.primary, appLocalizations!.thisWeek, tt),
                const SizedBox(width: 16),
                _dot(
                  AppColors.primary.withValues(alpha: 0.3),
                  appLocalizations.lastWeek,
                  tt,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                groupsSpace: 8,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.primary,
                    getTooltipItem: (group, _, rod, rodIndex) {
                      final label = rodIndex == 0
                          ? appLocalizations.thisWeek
                          : appLocalizations.lastWeek;
                      return BarTooltipItem(
                        '$label\n${context.formatter.compact(rod.toY)}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
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
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        final isToday = i == todayIdx;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            labels[i],
                            style: tt.bodySmall?.copyWith(
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isToday ? AppColors.primary : null,
                            ),
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
                barGroups: List.generate(thisW.length, (i) {
                  final isToday = i == todayIdx;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: thisW[i],
                        width: 12,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            isToday
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.7),
                            isToday
                                ? const Color(0xFF4A43D4)
                                : AppColors.primary.withValues(alpha: 0.4),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      BarChartRodData(
                        toY: lastW.isNotEmpty ? lastW[i] : 0,
                        width: 12,
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
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

  Widget _dot(Color color, String label, TextTheme tt) => Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 6),
      Text(label, style: tt.bodySmall?.copyWith(fontSize: 11)),
    ],
  );

  Widget _emptyChart(BuildContext context, String msg) => Container(
    height: 100,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
      ),
    ),
    child: Text(msg, style: Theme.of(context).textTheme.bodySmall),
  );
}
