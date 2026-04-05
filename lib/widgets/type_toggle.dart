import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../l10n/generated/app_localizations.dart';

class TypeToggle extends StatelessWidget {
  final TabController controller;
  const TypeToggle({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: controller.index == 0
              ? AppColors.expenseLight
              : AppColors.incomeLight,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_upward_rounded,
                  size: 16,
                  color: AppColors.expense,
                ),
                const SizedBox(width: 6),
                Text(
                  appLocalizations?.expense ?? 'Expense',
                  style: TextStyle(
                    color: controller.index == 0
                        ? AppColors.expense
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_downward_rounded,
                  size: 16,
                  color: AppColors.income,
                ),
                const SizedBox(width: 6),
                Text(
                  appLocalizations?.income ?? 'Income',
                  style: TextStyle(
                    color: controller.index == 1
                        ? AppColors.income
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
