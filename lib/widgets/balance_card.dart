import 'package:Spendara/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

class BalanceCard extends StatelessWidget {
  final String balance;
  final double savingsProgress;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.savingsProgress,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4A43D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appLocalizations?.currentBalance ?? 'Current balance',
            style: tt.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            context.formatter.format(double.parse(balance)),
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appLocalizations?.savingsGoal ?? 'Savings goal',
                style: tt.bodySmall?.copyWith(color: Colors.white70),
              ),
              Text(
                '${(savingsProgress * 100).toInt()}%',
                style: tt.labelSmall?.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: savingsProgress,
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
