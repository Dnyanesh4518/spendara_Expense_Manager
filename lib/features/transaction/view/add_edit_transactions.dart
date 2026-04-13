import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../constants/constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../widgets/group_category_picker.dart';
import '../../../widgets/widgets.dart';
import '../cubit/transaction_cubit.dart';
import '../model/transaction_model.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final TransactionModel? existing; // null = add mode, non-null = edit mode

  const AddEditTransactionScreen({super.key, this.existing});

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late TabController _typeTabController;
  late String _selectedType; // 'expense' | 'income'
  late String _selectedCategory;
  late DateTime _selectedDate;
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  bool _initialized = false; // ← guard flag to run setup only once

  @override
  void initState() {
    super.initState();
    final e = widget.existing;

    // ✅ Safe — no context needed here
    _selectedType = e?.type ?? 'expense';
    _selectedDate = e?.date ?? DateTime.now();

    _typeTabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _selectedType == 'expense' ? 0 : 1,
    );

    if (e != null) {
      _amountCtrl.text = e.amount.toStringAsFixed(e.amount % 1 == 0 ? 0 : 2);
      _notesCtrl.text = e.notes;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ Safe — context is fully available here
    // Guard ensures category init runs only once (not on every rebuild)
    if (!_initialized) {
      _selectedCategory =
          widget.existing?.category ?? Constants.expenseCategoryKeys.first;
      _initialized = true;
    }

    // ✅ Re-register listener here (safe to use context in listener too)
    _typeTabController.removeListener(_onTabChanged);
    _typeTabController.addListener(_onTabChanged);
  }

  // ── Extract listener to a named method ──────────────────────
  void _onTabChanged() {
    if (_typeTabController.indexIsChanging) return;
    setState(() {
      _selectedType = _typeTabController.index == 0 ? 'expense' : 'income';
      _selectedCategory = _selectedType == 'expense'
          ? Constants
                .expenseCategoryKeys
                .first // 'food_dining'
          : Constants.incomeCategoryKeys.first; // 'salary'
    });
  }

  @override
  void dispose() {
    _typeTabController.removeListener(_onTabChanged); // ✅ clean up
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    _typeTabController.dispose();
    super.dispose();
  }

  List<CategoryGroup> get _categories => _selectedType == 'expense'
      ? Constants.expenseCategoryGroups(context) // localized labels ✅
      : Constants.incomeCategoryGroups(context);

  Color get _typeColor =>
      _selectedType == 'expense' ? AppColors.expense : AppColors.income;

  Color get _typeBgColor => _selectedType == 'expense'
      ? AppColors.expenseLight
      : AppColors.incomeLight;

  // ── Save ───────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final amount = double.parse(_amountCtrl.text.replaceAll(',', ''));

    final transaction = TransactionModel(
      id: _isEditing ? widget.existing!.id : const Uuid().v4(),
      amount: amount,
      type: _selectedType,
      category: _selectedCategory,
      date: _selectedDate,
      notes: _notesCtrl.text.trim(),
    );

    final cubit = context.read<TransactionCubit>();
    if (_isEditing) {
      await cubit.updateTransaction(transaction);
    } else {
      await cubit.addTransaction(transaction);
    }
    if (mounted) Navigator.of(context).pop();
  }

  // ── Date picker ────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ── Delete (edit mode only) ────────────────────────────────
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        AppLocalizations? appLocalizations = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(
            appLocalizations?.deleteTransaction ?? 'Delete transaction?',
          ),
          content: Text(
            appLocalizations?.actionCannotBeUndone ??
                'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(appLocalizations?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.expense),
              child: Text(appLocalizations?.delete ?? 'Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await context.read<TransactionCubit>().deleteTransaction(
        widget.existing!.id,
      );
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditing
              ? appLocalizations?.editTransaction ?? 'Edit transaction'
              : appLocalizations?.addTransaction ?? 'Add transaction',
          style: tt.headlineMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.expense,
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            // ── Type toggle (Expense / Income) ──────────────
            TypeToggle(controller: _typeTabController),
            const SizedBox(height: 12),

            // ── Amount field ────────────────────────────────
            SectionLabel(label: appLocalizations?.amount ?? 'Amount'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: tt.displayLarge?.copyWith(
                fontSize: 36,
                color: _typeColor,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: tt.displayLarge?.copyWith(
                  fontSize: 36,
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w700,
                ),
                prefixText: '${appLocalizations?.currencySymbol}  ',
                prefixStyle: tt.headlineMedium?.copyWith(
                  color: _typeColor.withValues(alpha: 0.6),
                ),
                filled: true,
                fillColor: _typeBgColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _typeColor.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: _typeColor, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.expense),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.expense,
                    width: 2,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return appLocalizations?.pleaseEnterAmount ??
                      'Please enter an amount';
                }
                final parsed = double.tryParse(v.replaceAll(',', ''));
                if (parsed == null || parsed <= 0) {
                  return appLocalizations?.enterValidAmount ??
                      'Enter a valid amount greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            // ── Date picker ─────────────────────────────────
            SectionLabel(label: appLocalizations?.date ?? 'Date'),
            const SizedBox(height: 8),
            DateField(date: _selectedDate, onTap: _pickDate),
            const SizedBox(height: 12),

            // ── Notes ───────────────────────────────────────
            SectionLabel(
              label: appLocalizations?.notesOptional ?? 'Notes (optional)',
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              maxLength: 120,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintStyle: tt.bodySmall,
                hintText: appLocalizations?.addANote ?? 'Add a note...',
                alignLabelWithHint: true,
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            // ── Category picker ─────────────────────────────
            SectionLabel(label: appLocalizations?.category ?? 'Category'),
            const SizedBox(height: 10),
            GroupedCategoryPicker(
              groups: _categories,
              selected: _selectedCategory,
              typeColor: _typeColor,
              typeBgColor: _typeBgColor,
              onSelect: (key) => setState(() => _selectedCategory = key),
            ),
            // ── Save button ─────────────────────────────────
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _typeColor,
                disabledBackgroundColor: _typeColor.withValues(alpha: 0.5),
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
                      _isEditing
                          ? appLocalizations?.updateTransaction ??
                                'Update transaction'
                          : appLocalizations?.saveTransaction ??
                                'Save transaction',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
