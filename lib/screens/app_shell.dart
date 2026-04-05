import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/dashboard/cubit/dashboard_cubit.dart';
import '../features/insights/cubit/insights_cubit.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/banner_ad_widget.dart';
import 'screens.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _onSelectedIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      context.read<DashboardCubit>().load();
    }
    if (index == 3) {
      context.read<InsightsCubit>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const DashboardScreen(),
          const TransactionsScreen(),
          const GoalsScreen(),
          const InsightsScreen(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdWidget(),
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onSelectedIndex,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: appLocalizations?.dashboard ?? 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: appLocalizations?.transactions ?? 'Transactions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.flag_outlined),
                activeIcon: Icon(Icons.flag),
                label: appLocalizations?.goals ?? 'Goals',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.insights_outlined),
                activeIcon: Icon(Icons.insights),
                label: appLocalizations?.insights ?? 'Insights',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
