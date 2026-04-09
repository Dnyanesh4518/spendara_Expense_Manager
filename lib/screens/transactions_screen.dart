import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../constants/constants.dart';
import '../core/theme/app_colors.dart';
import '../features/dashboard/cubit/dashboard_cubit.dart';
import '../features/insights/cubit/insights_cubit.dart';
import '../features/transaction/cubit/transaction_cubit.dart';
import '../features/transaction/model/transaction_model.dart';
import '../features/transaction/view/add_edit_transactions.dart';
import '../l10n/generated/app_localizations.dart';
import '../routes/transitions.dart';
import '../widgets/widgets.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _filter = 'All';
  String _query = '';
  String? _selectedCategory;

  // Define filter keys as constants — never change these
  static const String filterAll = 'All';
  static const String filterIncome = 'Income';
  static const String filterExpense = 'Expense';

  List<String> get _activeCategories {
    if (_filter == 'Income') return Constants.incomeCategories(context);
    if (_filter == 'Expense') return Constants.expenseCategories(context);
    return [
      ...Constants.expenseCategories(context),
      ...Constants.incomeCategories(context),
    ]; // All
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return BlocConsumer<TransactionCubit, TransactionState>(
      listener: (context, state) {
        if (state.status == TransactionStatus.success) {
          if (context.mounted) {
            context.read<DashboardCubit>().load();
            context.read<InsightsCubit>().load();
          }
        }
      },
      builder: (context, state) {
        String filterLabel(String key) {
          return switch (key) {
            'Income' => appLocalizations?.income ?? 'Income',
            'Expense' => appLocalizations?.expense ?? 'Expense',
            _ => appLocalizations?.all ?? 'All', // 'All'
          };
        }

        final filtered = _applyFilters(state.transactions);
        final grouped = _groupByDate(filtered);

        if (state.status == TransactionStatus.loading ||
            state.status == TransactionStatus.initial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                titleSpacing: 20,
                title: Text(
                  appLocalizations?.transactions ?? 'Transactions',
                  style: tt.headlineMedium,
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(112),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (v) => setState(() => _query = v),
                          decoration: InputDecoration(
                            hintText:
                                appLocalizations?.searchTransactions ??
                                'Search transactions...',
                            prefixIcon: Icon(Icons.search, size: 20),
                            isDense: true,
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            // ── Scrollable chips ──────────────────────────────────────
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    ...[
                                      filterAll,
                                      filterIncome,
                                      filterExpense,
                                    ].map((f) {
                                      final selected = _filter == f;
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: ChoiceChip(
                                          checkmarkColor: tt.bodySmall!.color,
                                          backgroundColor: AppColors.warning
                                              .withValues(alpha: 0.20),
                                          label: Text(filterLabel(f)),
                                          selected: selected,
                                          onSelected: (_) => setState(() {
                                            _filter = f;
                                            _selectedCategory = null;
                                          }),
                                          selectedColor: AppColors.primary
                                              .withValues(alpha: 0.25),
                                          labelStyle: TextStyle(
                                            color: selected
                                                ? AppColors.primary
                                                : Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall?.color,
                                            fontWeight: selected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            fontSize: 13,
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),

                            // ── Category filter button — stays fixed on right ─────────
                            Badge(
                              isLabelVisible: _selectedCategory != null,
                              child: IconButton(
                                onPressed: () => _showCategoryFilter(context),
                                icon: Icon(
                                  Icons.filter_list_rounded,
                                  color: _selectedCategory != null
                                      ? AppColors.primary
                                      : Theme.of(context).iconTheme.color,
                                ),
                                tooltip: 'Filter by category',
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                        if (_selectedCategory != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.label_outline,
                                size: 13,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _selectedCategory!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedCategory = null),
                                child: Icon(
                                  Icons.close,
                                  size: 13,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (filtered.isEmpty)
                SliverFillRemaining(child: _EmptyState(filter: _filter))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      final entry = grouped.entries.elementAt(i);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              entry.key,
                              style: tt.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topCenter,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withValues(alpha: 0.4),
                              ),
                            ),
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: entry.value.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withValues(alpha: 0.3),
                              ),
                              itemBuilder: (_, j) {
                                final t = entry.value[j];
                                return TransactionTile(
                                  category: t.isExpense
                                      ? Constants.expenseCategoryLabel(
                                          context,
                                          t.category,
                                        )
                                      : Constants.incomeCategoryLabel(
                                          context,
                                          t.category,
                                        ),
                                  notes: t.notes,
                                  amount:
                                      '${appLocalizations?.currencySymbol}${t.amount.toStringAsFixed(0)}',
                                  date: DateFormat("dd-MM-yyyy").format(t.date),
                                  isExpense: t.isExpense,
                                  categoryIcon: t.isExpense
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      slideUp(
                                        AddEditTransactionScreen(existing: t),
                                      ),
                                    );
                                  },
                                  onDelete: () {},
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }, childCount: grouped.length),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: "add",
            onPressed: () {
              Navigator.of(
                context,
              ).push(slideUp(const AddEditTransactionScreen()));
              if (context.mounted) {
                context.read<DashboardCubit>().load();
                context.read<InsightsCubit>().load();
              }
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  List<TransactionModel> _applyFilters(List<TransactionModel> transactions) {
    return transactions.where((t) {
      final matchFilter =
          _filter == 'All' ||
          (_filter == 'Income' && !t.isExpense) ||
          (_filter == 'Expense' && t.isExpense);

      final matchQuery =
          _query.isEmpty ||
          t.category.toLowerCase().contains(_query.toLowerCase()) ||
          t.notes.toLowerCase().contains(_query.toLowerCase());

      // ✅ new
      final matchCategory =
          _selectedCategory == null || t.category == _selectedCategory;

      return matchFilter && matchQuery && matchCategory;
    }).toList();
  }

  void _showCategoryFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Handle ───────────────────────────────────────────
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ── Header ───────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.filterByCategory ??
                          'Filter by Category',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (_selectedCategory != null)
                      TextButton(
                        onPressed: () {
                          setState(() => _selectedCategory = null);
                          setSheetState(() {});
                        },
                        child: const Text('Clear'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Category chips ───────────────────────────────────
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _activeCategories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _categoryIcon(cat),
                            size: 14,
                            color: isSelected
                                ? AppColors.primary
                                : Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(cat),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = isSelected ? null : cat;
                        });
                        setSheetState(() {});
                        Navigator.pop(context);
                      },
                      selectedColor: AppColors.primaryLight,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        fontSize: 13,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Category → Icon mapping ────────────────────────────────────────
  IconData _categoryIcon(String category) {
    return switch (category) {
      'Food & Dining' => Icons.restaurant_outlined,
      'Transport' => Icons.directions_car_outlined,
      'Shopping' => Icons.shopping_bag_outlined,
      'Utilities' => Icons.bolt_outlined,
      'Healthcare' => Icons.health_and_safety_outlined,
      'Entertainment' => Icons.movie_outlined,
      'Education' => Icons.school_outlined,
      'Salary' => Icons.account_balance_wallet_outlined,
      'Freelance' => Icons.laptop_outlined,
      'Investment' => Icons.trending_up_outlined,
      'Gift' => Icons.card_giftcard_outlined,
      _ => Icons.category_outlined,
    };
  }
}

Map<String, List<TransactionModel>> _groupByDate(List<TransactionModel> txns) {
  final map = <String, List<TransactionModel>>{};
  for (final t in txns) {
    final key = DateFormat('dd MMM yyyy').format(t.date); // ← date only
    map.putIfAbsent(key, () => []).add(t);
  }
  return map;
}

class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});
  @override
  Widget build(BuildContext context) {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            appLocalizations?.noTransactionsFound ?? 'No transactions found',
            style: tt.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            filter == 'All'
                ? appLocalizations?.addFirstTransaction ??
                      'Add your first transaction\nusing the + button'
                : appLocalizations?.noTransactionsYet ??
                      'No $filter transactions yet',
            style: tt.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
