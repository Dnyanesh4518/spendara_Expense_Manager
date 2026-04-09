import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../l10n/generated/app_localizations.dart';

class GoalsEmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const GoalsEmptyState({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.incomeLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.flag_outlined,
              size: 44,
              color: AppColors.income,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            appLocalizations?.noGoalsYet ?? 'No goals yet',
            style: tt.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            appLocalizations?.setSavingsGoal ??
                'Set a savings goal and track\nyour progress over time.',
            style: tt.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              appLocalizations?.createFirstGoal ?? 'Create your first goal',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.income,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                inherit: true, // Forces consistent inheritance
              ),
              minimumSize: const Size(200, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
