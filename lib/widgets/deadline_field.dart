import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

class DeadlineField extends StatelessWidget {
  final DateTime deadline;
  final Color activeColor;
  final VoidCallback onTap;

  const DeadlineField({
    super.key,
    required this.deadline,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    String month(int m) => [
      '',
      appLocalizations!.jan,
      appLocalizations.feb,
      appLocalizations.mar,
      appLocalizations.apr,
      appLocalizations.may,
      appLocalizations.jun,
      appLocalizations.jul,
      appLocalizations.aug,
      appLocalizations.sep,
      appLocalizations.oct,
      appLocalizations.nov,
      appLocalizations.dec,
    ][m];
    final tt = Theme.of(context).textTheme;
    final diff = deadline.difference(DateTime.now()).inDays;
    final label = '${deadline.day} ${month(deadline.month)} ${deadline.year}';
    final badge = diff < 30
        ? '$diff ${appLocalizations?.daysLeft}'
        : diff < 365
        ? '${(diff / 30).round()} ${appLocalizations?.monthsLeft}'
        : '${(diff / 365).round()} ${appLocalizations?.yrLeft}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 18, color: activeColor),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: tt.bodyLarge)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge,
                style: tt.labelSmall?.copyWith(
                  color: activeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
