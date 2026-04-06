import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../features/insights/cubit/insights_cubit.dart';
import '../../l10n/generated/app_localizations.dart';
import 'empty_box.dart';

class SavingsRateTrendChart extends StatelessWidget {
  final InsightsState state;

  const SavingsRateTrendChart({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final data = state.savingsRateTrend;
    final labels = state.savingsRateLabels;
    AppLocalizations? appLocalizations = AppLocalizations.of(context);

    if (data.isEmpty) {
      return emptyBox(context, appLocalizations!.noSavingsDataYet);
    }

    final maxY = max(data.reduce(max) * 1.3, 10.0);
    final avgRate = data.fold(0.0, (s, v) => s + v) / data.length;

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
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
                Container(
                  width: 24,
                  height: 2,
                  color: AppColors.income.withValues(alpha: 0.4),
                  margin: const EdgeInsets.only(right: 6),
                ),
                Text(
                  '${appLocalizations!.avgLabel} ${avgRate.toStringAsFixed(1)}%',
                  style: tt.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                clipData: const FlClipData.all(),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.primary,
                    getTooltipItems: (spots) => spots
                        .map(
                          (s) => LineTooltipItem(
                            '${labels[s.x.toInt()]}\n'
                            '${s.y.toStringAsFixed(1)}%',
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: avgRate,
                      color: AppColors.income.withValues(alpha: 0.4),
                      strokeWidth: 1,
                      dashArray: [6, 4],
                    ),
                  ],
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
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}%',
                        style: tt.bodySmall?.copyWith(fontSize: 10),
                      ),
                    ),
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
                lineBarsData: [
                  LineChartBarData(
                    spots: data
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: AppColors.income,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: 3,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: AppColors.income,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.income.withValues(alpha: 0.2),
                          AppColors.income.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
