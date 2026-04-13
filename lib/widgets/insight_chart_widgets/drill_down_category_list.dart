import 'package:flutter/material.dart';

import '../../constants/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../features/insights/cubit/insights_cubit.dart';
import '../../features/transaction/model/transaction_model.dart';
import '../../l10n/generated/app_localizations.dart';
import 'empty_box.dart';

class DrillDownCategoryList extends StatelessWidget {
  final InsightsState state;
  final ValueChanged<String?> onCategoryTap;

  const DrillDownCategoryList({
    super.key,
    required this.state,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    final categories = state.expensesByCategory.entries.toList();

    if (categories.isEmpty) {
      return emptyBox(context, appLocalizations!.noCategoryDataForThisPeriod);
    }

    return Column(
      children: categories.map((entry) {
        final engCat = Constants.normalizeKey(entry.key);
        final cat = Constants.expenseCategoryLabel(context, entry.key);
        final amt = entry.value;
        final isSelected = state.selectedCategory != null
            ? Constants.expenseCategoryLabel(
                    context,
                    state.selectedCategory!,
                  ) ==
                  cat
            : false;
        final isAlert = state.alertCategories.contains(cat);
        final pct = state.currentPeriodExpenses == 0
            ? 0.0
            : (amt / state.currentPeriodExpenses * 100);
        final icon = Constants.categoryIcon(cat);

        return _CategoryRow(
          key: ValueKey(cat),
          category: cat,
          amount: amt,
          pct: pct,
          icon: icon,
          isSelected: isSelected,
          isAlert: isAlert,
          transactions: isSelected ? state.drillDownTransactions : [],
          onTap: () => onCategoryTap(isSelected ? null : engCat),
        );
      }).toList(),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String category;
  final double amount;
  final double pct;
  final IconData icon;
  final bool isSelected;
  final bool isAlert;
  final List<dynamic> transactions;
  final VoidCallback onTap;

  const _CategoryRow({
    super.key,
    required this.category,
    required this.amount,
    required this.pct,
    required this.icon,
    required this.isSelected,
    required this.isAlert,
    required this.transactions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final fmt = CurrencyFormatter.of(context);
    AppLocalizations? appLocalizations = AppLocalizations.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.4)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // ── Header row ─────────────────────────────────────────────
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Category icon pill
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isAlert
                          ? AppColors.warningLight
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: isAlert ? AppColors.warning : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name + progress bar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                category,
                                style: tt.labelLarge,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isAlert) ...[
                              const SizedBox(width: 5),
                              const Text('⚠️', style: TextStyle(fontSize: 11)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (pct / 100).clamp(0.0, 1.0),
                            minHeight: 4,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isAlert ? AppColors.warning : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Amount + percentage
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        fmt.format(amount),
                        style: tt.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isAlert ? AppColors.warning : null,
                        ),
                      ),
                      Text('${pct.toStringAsFixed(1)}%', style: tt.bodySmall),
                    ],
                  ),
                  const SizedBox(width: 6),
                  // Chevron
                  AnimatedRotation(
                    turns: isSelected ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded transaction list ───────────────────────────────
          if (isSelected) ...[
            Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: Theme.of(context).colorScheme.outline,
            ),
            if (transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appLocalizations!.noTransactionsInThisPeriod,
                      style: tt.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
                itemBuilder: (ctx, i) {
                  final txn = transactions[i] as TransactionModel;
                  return _TransactionTile(txn: txn);
                },
              ),
          ],
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel txn;

  const _TransactionTile({required this.txn});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final fmt = CurrencyFormatter.of(context);

    // NOTE: Replace `txn.title` with the correct field name in your
    // TransactionModel (e.g., txn.note, txn.description, txn.name).
    // The cubit confirms: .isExpense, .category, .amount, .date exist.
    final displayTitle = Constants.expenseCategoryLabel(context, txn.category);
    final notesTitle = Constants.expenseCategoryLabel(context, txn.notes);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (notesTitle.isNotEmpty)
                  Text(
                    notesTitle,
                    style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w400),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(_formatDate(txn.date), style: tt.bodySmall),
              ],
            ),
          ),
          Text(
            fmt.format(txn.amount),
            style: tt.labelLarge?.copyWith(
              color: AppColors.expense,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}
