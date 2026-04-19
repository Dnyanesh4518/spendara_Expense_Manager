import 'package:Spendara/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../constants/constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../cubit/budget_cubit.dart';
import '../model/budget_model.dart';

class CreateBudgetScreen extends StatefulWidget {
  final BudgetModel? existing;
  const CreateBudgetScreen({super.key, this.existing});

  @override
  State<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends State<CreateBudgetScreen>
    with TickerProviderStateMixin {
  // ── Step controller ────────────────────────────────────────
  final _pageCtrl = PageController();
  int _step = 0;

  // ── Step 1 ─────────────────────────────────────────────────
  final _totalCtrl = TextEditingController();
  late int _selectedMonth;
  late int _selectedYear;

  // ── Step 2 ─────────────────────────────────────────────────
  final Map<String, TextEditingController> _catCtrls = {};

  // ── Step 3 ─────────────────────────────────────────────────
  final Map<String, int> _priorities = {}; // 1=High 2=Medium 3=Low

  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final e = widget.existing;
    _selectedMonth = e?.month ?? now.month;
    _selectedYear = e?.year ?? now.year;

    if (e != null) {
      _totalCtrl.text = e.totalBudget.toStringAsFixed(0);
    }

    // Pre-fill controllers for existing budget
    for (final key in Constants.expenseCategoryKeys) {
      _catCtrls[key] = TextEditingController(
        text: e?.categoryBudgets[key] != null && e!.categoryBudgets[key]! > 0
            ? e.categoryBudgets[key]!.toStringAsFixed(0)
            : '',
      );
      _priorities[key] = e?.priorities[key] ?? 2; // default Medium
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _totalCtrl.dispose();
    for (final c in _catCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Computed ────────────────────────────────────────────────
  double get _totalBudget =>
      double.tryParse(_totalCtrl.text.replaceAll(',', '')) ?? 0;

  double get _totalAllocated => _catCtrls.values.fold(0.0, (s, c) {
    return s + (double.tryParse(c.text.replaceAll(',', '')) ?? 0);
  });

  bool get _isOverAllocated =>
      _totalAllocated > _totalBudget && _totalBudget > 0;

  Map<String, double> get _categoryBudgets {
    final map = <String, double>{};
    for (final entry in _catCtrls.entries) {
      final v = double.tryParse(entry.value.text.replaceAll(',', '')) ?? 0;
      if (v > 0) map[entry.key] = v;
    }
    return map;
  }

  // ── Navigation ──────────────────────────────────────────────
  void _next() {
    if (_step == 0 && _totalBudget <= 0) return;
    if (_step < 2) {
      setState(() => _step++);
      _pageCtrl.animateToPage(
        _step,
        duration: const Duration(milliseconds: 340),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _save();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pageCtrl.animateToPage(
        _step,
        duration: const Duration(milliseconds: 340),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  // ── Save ────────────────────────────────────────────────────
  Future<void> _save() async {
    setState(() => _isSaving = true);
    final cubit = context.read<BudgetCubit>();
    final nav = Navigator.of(context);

    final budget = BudgetModel(
      id: _isEditing ? widget.existing!.id : const Uuid().v4(),
      month: _selectedMonth,
      year: _selectedYear,
      totalBudget: _totalBudget,
      categoryBudgets: _categoryBudgets,
      priorities: Map.from(_priorities)
        ..removeWhere((k, _) => !_categoryBudgets.containsKey(k)),
    );

    await cubit.saveBudget(budget);
    if (mounted) nav.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(_step == 0 ? Icons.close : Icons.arrow_back),
          onPressed: _back,
        ),
        title: Text(
          _isEditing ? l10n.editBudget : l10n.createBudget,
          style: tt.headlineMedium,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: _StepIndicator(current: _step, total: 3),
        ),
      ),
      body: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _Step1(
            totalCtrl: _totalCtrl,
            month: _selectedMonth,
            year: _selectedYear,
            onMonthYearChanged: (m, y) => setState(() {
              _selectedMonth = m;
              _selectedYear = y;
            }),
            onChanged: () => setState(() {}),
          ),
          _Step2(
            catCtrls: _catCtrls,
            totalBudget: _totalBudget,
            totalAllocated: _totalAllocated,
            isOverAllocated: _isOverAllocated,
            onChanged: () => setState(() {}),
          ),
          _Step3(
            categoryBudgets: _categoryBudgets,
            priorities: _priorities,
            onChanged: (key, val) => setState(() => _priorities[key] = val),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton(
            onPressed: (_isSaving || (_step == 0 && _totalBudget <= 0))
                ? null
                : _next,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    _step == 2 ? l10n.saveBudget : l10n.next,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Step indicator ─────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int current, total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i <= current;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            margin: EdgeInsets.only(right: i < total - 1 ? 3 : 0),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary
                  : Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// STEP 1 — Total budget + month/year
// ──────────────────────────────────────────────────────────────
class _Step1 extends StatelessWidget {
  final TextEditingController totalCtrl;
  final int month, year;
  final void Function(int, int) onMonthYearChanged;
  final VoidCallback onChanged;

  const _Step1({
    required this.totalCtrl,
    required this.month,
    required this.year,
    required this.onMonthYearChanged,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;
    final now = DateTime.now();
    final months = Constants.monthLabels(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        Text(l10n.setBudgetTitle, style: tt.headlineLarge),
        const SizedBox(height: 6),
        Text(l10n.setBudgetSubtitle, style: tt.bodyMedium),
        const SizedBox(height: 32),

        // ── Month / Year row ─────────────────────────────────
        // inside _Step1.build()

        // Month dropdown — disable months in the past if year == current year
        _DropdownCard(
          label: l10n.month,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: month,
              isExpanded: true,
              items: List.generate(12, (i) {
                final monthVal = i + 1; // 1–12
                final isPast = year == now.year && monthVal < now.month;
                return DropdownMenuItem<int>(
                  value: monthVal,
                  enabled: !isPast,
                  child: Text(
                    months[i],
                    style: tt.bodyLarge?.copyWith(
                      color: isPast
                          ? Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.3)
                          : null,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (m) {
                if (m != null) onMonthYearChanged(m, year);
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Year dropdown — allow current year and future, not past
        _DropdownCard(
          label: l10n.year,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: year,
              isExpanded: true,
              items: [now.year, now.year + 1].map((y) {
                return DropdownMenuItem<int>(
                  value: y,
                  child: Text('$y', style: tt.bodyLarge),
                );
              }).toList(),
              onChanged: (y) {
                if (y != null) {
                  // If switching to current year, reset month to current if selected is past
                  final newMonth = (y == now.year && month < now.month)
                      ? now.month
                      : month;
                  onMonthYearChanged(newMonth, y);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ── Total budget input ───────────────────────────────
        Text(
          l10n.totalMonthlyBudget,
          style: tt.labelLarge?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: totalCtrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          style: tt.displayLarge?.copyWith(
            fontSize: 30,
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.start,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: tt.displayLarge?.copyWith(
              fontSize: 30,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.2),
              fontWeight: FontWeight.w700,
            ),
            prefixText: '${context.formatter.symbol} ',
            prefixStyle: tt.headlineMedium?.copyWith(
              fontSize: 25,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: AppColors.primaryLight,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownCard extends StatelessWidget {
  final String label;
  final Widget child;
  const _DropdownCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        spacing: 0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
          child,
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// STEP 2 — Category allocation
// ──────────────────────────────────────────────────────────────
class _Step2 extends StatelessWidget {
  final Map<String, TextEditingController> catCtrls;
  final double totalBudget;
  final double totalAllocated;
  final bool isOverAllocated;
  final VoidCallback onChanged;

  const _Step2({
    required this.catCtrls,
    required this.totalBudget,
    required this.totalAllocated,
    required this.isOverAllocated,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;
    final remaining = totalBudget - totalAllocated;
    final progress = totalBudget > 0
        ? (totalAllocated / totalBudget).clamp(0.0, 1.0)
        : 0.0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        Text(l10n.allocateBudgetTitle, style: tt.headlineLarge),
        const SizedBox(height: 6),
        Text(l10n.allocateBudgetSubtitle, style: tt.bodyMedium),
        const SizedBox(height: 20),

        // ── Live total tracker ───────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isOverAllocated
                ? AppColors.expenseLight
                : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isOverAllocated
                  ? AppColors.expense.withValues(alpha: 0.3)
                  : AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.allocated, style: tt.bodySmall),
                      Text(
                        '${l10n.currencySymbol}${totalAllocated.toStringAsFixed(0)}',
                        style: tt.labelLarge?.copyWith(
                          color: isOverAllocated
                              ? AppColors.expense
                              : AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isOverAllocated ? l10n.overBudget : l10n.remaining,
                        style: tt.bodySmall,
                      ),
                      Text(
                        '${l10n.currencySymbol}${remaining.abs().toStringAsFixed(0)}',
                        style: tt.labelLarge?.copyWith(
                          color: isOverAllocated
                              ? AppColors.expense
                              : AppColors.income,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: isOverAllocated
                      ? AppColors.expense.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(
                    isOverAllocated ? AppColors.expense : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Per-category fields ──────────────────────────────
        ...Constants.expenseCategoryGroups(context).expand(
          (group) => [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                children: [
                  Icon(
                    group.icon,
                    size: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    group.label,
                    style: tt.bodySmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
            ...List.generate(group.keys.length, (i) {
              final key = group.keys[i];
              final label = group.labels[i];
              final ctrl = catCtrls[key]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Constants.categoryIcon(key),
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(label, style: tt.bodyMedium)),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: ctrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        textAlign: TextAlign.right,
                        style: tt.labelLarge,
                        onChanged: (val) {
                          final entered =
                              double.tryParse(val.replaceAll(',', '')) ?? 0;

                          // Sum all other fields (not this one)
                          final otherAllocated = catCtrls.entries
                              .where((e) => e.key != key)
                              .fold(
                                0.0,
                                (sum, e) =>
                                    sum +
                                    (double.tryParse(
                                          e.value.text.replaceAll(',', ''),
                                        ) ??
                                        0),
                              );

                          final maxAllowed = (totalBudget - otherAllocated)
                              .clamp(0.0, totalBudget);

                          if (entered > maxAllowed && totalBudget > 0) {
                            final clamped = maxAllowed.toStringAsFixed(
                              maxAllowed % 1 == 0 ? 0 : 2,
                            );
                            ctrl.value = TextEditingValue(
                              text: clamped,
                              selection: TextSelection.collapsed(
                                offset: clamped.length,
                              ),
                            );
                          }
                          onChanged();
                        },
                        decoration: InputDecoration(
                          hintStyle: tt.bodySmall!.copyWith(
                            color: AppColors.warningLight,
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          prefixText:
                              '${AppLocalizations.of(context)?.currencySymbol ?? '₹'} ',
                          prefixStyle: tt.bodySmall,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.4),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.4),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// STEP 3 — Priority assignment
// ──────────────────────────────────────────────────────────────
class _Step3 extends StatelessWidget {
  final Map<String, double> categoryBudgets;
  final Map<String, int> priorities;
  final void Function(String key, int value) onChanged;

  const _Step3({
    required this.categoryBudgets,
    required this.priorities,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;

    final allocated = categoryBudgets.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (allocated.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noCategoriesAllocated,
                textAlign: TextAlign.center,
                style: tt.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        Text(l10n.setPrioritiesTitle, style: tt.headlineLarge),
        const SizedBox(height: 6),
        Text(l10n.setPrioritiesSubtitle, style: tt.bodyMedium),
        const SizedBox(height: 24),
        ...allocated.map((entry) {
          final key = entry.key;
          final label = Constants.categoryLabel(context, key);
          final prio = priorities[key] ?? 2;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _priorityColor(prio).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Constants.categoryIcon(key),
                    size: 16,
                    color: _priorityColor(prio),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: tt.labelLarge),
                      Text(
                        '${l10n.currencySymbol}${entry.value.toStringAsFixed(0)}',
                        style: tt.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Priority toggle chips
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [1, 2, 3].map((p) {
                    final selected = prio == p;
                    final label = _priorityLabel(p, l10n);
                    return GestureDetector(
                      onTap: () => onChanged(key, p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        margin: EdgeInsets.only(left: p == 1 ? 0 : 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? _priorityColor(p)
                              : _priorityColor(p).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _priorityColor(
                              p,
                            ).withValues(alpha: selected ? 0.0 : 0.3),
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : _priorityColor(p),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _priorityColor(int p) {
    return switch (p) {
      1 => AppColors.expense, // High → red/coral
      2 => AppColors.warning, // Medium → amber
      _ => AppColors.income, // Low → green
    };
  }

  String _priorityLabel(int p, AppLocalizations l10n) {
    return switch (p) {
      1 => l10n.priorityHigh,
      2 => l10n.priorityMedium,
      _ => l10n.priorityLow,
    };
  }
}
