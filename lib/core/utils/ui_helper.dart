import 'package:flutter/material.dart';

import '../../main.dart';
import '../theme/app_colors.dart';

class UiHelper {
  static void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    final context = navigatorKey.currentState?.overlay?.context;
    if (context == null) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    messenger.clearSnackBars();
    final snackBar = SnackBar(
      padding: const EdgeInsets.all(8),
      duration: duration,
      // Use the passed duration
      content: Text(
        maxLines: 3,
        message,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      backgroundColor: AppColors.primary.withValues(alpha: 0.9),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      margin: const EdgeInsets.only(bottom: 20.0, left: 40, right: 40),
      elevation: 6.0,
      dismissDirection: DismissDirection.horizontal,
    );
    messenger.showSnackBar(snackBar);
  }
}
