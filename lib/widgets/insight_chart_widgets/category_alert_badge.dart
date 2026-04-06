import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

class CategoryAlertBadge extends StatelessWidget {
  final String category;
  final double currentAmount;
  final double pctIncrease;

  const CategoryAlertBadge({
    super.key,
    required this.category,
    required this.currentAmount,
    required this.pctIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final fmt = CurrencyFormatter.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$category spending is '
              '${pctIncrease.toStringAsFixed(0)}% '
              'higher than your average',
              style: tt.bodyMedium?.copyWith(color: AppColors.warning),
            ),
          ),
          Text(
            fmt.format(currentAmount),
            style: tt.labelLarge?.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
