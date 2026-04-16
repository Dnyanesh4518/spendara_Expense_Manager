import 'package:Spendara/core/analytics/analytics_keys.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

import '../../features/dashboard/cubit/dashboard_cubit.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../widgets/remove_ad_button.dart';
import '../../widgets/widgets.dart';
import 'financial_health_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  // ── Open Add Transaction pre-filled by type ──────────────────
  void _openAddTransaction(BuildContext context, String type) {
    Navigator.pushNamed(
      context,
      AppRoutes.addEditTransactionScreen,
      arguments: [type, true],
    );
    FirebaseAnalytics.instance.logEvent(
      name: type == 'income'
          ? AnalyticsKeys.addIncomeTapped
          : AnalyticsKeys.addExpenseTapped,
    );
  }

  // ── Balance card tap → financial health sheet ────────────────
  void _showFinancialHealthSheet(
    BuildContext context,
    DashboardState state,
    AppLocalizations? l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => FinancialHealthSheet(state: state, l10n: l10n),
    );

    FirebaseAnalytics.instance.logEvent(name: AnalyticsKeys.balanceCardTapped);
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    return BlocConsumer<DashboardCubit, DashboardState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state.status == DashboardStatus.loading ||
            state.status == DashboardStatus.initial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return SafeArea(
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  titleSpacing: 20,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${appLocalizations?.hello ?? 'Hello'} ${state.userName}',
                        style: tt.headlineSmall?.copyWith(fontSize: 14),
                      ),
                      Text(
                        appLocalizations?.yourFinances ?? 'Your finances',
                        style: tt.headlineMedium,
                      ),
                    ],
                  ),
                  actions: [
                    RemoveAdsButton(),
                    SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, 'profileScreen');
                          FirebaseAnalytics.instance.logEvent(
                            name: AnalyticsKeys.profileClicked,
                          );
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.25,
                          ),
                          child: Text(
                            state.userName.substring(0, 1).toUpperCase(),
                            style: tt.labelLarge,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      GestureDetector(
                        onTap: () => _showFinancialHealthSheet(
                          context,
                          state,
                          appLocalizations,
                        ),
                        child: BalanceCard(
                          balance: state.balance.toString(),
                          savingsProgress: state.savingsProgress,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        spacing: 4,
                        children: [
                          Expanded(
                            child: SummaryCard(
                              label:
                                  appLocalizations?.totalIncome ??
                                  'Total income',
                              amount: context.formatter.format(
                                state.totalIncome,
                              ),
                              icon: Icons.arrow_downward_rounded,
                              color: AppColors.income,
                              bgColor: AppColors.incomeLight,
                              onTap: () =>
                                  _openAddTransaction(context, 'income'),
                            ),
                          ),
                          Expanded(
                            child: SummaryCard(
                              label:
                                  appLocalizations?.totalExpenses ??
                                  'Total expenses',
                              amount: context.formatter.format(
                                state.totalExpenses,
                              ),
                              icon: Icons.arrow_upward_rounded,
                              color: AppColors.expense,
                              bgColor: AppColors.expenseLight,
                              onTap: () =>
                                  _openAddTransaction(context, 'expense'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SectionHeader(
                        title:
                            appLocalizations?.weeklySpending ??
                            'Weekly spending',
                      ),
                      const SizedBox(height: 12),
                      state.weeklySpending.isEmpty
                          ? SizedBox(
                              height: 180,
                              child: Center(
                                child: Text(
                                  appLocalizations?.noDataYet ?? 'No data yet',
                                ),
                              ),
                            )
                          : WeeklyChart(
                              data: state.weeklySpending
                                  .asMap()
                                  .entries
                                  .map(
                                    (e) => SpendData(
                                      state.weekDayLabels[e.key],
                                      e.value,
                                    ),
                                  )
                                  .toList(),
                            ),
                      const SizedBox(height: 24),
                      SectionHeader(
                        title:
                            appLocalizations?.recentTransactions ??
                            'Recent transactions',
                        actionLabel: state.recentTransactions.isEmpty
                            ? null
                            : appLocalizations?.seeAll ?? 'See all',
                        onAction: () {
                          Navigator.of(context).pushNamed('transactions');
                          FirebaseAnalytics.instance.logEvent(
                            name: AnalyticsKeys.seeAll,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      state.recentTransactions.isEmpty
                          ? const SizedBox.shrink()
                          : RecentTransactions(txns: state.recentTransactions),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
