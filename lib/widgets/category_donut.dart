import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/currency_formatter.dart';
import '../features/insights/cubit/insights_cubit.dart';

class CategoryDonut extends StatefulWidget {
  final InsightsState state;
  const CategoryDonut({super.key, required this.state});

  @override
  State<CategoryDonut> createState() => _CategoryDonutState();
}

class _CategoryDonutState extends State<CategoryDonut> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final entries = widget.state.expensesByCategory.entries.toList();
    final total = widget.state.totalExpenses;
    final colors = AppColors.categoryColors;

    // Touched label
    final touchedLabel = _touched >= 0 && _touched < entries.length
        ? entries[_touched].key.split(' ').first
        : '';
    final touchedAmt = _touched >= 0 && _touched < entries.length
        ? context.formatter.format(entries[_touched].value)
        : '';

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          // ── Donut ────────────────────────────────────────
          Expanded(
            flex: 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 50,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          _touched = event is FlPointerExitEvent
                              ? -1
                              : response?.touchedSection?.touchedSectionIndex ??
                                    -1;
                        });
                      },
                    ),
                    sections: entries.asMap().entries.map((e) {
                      final isTouched = e.key == _touched;
                      return PieChartSectionData(
                        value: e.value.value,
                        color: colors[e.key % colors.length],
                        radius: isTouched ? 54 : 44,
                        showTitle: false,
                      );
                    }).toList(),
                  ),
                ),
                // Centre label — shows tapped category
                if (_touched >= 0)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        touchedLabel,
                        style: tt.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        touchedAmt,
                        style: tt.labelSmall?.copyWith(
                          color: colors[_touched % colors.length],
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // ── Legend ───────────────────────────────────────
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entries.asMap().entries.map((e) {
                final pct = total > 0
                    ? (e.value.value / total * 100).toInt()
                    : 0;
                final isHighlighted = _touched == e.key;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: isHighlighted ? 12 : 8,
                        height: isHighlighted ? 12 : 8,
                        decoration: BoxDecoration(
                          color: colors[e.key % colors.length],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.value.key.split(' ').first,
                          style: tt.bodySmall?.copyWith(
                            fontSize: 11,
                            fontWeight: isHighlighted
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: tt.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isHighlighted
                              ? colors[e.key % colors.length]
                              : null,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
