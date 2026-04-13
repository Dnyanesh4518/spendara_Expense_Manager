import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TransactionTile extends StatelessWidget {
  final String category;
  final String? notes;
  final String amount;
  final String date;
  final bool isExpense;
  final IconData categoryIcon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.category,
    this.notes,
    required this.amount,
    required this.date,
    required this.isExpense,
    required this.categoryIcon,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          spacing: 10,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isExpense
                    ? AppColors.expenseLight
                    : AppColors.incomeLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                categoryIcon,
                color: isExpense ? AppColors.expense : AppColors.income,
                size: 20,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category, style: tt.labelLarge),
                  if (notes != null && notes!.isNotEmpty)
                    Text(
                      notes!,
                      style: tt.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExpense ? '-' : '+'}$amount',
                  style: tt.labelLarge?.copyWith(
                    color: isExpense ? AppColors.expense : AppColors.income,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(date, style: tt.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );

    // if (onDelete == null) return tile;
    //
    // return Dismissible(
    //   key: ValueKey(category + date),
    //   direction: DismissDirection.endToStart,
    //   background: Container(
    //     alignment: Alignment.centerRight,
    //     padding: const EdgeInsets.only(right: 20),
    //     decoration: BoxDecoration(
    //       color: AppColors.expense.withValues(alpha: 0.1),
    //       borderRadius: BorderRadius.circular(14),
    //     ),
    //     child: const Icon(Icons.delete_outline, color: AppColors.expense),
    //   ),
    //   onDismissed: (_) => onDelete?.call(),
    //   child: tile,
    // );
  }
}
