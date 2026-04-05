import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../l10n/generated/app_localizations.dart';

class DateField extends StatefulWidget {
  final DateTime date;
  final VoidCallback onTap;
  const DateField({super.key, required this.date, required this.onTap});

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
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
    String label() {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      if (widget.date.year == now.year &&
          widget.date.month == now.month &&
          widget.date.day == now.day) {
        return appLocalizations?.today ?? 'Today';
      }
      if (widget.date.year == yesterday.year &&
          widget.date.month == yesterday.month &&
          widget.date.day == yesterday.day) {
        return appLocalizations?.yesterday ?? 'Yesterday';
      }
      return '${widget.date.day} ${month(widget.date.month)} ${widget.date.year}';
    }

    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: widget.onTap,
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
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(label(), style: tt.bodyLarge),
            const Spacer(),
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
