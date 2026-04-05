import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/insights/cubit/insights_cubit.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/widgets.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  Widget build(BuildContext context) {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);

    return BlocConsumer<InsightsCubit, InsightsState>(
      listener: (context, state) {},
      builder: (context, state) {
        final tt = Theme.of(context).textTheme;

        if (state.status == InsightsStatus.initial ||
            state.status == InsightsStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ── Empty state — no transactions yet ─────────────────
        if (state.totalTransactions == 0) {
          return Scaffold(body: InsightsEmptyState());
        }
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                titleSpacing: 20,
                title: Text(
                  appLocalizations?.insights ?? 'Insights',
                  style: tt.headlineMedium,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    StatCardsRow(state: state),
                    const SizedBox(height: 24),

                    if (state.expensesByCategory.isNotEmpty) ...[
                      SectionHeader(
                        title:
                            appLocalizations?.spendingByCategory ??
                            'Spending by category',
                      ),
                      const SizedBox(height: 12),
                      CategoryDonut(state: state),
                      const SizedBox(height: 24),
                    ],

                    // ── Week-over-week grouped bar ─────────────────
                    SectionHeader(
                      title:
                          appLocalizations?.thisWeekVsLastWeek ??
                          'This week vs last week',
                    ),
                    const SizedBox(height: 12),
                    WeekCompareChart(state: state),
                    const SizedBox(height: 24),

                    MonthCompareCard(state: state),
                    const SizedBox(height: 24),

                    if (state.expensesByCategory.isNotEmpty) ...[
                      SectionHeader(
                        title:
                            appLocalizations?.categoryBreakdown ??
                            'Category breakdown',
                      ),
                      const SizedBox(height: 12),
                      CategoryBreakdownList(state: state),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
