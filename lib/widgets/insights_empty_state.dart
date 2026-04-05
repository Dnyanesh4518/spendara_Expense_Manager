import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../l10n/generated/app_localizations.dart';

class InsightsEmptyState extends StatelessWidget {
  const InsightsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.insights_outlined,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              appLocalizations?.noInsightsYet ?? 'No insights yet',
              style: tt.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              appLocalizations?.addFewTransactions ??
                  'Add a few transactions and your\nspending patterns will appear here.',
              style: tt.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
