import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency_formatter.dart';

import '../features/dashboard/cubit/dashboard_cubit.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/remove_ad_button.dart';
import '../widgets/widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
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
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      BalanceCard(
                        balance: state.balance.toString(),
                        savingsProgress: state.savingsProgress,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        spacing: 12,
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
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
                        actionLabel: appLocalizations?.seeAll ?? 'See all',
                        onAction: () {
                          Navigator.of(context).pushNamed('transactions');
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
