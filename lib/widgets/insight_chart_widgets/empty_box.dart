import 'package:flutter/material.dart';

Widget emptyBox(BuildContext context, String message) {
  final tt = Theme.of(context).textTheme;
  return Container(
    height: 140,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.25),
      ),
    ),
    alignment: Alignment.center,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.bar_chart_rounded,
          size: 34,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.18),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: tt.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    ),
  );
}
