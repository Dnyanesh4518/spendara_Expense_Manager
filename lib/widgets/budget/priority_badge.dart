import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

class PriorityBadge extends StatelessWidget {
  final int priority;
  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = switch (priority) {
      1 => AppColors.expense,
      2 => AppColors.warning,
      _ => AppColors.income,
    };
    final label = switch (priority) {
      1 => l10n.priorityHigh,
      2 => l10n.priorityMedium,
      _ => l10n.priorityLow,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
