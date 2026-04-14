import 'package:Spendara/core/analytics/analytics_keys.dart';
import 'package:Spendara/core/utils/currency_formatter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../constants/constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../cubit/goal_cubit.dart';
import '../model/goals_model.dart';

class DepositSheet extends StatefulWidget {
  final GoalModel goal;
  const DepositSheet({super.key, required this.goal});

  static Future<void> show(BuildContext context, GoalModel goal) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<GoalCubit>(),
        child: DepositSheet(goal: goal),
      ),
    );
  }

  @override
  State<DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends State<DepositSheet> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  GoalModel get _goal => widget.goal;

  Color get _color =>
      Constants.goalColors[_goal.colorValue % Constants.goalColors.length];

  // Quick amount suggestions
  List<double> get _suggestions {
    final remaining = _goal.remaining;
    return [
      (remaining * 0.1).roundToDouble(),
      (remaining * 0.25).roundToDouble(),
      (remaining * 0.5).roundToDouble(),
      remaining,
    ].where((v) => v > 0).toList();
  }

  Future<void> _deposit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final amount = double.parse(_ctrl.text.replaceAll(',', ''));
    await context.read<GoalCubit>().deposit(_goal.id, amount);
    FirebaseAnalytics.instance.logEvent(name: AnalyticsKeys.depositAddedGoal);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final remaining = _goal.remaining;
    final progress = _goal.progress;
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
            shrinkWrap: true,
            children: [
              // ── Drag handle ──────────────────────────────
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Goal header ──────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Constants.goalIcon(_goal.iconName),
                      color: _color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_goal.title, style: tt.labelLarge),
                        Text(
                          '${appLocalizations?.currencySymbol}${_goal.savedAmount.toStringAsFixed(0)}'
                          ' of ${appLocalizations?.currencySymbol}${_goal.targetAmount.toStringAsFixed(0)}',
                          style: tt.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: tt.headlineMedium?.copyWith(color: _color),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Progress bar ─────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: _color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(_color),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${context.formatter.format(remaining)}${appLocalizations?.remaining ?? 'remaining'}',

                style: tt.bodySmall?.copyWith(color: _color),
              ),
              const SizedBox(height: 24),

              // ── Amount input ─────────────────────────────
              Text(
                appLocalizations?.howMuchToAdd ?? "how much to Add?",
                style: tt.headlineSmall,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ctrl,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                style: tt.displayLarge?.copyWith(
                  fontSize: 32,
                  color: _color,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: tt.displayLarge?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                  prefixText: '${appLocalizations?.currencySymbol}',
                  prefixStyle: tt.headlineMedium?.copyWith(
                    color: _color.withValues(alpha: 0.6),
                  ),
                  filled: true,
                  fillColor: _color.withValues(alpha: 0.06),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: _color.withValues(alpha: 0.25),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: _color, width: 2),
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
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return appLocalizations?.pleaseEnterAmount ??
                        'Enter an amount';
                  }
                  final n = double.tryParse(v.replaceAll(',', ''));
                  if (n == null || n <= 0) return 'Must be greater than 0';
                  if (n > remaining) {
                    return '${appLocalizations!.maxYouCanAddIs} ${appLocalizations.currencySymbol}${remaining.toStringAsFixed(0)}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Text(appLocalizations!.quickAdd, style: tt.bodySmall),

              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestions.map((s) {
                  final pct = ((s / _goal.targetAmount) * 100).toInt();
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _ctrl.text = s.toStringAsFixed(0)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _color.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        '${context.formatter.format(s)}  ($pct%)',
                        style: tt.labelSmall?.copyWith(
                          color: _color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // ── Deposit button ───────────────────────────
              ElevatedButton(
                onPressed: _isSaving ? null : _deposit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _color,
                  disabledBackgroundColor: _color.withValues(alpha: 0.4),
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
                        _ctrl.text.isEmpty
                            ? appLocalizations.addFunds
                            : '${appLocalizations.addFunds} ${appLocalizations.currencySymbol}${_ctrl.text}',

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
      ),
    );
  }
}
