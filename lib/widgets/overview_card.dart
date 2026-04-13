import 'package:Spendara/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

import '../features/goals/cubit/goal_cubit.dart';
import '../l10n/generated/app_localizations.dart';

class OverviewCard extends StatelessWidget {
  final GoalState state;
  const OverviewCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);

    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D9E75), Color(0xFF0F6E56)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appLocalizations?.totalSaved ?? 'Total saved',
            style: tt.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            context.formatter.format(state.totalSaved),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            context.formatter.format(state.totalTarget),
            style: tt.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: state.overallProgress,
              minHeight: 6,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
