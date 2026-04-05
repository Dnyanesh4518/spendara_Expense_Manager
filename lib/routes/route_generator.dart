import 'package:flutter/material.dart';
import '../features/transaction/view/add_edit_transactions.dart';
import '../screens/screens.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.appShell:
        return customPageRoute(const AppShell());
      case AppRoutes.transactionsScreen:
        return customPageRoute(const TransactionsScreen());
      case AppRoutes.goalsScreen:
        return customPageRoute(const GoalsScreen());
      case AppRoutes.insightsScreen:
        return customPageRoute(const InsightsScreen());
      case AppRoutes.addEditTransactionScreen:
        return customPageRoute(const AddEditTransactionScreen());
      case AppRoutes.onBoardingScreen:
        return customPageRoute(const OnboardingScreen());
      case AppRoutes.profileScreen:
        return customPageRoute(const ProfileScreen());

      default:
        throw Exception('Route not defined: ${settings.name}');
    }
  }

  static Route<dynamic> customPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        final curve = Curves.easeOut;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}
