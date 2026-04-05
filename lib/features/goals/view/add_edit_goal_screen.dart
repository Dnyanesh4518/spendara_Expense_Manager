import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../constants/constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../widgets/widgets.dart';
import '../cubit/goal_cubit.dart';
import '../model/goals_model.dart';

class AddEditGoalScreen extends StatefulWidget {
  final GoalModel? existing;
  const AddEditGoalScreen({super.key, this.existing});

  @override
  State<AddEditGoalScreen> createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends State<AddEditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _savedCtrl = TextEditingController();

  late DateTime _deadline;
  late String _selectedIconKey;
  late int _selectedColorIdx;
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  // ── Available icon options ─────────────────────────────────
  static const _iconOptions = <String, IconData>{
    'shield': Icons.shield_outlined,
    'flight': Icons.flight_outlined,
    'laptop': Icons.laptop_outlined,
    'favorite': Icons.favorite_outline,
    'home': Icons.home_outlined,
    'car': Icons.directions_car_outlined,
    'savings': Icons.savings_outlined,
    'school': Icons.school_outlined,
    'medical': Icons.local_hospital_outlined,
    'gift': Icons.card_giftcard_outlined,
  };

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _deadline = e?.deadline ?? DateTime.now().add(const Duration(days: 90));
    _selectedIconKey = e?.iconName ?? 'savings';
    _selectedColorIdx = e?.colorValue ?? 0;

    if (e != null) {
      _titleCtrl.text = e.title;
      _targetCtrl.text = e.targetAmount.toStringAsFixed(0);
      _savedCtrl.text = e.savedAmount == 0
          ? ''
          : e.savedAmount.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _targetCtrl.dispose();
    _savedCtrl.dispose();
    super.dispose();
  }

  Color get _activeColor =>
      Constants.goalColors[_selectedColorIdx % Constants.goalColors.length];

  // ── Save ───────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final target = double.parse(_targetCtrl.text.replaceAll(',', ''));
    final saved = double.tryParse(_savedCtrl.text.replaceAll(',', '')) ?? 0;

    final goal = GoalModel(
      id: _isEditing ? widget.existing!.id : const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      targetAmount: target,
      savedAmount: saved.clamp(0, target),
      deadline: _deadline,
      iconName: _selectedIconKey,
      colorValue: _selectedColorIdx,
    );

    final cubit = context.read<GoalCubit>();
    _isEditing ? await cubit.updateGoal(goal) : await cubit.addGoal(goal);

    if (mounted) Navigator.of(context).pop();
  }

  // ── Delete ─────────────────────────────────────────────────
  Future<void> _confirmDelete() async {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(appLocalizations?.deleteGoal ?? 'Delete goal?'),
        content: Text(
          appLocalizations?.allProgressLost ??
              'All progress will be lost. This cannot be undone.',
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
      ),
    );
    if (ok == true && mounted) {
      await context.read<GoalCubit>().deleteGoal(widget.existing!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  // ── Deadline picker ────────────────────────────────────────
  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: _activeColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditing
              ? appLocalizations?.editGoal ?? 'Edit goal'
              : appLocalizations?.newGoal ?? 'New goal',
          style: tt.headlineMedium,
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            GoalPreviewCard(
              title: _titleCtrl.text.isEmpty
                  ? appLocalizations?.goalName ?? 'Goal name'
                  : _titleCtrl.text,
              iconKey: _selectedIconKey,
              colorIdx: _selectedColorIdx,
              target: double.tryParse(_targetCtrl.text) ?? 0,
              saved: double.tryParse(_savedCtrl.text) ?? 0,
              deadline: _deadline,
              activeColor: _activeColor,
              iconOptions: _iconOptions,
            ),
            const SizedBox(height: 28),

            // ── Goal title ─────────────────────────────────
            Label(appLocalizations?.goalName ?? 'Goal name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 40,
              decoration: InputDecoration(
                hintStyle: Theme.of(context).textTheme.bodySmall,
                hintText: 'e.g. Emergency fund, Vacation...',
                counterText: '',
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) => v == null || v.trim().isEmpty
                  ? appLocalizations?.pleaseEnterGoalName ??
                        'Please enter a goal name'
                  : null,
            ),
            const SizedBox(height: 20),

            // ── Target + already saved row ─────────────────
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Label(
                        appLocalizations?.targetAmount ?? 'Target amount (₹)',
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _targetCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        decoration: InputDecoration(
                          hintText: '50,000',
                          hintStyle: Theme.of(context).textTheme.bodySmall,
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          final n = double.tryParse(v.replaceAll(',', ''));
                          if (n == null || n <= 0) return 'Must be > 0';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Label(
                        appLocalizations?.alreadySaved ?? 'Already saved (₹)',
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _savedCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: Theme.of(context).textTheme.bodySmall,
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final saved =
                              double.tryParse(v.replaceAll(',', '')) ?? 0;
                          final target =
                              double.tryParse(
                                _targetCtrl.text.replaceAll(',', ''),
                              ) ??
                              0;
                          if (saved < 0) return 'Cannot be negative';
                          if (target > 0 && saved > target) {
                            return 'Exceeds target';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Deadline ───────────────────────────────────
            Label(appLocalizations?.targetDeadline ?? 'Target deadline'),
            const SizedBox(height: 8),
            DeadlineField(
              deadline: _deadline,
              activeColor: _activeColor,
              onTap: _pickDeadline,
            ),
            const SizedBox(height: 24),

            // ── Icon picker ────────────────────────────────
            Label(appLocalizations?.icon ?? 'Icon'),
            const SizedBox(height: 10),
            IconPicker(
              options: _iconOptions,
              selected: _selectedIconKey,
              activeColor: _activeColor,
              onSelect: (k) => setState(() => _selectedIconKey = k),
            ),
            const SizedBox(height: 24),

            // ── Color picker ───────────────────────────────
            Label(appLocalizations?.color ?? 'Color'),
            const SizedBox(height: 10),
            ColorPicker(
              colors: Constants.goalColors,
              selectedIdx: _selectedColorIdx,
              onSelect: (i) => setState(() => _selectedColorIdx = i),
            ),
            const SizedBox(height: 36),

            // ── Save button ────────────────────────────────
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _activeColor,
                disabledBackgroundColor: _activeColor.withValues(alpha: 0.5),
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
                          ? appLocalizations?.updateGoal ?? 'Update goal'
                          : appLocalizations?.createGoal ?? 'Create goal',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
