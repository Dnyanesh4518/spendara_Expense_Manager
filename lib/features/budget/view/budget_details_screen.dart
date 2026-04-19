import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../constants/constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../routes/transitions.dart';
import '../../../widgets/budget/priority_badge.dart';
import '../cubit/budget_cubit.dart';
import '../model/budget_model.dart';
import 'create_budget_screen.dart';

class BudgetDetailScreen extends StatelessWidget {
  final BudgetModel budget;
  final Map<String, double> spentByCategory;

  const BudgetDetailScreen({
    super.key,
    required this.budget,
    required this.spentByCategory,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;
    final fmt = context.formatter;

    final totalSpent = spentByCategory.values.fold(0.0, (s, v) => s + v);
    final totalProgress = budget.totalBudget > 0
        ? (totalSpent / budget.totalBudget).clamp(0.0, 1.0)
        : 0.0;
    final overallColor = _progressColor(totalProgress);

    final sorted = budget.categoryBudgets.entries.toList()
      ..sort((a, b) {
        final pa = budget.priorities[a.key] ?? 2;
        final pb = budget.priorities[b.key] ?? 2;
        if (pa != pb) return pa.compareTo(pb);
        return b.value.compareTo(a.value);
      });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${Constants.monthLabels(context)[budget.month - 1]} ${budget.year}',
          style: tt.headlineMedium,
        ),
        actions: [
          // Edit
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final nav = Navigator.of(context);
              final result = await nav.push<bool>(
                slideUp(CreateBudgetScreen(existing: budget)),
              );
              if (result == true) nav.pop();
            },
          ),
          // Delete
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AppColors.expense,
            onPressed: () => _confirmDelete(context, l10n),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Overall summary card ─────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        overallColor,
                        overallColor.withValues(alpha: 0.75),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalSpent,
                        style: tt.bodySmall?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fmt.format(totalSpent),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        'of ${fmt.format(budget.totalBudget)}',
                        style: tt.bodySmall?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: totalProgress,
                          minHeight: 7,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(totalProgress * 100).toInt()}% ${l10n.used}',
                            style: tt.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '${fmt.format(budget.totalBudget - totalSpent)} ${l10n.left}',
                            style: tt.bodySmall?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Category breakdown ───────────────────────
                Text(l10n.categoryBreakdown, style: tt.labelLarge),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.4),
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sorted.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.25),
                    ),
                    itemBuilder: (_, i) {
                      final entry = sorted[i];
                      final key = entry.key;
                      final allocated = entry.value;
                      final spent = spentByCategory[key] ?? 0;
                      final progress = allocated > 0
                          ? (spent / allocated).clamp(0.0, 1.0)
                          : 0.0;
                      final color = _progressColor(progress);
                      final prio = budget.priorities[key] ?? 2;
                      // Compute % change
                      final pctRaw = allocated > 0
                          ? ((spent - allocated) / allocated * 100)
                          : 0.0;
                      final pctAbs = pctRaw.abs().toStringAsFixed(0);
                      final isOver = pctRaw > 0;
                      final isExact = pctRaw == 0;
                      final pctColor = isOver
                          ? AppColors.expense
                          : AppColors.income;
                      final label = Constants.categoryLabel(context, key);

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                        child: Column(
                          children: [
                            Row(
                              spacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Constants.categoryIcon(key),
                                    size: 15,
                                    color: color,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(label, style: tt.labelLarge),
                                      Text(
                                        '${fmt.format(spent)} of ${fmt.format(allocated)}',
                                        style: tt.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isExact)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: pctColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isOver
                                              ? Icons.arrow_upward
                                              : Icons.arrow_downward,
                                          size: 10,
                                          color: pctColor,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '$pctAbs%',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: pctColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                PriorityBadge(priority: prio),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: color.withValues(alpha: 0.12),
                                valueColor: AlwaysStoppedAnimation(color),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Color _progressColor(double p) {
    if (p >= 0.9) return AppColors.expense;
    if (p >= 0.7) return AppColors.warning;
    return AppColors.income;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final cubit = context.read<BudgetCubit>();
    final nav = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteBudget),
        content: Text(l10n.actionCannotBeUndone),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await cubit.deleteBudget(budget.id);
      nav.pop();
    }
  }
}
