import 'package:Spendara/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatters.dart';
import '../features/transaction/model/transaction_model.dart';
import '../features/transaction/view/add_edit_transactions.dart';
import '../routes/transitions.dart';

class RecentTransactions extends StatelessWidget {
  final List<TransactionModel> txns;
  const RecentTransactions({super.key, required this.txns});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: txns.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
        itemBuilder: (_, i) {
          final t = txns[i];
          return TransactionTile(
            onTap: () {
              Navigator.of(
                context,
              ).push(slideUp(AddEditTransactionScreen(existing: t)));
            },
            category: t.isExpense
                ? Constants.expenseCategoryLabel(context, t.category)
                : Constants.incomeCategoryLabel(context, t.category),
            notes: t.notes,
            amount: context.formatter.format(t.amount),
            date: DateFormatter.relative(t.date),
            isExpense: t.isExpense,
            categoryIcon: Constants.categoryIcon(t.category),
          );
        },
      ),
    );
  }
}
