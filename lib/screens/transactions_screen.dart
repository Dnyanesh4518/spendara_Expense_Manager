import 'package:Spendara/core/crashlytics/crashlytics_keys.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../constants/constants.dart';
import '../core/analytics/analytics_keys.dart';
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

  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  static const String filterAll = 'All';
  static const String filterIncome = 'Income';
  static const String filterExpense = 'Expense';

  List get _activeCategories {
    if (_filter == 'Income') return Constants.incomeCategories(context);
    if (_filter == 'Expense') return Constants.expenseCategories(context);
    return [
      ...Constants.expenseCategories(context),
      ...Constants.incomeCategories(context),
    ];
  }

  void _enterSelectionMode(String id) {
    setState(() {
      _isSelectionMode = true;
      _selectedIds.add(id);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _deleteSelected(
    BuildContext context,
    AppLocalizations? l10n,
  ) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n?.deleteTransaction ?? 'Delete transaction?'),
          content: Text(
            l10n?.actionCannotBeUndone ?? 'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.expense),
              child: Text(l10n?.delete ?? 'Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        await context.read<TransactionCubit>().deleteMultiple(
          _selectedIds.toList(),
        );
        _exitSelectionMode();
      }
    } catch (e) {
      FirebaseCrashlytics.instance.log(CrashlyticsKeys.deleteTransactionUI);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exitSelectionMode();
      },
      child: BlocConsumer<TransactionCubit, TransactionState>(
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
              _ => appLocalizations?.all ?? 'All',
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
                  titleSpacing: _isSelectionMode ? 0 : 20,
                  automaticallyImplyLeading: !_isSelectionMode,

                  // Close button in selection mode
                  leading: _isSelectionMode
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _exitSelectionMode,
                          tooltip: 'Cancel selection',
                        )
                      : null,

                  // Title shows count in selection mode
                  title: _isSelectionMode
                      ? Text(
                          '${_selectedIds.length} selected',
                          style: tt.headlineMedium,
                        )
                      : Text(
                          appLocalizations?.transactions ?? 'Transactions',
                          style: tt.headlineMedium,
                        ),

                  // Actions: select-all + delete in selection mode
                  actions: _isSelectionMode
                      ? [
                          IconButton(
                            icon: Icon(
                              _selectedIds.length == filtered.length
                                  ? Icons.deselect
                                  : Icons.select_all,
                            ),
                            tooltip: _selectedIds.length == filtered.length
                                ? 'Deselect all'
                                : 'Select all',
                            onPressed: () => setState(() {
                              if (_selectedIds.length == filtered.length) {
                                _selectedIds.clear();
                                _isSelectionMode = false;
                              } else {
                                _selectedIds
                                  ..clear()
                                  ..addAll(filtered.map((t) => t.id));
                              }
                            }),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: _selectedIds.isNotEmpty
                                ? AppColors.expense
                                : null,
                            tooltip: 'Delete selected',
                            onPressed: _selectedIds.isNotEmpty
                                ? () =>
                                      _deleteSelected(context, appLocalizations)
                                : null,
                          ),
                          const SizedBox(width: 8),
                        ]
                      : [],

                  // Search + filter bar hidden in selection mode
                  bottom: _isSelectionMode
                      ? null
                      : PreferredSize(
                          preferredSize: const Size.fromHeight(112),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Column(
                              children: [
                                TextField(
                                  onChanged: (v) => setState(() => _query = v),
                                  decoration: InputDecoration(
                                    hintStyle: tt.bodySmall,
                                    hintText:
                                        appLocalizations?.searchTransactions ??
                                        'Search transactions...',
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      size: 20,
                                    ),
                                    isDense: true,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
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
                                                  checkmarkColor:
                                                      tt.bodySmall!.color,
                                                  backgroundColor: AppColors
                                                      .warning
                                                      .withValues(alpha: 0.20),
                                                  label: Text(filterLabel(f)),
                                                  selected: selected,
                                                  onSelected: (_) => setState(() {
                                                    _filter = f;
                                                    _selectedCategory = null;
                                                    // Clear selection when filter changes
                                                    _isSelectionMode = false;
                                                    _selectedIds.clear();
                                                  }),
                                                  selectedColor: AppColors
                                                      .primary
                                                      .withValues(alpha: 0.25),
                                                  labelStyle: TextStyle(
                                                    color: selected
                                                        ? AppColors.primary
                                                        : Theme.of(context)
                                                              .textTheme
                                                              .bodySmall
                                                              ?.color,
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
                                    Badge(
                                      isLabelVisible: _selectedCategory != null,
                                      child: IconButton(
                                        onPressed: () {
                                          _showCategoryFilter(context);
                                          FirebaseAnalytics.instance.logEvent(
                                            name: AnalyticsKeys
                                                .transactionFilterTap,
                                          );
                                        },
                                        icon: Icon(
                                          Icons.filter_list_rounded,
                                          color: _selectedCategory != null
                                              ? AppColors.primary
                                              : Theme.of(
                                                  context,
                                                ).iconTheme.color,
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () => setState(
                                          () => _selectedCategory = null,
                                        ),
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

                // ── Transaction list ─────────────────────────────────────────
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    child: _EmptyState(
                      filter: _filter,
                      query: _query,
                      onAdd: () {
                        Navigator.of(
                          context,
                        ).push(slideUp(const AddEditTransactionScreen()));
                        if (context.mounted) {
                          context.read<DashboardCubit>().load();
                          context.read<InsightsCubit>().load();
                        }
                        FirebaseAnalytics.instance.logEvent(
                          name: AnalyticsKeys.addTransaction,
                        );
                      },
                    ),
                  )
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
                              padding: const EdgeInsets.only(
                                left: 4,
                                bottom: 8,
                              ),
                              child: Text(
                                entry.key,
                                style: tt.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.5),
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
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: entry.value.length,
                                  separatorBuilder: (_, __) => Divider(
                                    height: 1,
                                    indent: 16,
                                    endIndent: 16,
                                    color: Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.3),
                                  ),
                                  itemBuilder: (_, j) {
                                    final t = entry.value[j];
                                    final isSelected = _selectedIds.contains(
                                      t.id,
                                    );

                                    return GestureDetector(
                                      // Long press to enter selection mode
                                      onLongPress: _isSelectionMode
                                          ? null
                                          : () => _enterSelectionMode(t.id),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 150,
                                        ),
                                        color: isSelected
                                            ? AppColors.primary.withValues(
                                                alpha: 0.08,
                                              )
                                            : Colors.transparent,
                                        child: Row(
                                          children: [
                                            // Animated checkbox slides in
                                            AnimatedSize(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              curve: Curves.easeInOut,
                                              child: _isSelectionMode
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: 12,
                                                          ),
                                                      child: Checkbox(
                                                        value: isSelected,
                                                        onChanged: (_) =>
                                                            _toggleSelection(
                                                              t.id,
                                                            ),
                                                        activeColor:
                                                            AppColors.primary,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4,
                                                              ),
                                                        ),
                                                      ),
                                                    )
                                                  : const SizedBox.shrink(),
                                            ),

                                            // Tile — tap toggles in selection mode
                                            Expanded(
                                              child: TransactionTile(
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
                                                date: DateFormat(
                                                  "dd-MM-yyyy",
                                                ).format(t.date),
                                                isExpense: t.isExpense,
                                                categoryIcon: t.isExpense
                                                    ? Icons.arrow_downward
                                                    : Icons.arrow_upward,
                                                onTap: _isSelectionMode
                                                    ? () =>
                                                          _toggleSelection(t.id)
                                                    : () {
                                                        Navigator.of(
                                                          context,
                                                        ).push(
                                                          slideUp(
                                                            AddEditTransactionScreen(
                                                              existing: t,
                                                            ),
                                                          ),
                                                        );
                                                        FirebaseAnalytics
                                                            .instance
                                                            .logEvent(
                                                              name: AnalyticsKeys
                                                                  .transactionTap,
                                                            );
                                                      },
                                                onDelete: () {},
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      }, childCount: grouped.length),
                    ),
                  ),
              ],
            ),
            floatingActionButton: filtered.isNotEmpty && !_isSelectionMode
                ? FloatingActionButton(
                    heroTag: "add",
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).push(slideUp(const AddEditTransactionScreen()));
                      if (context.mounted) {
                        context.read<DashboardCubit>().load();
                        context.read<InsightsCubit>().load();
                      }
                      FirebaseAnalytics.instance.logEvent(
                        name: AnalyticsKeys.addTransactionPlus,
                      );
                    },
                    child: const Icon(Icons.add),
                  )
                : null,
          );
        },
      ),
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

      final matchCategory =
          _selectedCategory == null || t.category == _selectedCategory;

      return matchFilter && matchQuery && matchCategory;
    }).toList();
  }

  void _showCategoryFilter(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
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
            child: ListView(
              children: [
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
                        child: Text(
                          AppLocalizations.of(context)?.clear ?? 'Clear',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
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
                            Constants.categoryIcon(cat),
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
}

Map<String, List<TransactionModel>> _groupByDate(List<TransactionModel> txns) {
  final map = <String, List<TransactionModel>>{};
  for (final t in txns) {
    final key = DateFormat('dd MMM yyyy').format(t.date);
    map.putIfAbsent(key, () => []).add(t);
  }
  return map;
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  final String filter;
  final String query;
  const _EmptyState({
    required this.filter,
    required this.onAdd,
    required this.query,
  });
  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
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
            textAlign: TextAlign.center,
            appLocalizations?.noTransactionsFound ?? 'No transactions found',
            style: tt.headlineSmall,
          ),
          const SizedBox(height: 6),
          if (query.isEmpty)
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                appLocalizations?.addTransaction ?? 'Add your transaction',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                minimumSize: const Size(80, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
        ],
      ),
    );
  }
}
