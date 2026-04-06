import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../constants/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../features/insights/cubit/insights_cubit.dart';
import '../../l10n/generated/app_localizations.dart';
import 'empty_box.dart';

class CategoryDonut extends StatefulWidget {
  final InsightsState state;

  const CategoryDonut({super.key, required this.state});

  @override
  State<CategoryDonut> createState() => _CategoryDonutState();
}

class _CategoryDonutState extends State<CategoryDonut> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final cats = widget.state.expensesByCategory.entries.toList();
    final total = widget.state.totalExpenses;
    final colors = AppColors.categoryColors;
    AppLocalizations? appLocalizations = AppLocalizations.of(context);

    if (cats.isEmpty) {
      return emptyBox(context, appLocalizations!.noExpensesThisPeriod);
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = -1;
                    } else {
                      _touchedIndex =
                          response.touchedSection!.touchedSectionIndex;
                    }
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 56,
              sections: cats.asMap().entries.map((e) {
                final i = e.key;
                final entry = e.value;
                final isTouched = i == _touchedIndex;
                final pct = total == 0 ? 0.0 : entry.value / total * 100;
                return PieChartSectionData(
                  color: colors[i % colors.length],
                  value: entry.value,
                  title: isTouched ? '${pct.toStringAsFixed(1)}%' : '',
                  radius: isTouched ? 62 : 52,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // ── Legend ────────────────────────────────────────────────────
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: cats.asMap().entries.map((e) {
            final pct = total == 0 ? 0.0 : e.value.value / total * 100;
            return Row(
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
                  '${Constants.expenseCategoryLabel(context, e.value.key)} '
                  '${pct.toStringAsFixed(0)}%',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
