import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../core/theme/app_colors.dart';
import '../features/goals/model/goals_model.dart';

class GoalCard extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback onDeposit;
  final VoidCallback onEdit;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onDeposit,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color =
        Constants.goalColors[goal.colorValue % Constants.goalColors.length];
    final icon = Constants.goalIcon(goal.iconName);
    final progress = goal.progress;
    final remaining = goal.remaining;
    final daysLeft = goal.deadline.difference(DateTime.now()).inDays;
    final isComplete = progress >= 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete
              ? color.withOpacity(0.5)
              : Theme.of(context).colorScheme.outline.withOpacity(0.4),
          width: isComplete ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ───────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.title, style: tt.labelLarge),
                    Text(
                      isComplete
                          ? '🎉 Goal achieved!'
                          : daysLeft <= 0
                          ? 'Deadline passed'
                          : '$daysLeft day${daysLeft == 1 ? '' : 's'} left',
                      style: tt.bodySmall?.copyWith(
                        color: isComplete
                            ? color
                            : daysLeft <= 7 && !isComplete
                            ? AppColors.warning
                            : null,
                        fontWeight: isComplete ? FontWeight.w600 : null,
                      ),
                    ),
                  ],
                ),
              ),
              // Edit button
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.4),
                ),
                onPressed: onEdit,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
              // Progress badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: tt.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Progress bar ─────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 12),

          // ── Amount row + deposit button ───────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${goal.savedAmount.toStringAsFixed(0)} saved',
                      style: tt.labelLarge?.copyWith(color: color),
                    ),
                    Text(
                      isComplete
                          ? 'Target: ₹${goal.targetAmount.toStringAsFixed(0)}'
                          : '₹${remaining.toStringAsFixed(0)} to go',
                      style: tt.bodySmall,
                    ),
                  ],
                ),
              ),
              if (!isComplete)
                ElevatedButton.icon(
                  onPressed: onDeposit,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add funds'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Complete ✓',
                    style: tt.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
