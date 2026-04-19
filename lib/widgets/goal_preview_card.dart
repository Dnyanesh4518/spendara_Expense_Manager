import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

class GoalPreviewCard extends StatelessWidget {
  final String title, iconKey;
  final int colorIdx;
  final double target, saved;
  final DateTime deadline;
  final Color activeColor;
  final Map<String, IconData> iconOptions;

  const GoalPreviewCard({
    super.key,
    required this.title,
    required this.iconKey,
    required this.colorIdx,
    required this.target,
    required this.saved,
    required this.deadline,
    required this.activeColor,
    required this.iconOptions,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final progress = target > 0 ? (saved / target).clamp(0.0, 1.0) : 0.0;
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    String deadlineLabel() {
      final diff = deadline.difference(DateTime.now()).inDays;
      if (diff <= 0) return appLocalizations?.dueToday ?? 'Due today';
      if (diff == 1) return '1 ${appLocalizations?.daysLeft}';
      if (diff < 30) return '$diff ${appLocalizations?.daysLeft}';
      if (diff < 365) {
        return '${(diff / 30).round()} ${appLocalizations?.monthsLeft}';
      } else {
        return '${(diff / 365).round()} ${appLocalizations?.yrLeft}';
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: activeColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconOptions[iconKey] ?? Icons.flag_outlined,
                  color: activeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tt.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(deadlineLabel(), style: tt.bodySmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: tt.labelSmall?.copyWith(
                    color: activeColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: activeColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(activeColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${saved.toStringAsFixed(0)} ${appLocalizations?.savedLabel}',
                style: tt.bodySmall?.copyWith(
                  color: activeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text('of ₹${target.toStringAsFixed(0)}', style: tt.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
