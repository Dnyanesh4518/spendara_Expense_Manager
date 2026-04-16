import 'package:Spendara/core/analytics/analytics_keys.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/insights/cubit/insights_cubit.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/widgets.dart';
import '../core/theme/app_colors.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  // ── Custom date range picker ───────────────────────────────────
  Future<void> _pickCustomRange(InsightsCubit cubit) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          primaryColor: AppColors.textPrimary,
          inputDecorationTheme: InputDecorationTheme(
            floatingLabelStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.primary, // ← purple when focused/floating
              fontWeight: FontWeight.w500,
            ),
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: Theme.of(ctx).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (range != null && mounted) {
      cubit.load(
        timeRange: TimeRange.custom,
        customStart: range.start,
        customEnd: range.end,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context);

    return BlocConsumer<InsightsCubit, InsightsState>(
      listener: (context, state) {},
      builder: (context, state) {
        final tt = Theme.of(context).textTheme;
        final cubit = context.read<InsightsCubit>();

        if (state.status == InsightsStatus.initial ||
            state.status == InsightsStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.totalTransactions == 0) {
          return Scaffold(body: InsightsEmptyState());
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // ── App bar with sticky filter bar ────────────────
              SliverAppBar(
                floating: true,
                snap: true,
                titleSpacing: 20,
                title: Text(
                  appLocalization?.insights ?? 'Insights',
                  style: tt.headlineMedium,
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(104),
                  child: _FilterBar(
                    state: state,
                    onTimeRangeTap: (range) {
                      if (range == TimeRange.custom) {
                        _pickCustomRange(cubit);
                      } else {
                        cubit.load(timeRange: range);
                      }
                    },
                    onViewModeTap: cubit.changeViewMode,
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Content switches on viewMode ──────────────
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.04),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: KeyedSubtree(
                        key: ValueKey(state.viewMode),
                        child: _buildViewContent(
                          context,
                          state,
                          cubit,
                          appLocalization,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildViewContent(
    BuildContext context,
    InsightsState state,
    InsightsCubit cubit,
    AppLocalizations? l10n,
  ) {
    switch (state.viewMode) {
      case ViewMode.overview:
        return _OverviewContent(state: state, l10n: l10n);
      case ViewMode.category:
        return _CategoryContent(
          state: state,
          l10n: l10n,
          onCategoryTap: (value) {
            FirebaseAnalytics.instance.logEvent(
              name: "${AnalyticsKeys.catSelected}_$value",
            );
            cubit.selectCategory(value);
          },
        );
      case ViewMode.trends:
        return _TrendsContent(state: state);
      case ViewMode.forecast:
        return _ForecastContent(state: state);
    }
  }
}

// ──────────────────────────────────────────────────────────────────
// FILTER BAR
// ──────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final InsightsState state;
  final ValueChanged<TimeRange> onTimeRangeTap;
  final ValueChanged<ViewMode> onViewModeTap;

  const _FilterBar({
    required this.state,
    required this.onTimeRangeTap,
    required this.onViewModeTap,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Time range ──────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TimeRange.values.map((range) {
                final selected = state.timeRange == range;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: _rangeLabel(range, state, appLocalizations),
                    selected: selected,
                    onTap: () => onTimeRangeTap(range),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // ── Row 2: View mode ───────────────────────────────────
          Row(
            children: ViewMode.values.map((mode) {
              final selected = state.viewMode == mode;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _ViewModeChip(
                    label: _modeLabel(mode, appLocalizations),
                    icon: _modeIcon(mode),
                    selected: selected,
                    onTap: () => onViewModeTap(mode),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _rangeLabel(
    TimeRange r,
    InsightsState s,
    AppLocalizations? appLocalization,
  ) {
    if (r == TimeRange.custom &&
        s.timeRange == TimeRange.custom &&
        s.customStart != null &&
        s.customEnd != null) {
      final fmt =
          '${s.customStart!.day}/${s.customStart!.month}'
          ' – ${s.customEnd!.day}/${s.customEnd!.month}';
      return fmt;
    }
    return switch (r) {
      TimeRange.week => appLocalization?.week ?? 'week',
      TimeRange.month => appLocalization?.month ?? 'Month',
      TimeRange.year => appLocalization?.year ?? 'Year',
      TimeRange.custom => appLocalization?.custom ?? 'custom',
    };
  }

  String _modeLabel(ViewMode m, AppLocalizations? appLocalization) =>
      switch (m) {
        ViewMode.overview => appLocalization?.overview ?? 'Overview',
        ViewMode.category => appLocalization?.category ?? 'Category',
        ViewMode.trends => appLocalization?.trends ?? 'Trends',
        ViewMode.forecast => appLocalization?.forecast ?? 'Forecast',
      };

  IconData _modeIcon(ViewMode m) => switch (m) {
    ViewMode.overview => Icons.grid_view_rounded,
    ViewMode.category => Icons.donut_small_outlined,
    ViewMode.trends => Icons.trending_up_rounded,
    ViewMode.forecast => Icons.auto_graph_rounded,
  };
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? tt.primaryColor : tt.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : tt.colorScheme.outline.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: tt.textTheme.labelSmall?.copyWith(
            color: selected
                ? Colors.white
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.9),
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _ViewModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ViewModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : tt.cardTheme.color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.5)
                : tt.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected
                  ? AppColors.primary
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? AppColors.primary
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// OVERVIEW VIEW
// Shows existing widgets + period-aware comparison chart
// ──────────────────────────────────────────────────────────────────

class _OverviewContent extends StatelessWidget {
  final InsightsState state;
  final AppLocalizations? l10n;

  const _OverviewContent({required this.state, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Period summary cards
        StatCardsRow(state: state),
        const SizedBox(height: 24),

        // Comparison chart adapts to selected time range
        SectionHeader(
          title: state.timeRange == TimeRange.year
              ? l10n?.thisYearVsLastYear ?? 'This year vs last year'
              : l10n?.thisWeekVsLastWeek ?? 'This week vs last week',
        ),
        const SizedBox(height: 12),
        if (state.timeRange == TimeRange.year)
          YearlyCompareChart(state: state)
        else
          WeekCompareChart(state: state),
        const SizedBox(height: 24),
        state.timeRange == TimeRange.year
            ? YearCompareCard(state: state)
            : MonthCompareCard(state: state),
        const SizedBox(height: 24),

        if (state.expensesByCategory.isNotEmpty) ...[
          SectionHeader(title: l10n?.categoryBreakdown ?? 'Category breakdown'),
          const SizedBox(height: 12),
          CategoryBreakdownList(state: state),
        ],
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// CATEGORY VIEW
// Donut + alert badges + history chart + drill-down
// ──────────────────────────────────────────────────────────────────

class _CategoryContent extends StatelessWidget {
  final InsightsState state;
  final AppLocalizations? l10n;
  final ValueChanged<String?> onCategoryTap;

  const _CategoryContent({
    required this.state,
    required this.l10n,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Donut chart (existing widget) ──────────────────────
        if (state.expensesByCategory.isNotEmpty) ...[
          SectionHeader(
            title: l10n?.spendingByCategory ?? 'Spending by category',
          ),
          const SizedBox(height: 12),
          CategoryDonut(state: state),
          const SizedBox(height: 20),
        ],

        // ── Alert badges for >20% spike categories ─────────────
        if (state.alertCategories.isNotEmpty) ...[
          SectionHeader(title: l10n?.spendingAlerts ?? 'Spending alerts'),
          const SizedBox(height: 10),
          ...state.alertCategories.map((cat) {
            final curAmt = state.expensesByCategory[cat] ?? 0;
            final prevAmt = state.prevPeriodExpenses;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CategoryAlertBadge(
                category: cat,
                currentAmount: curAmt,
                pctIncrease: state.alertCategories.contains(cat)
                    ? ((curAmt - (prevAmt * 0.5)) / (prevAmt * 0.5) * 100)
                          .clamp(20, 999)
                    : 0,
              ),
            );
          }),
          const SizedBox(height: 16),
        ],

        // ── Top 5 category history (6 periods bar chart) ───────
        // if (state.top5CategoryHistory.isNotEmpty) ...[
        //   SectionHeader(
        //     title:
        //         '${l10n!.topCategoriesLast} ${_periodWord(state.timeRange, l10n)}',
        //   ),
        //   const SizedBox(height: 12),
        //   CategoryHistoryChart(state: state),
        //   const SizedBox(height: 20),
        // ],

        // ── Drill-down (tap category in the list below) ────────
        SectionHeader(title: l10n!.tapACategoryToExplore),
        const SizedBox(height: 12),
        DrillDownCategoryList(state: state, onCategoryTap: onCategoryTap),
      ],
    );
  }

  // String _periodWord(TimeRange r, AppLocalizations? appLocalization) =>
  //     switch (r) {
  //       TimeRange.week => appLocalization?.week ?? 'week',
  //       TimeRange.month => appLocalization?.month ?? 'Month',
  //       TimeRange.year => appLocalization?.year ?? 'Year',
  //       TimeRange.custom => appLocalization?.custom ?? 'custom',
  //     };
}

// ──────────────────────────────────────────────────────────────────
// TRENDS VIEW
// Velocity + heatmap + anomaly alerts + biggest spike
// ──────────────────────────────────────────────────────────────────

class _TrendsContent extends StatelessWidget {
  final InsightsState state;

  const _TrendsContent({required this.state});

  @override
  Widget build(BuildContext context) {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Spending velocity (month view only) ────────────────
        if (state.timeRange == TimeRange.month &&
            state.spendingVelocity > 0) ...[
          SectionHeader(title: appLocalizations!.spendingVelocity),
          const SizedBox(height: 12),
          SpendingVelocityCard(state: state),
          const SizedBox(height: 24),
        ],

        // ── Day-of-week heatmap ────────────────────────────────
        if (state.dayOfWeekTotals.isNotEmpty) ...[
          SectionHeader(title: appLocalizations!.spendingByDayOfWeek),
          const SizedBox(height: 12),
          DayHeatmapWidget(totals: state.dayOfWeekTotals),
          const SizedBox(height: 24),
        ],

        // ── Anomaly alerts ─────────────────────────────────────
        if (state.anomalies.isNotEmpty) ...[
          SectionHeader(title: appLocalizations!.anomalyAlerts),
          const SizedBox(height: 12),
          ...state.anomalies.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AnomalyAlertCard(item: a),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Biggest single-day spike ───────────────────────────
        if (state.biggestSpikeDay != '—' && state.biggestSpikeAmount > 0) ...[
          SectionHeader(title: appLocalizations!.biggestSpendDay),
          const SizedBox(height: 12),
          BiggestSpikeDayCard(state: state),
        ],
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// FORECAST VIEW
// Savings rate trend + projected monthly spend
// ──────────────────────────────────────────────────────────────────

class _ForecastContent extends StatelessWidget {
  final InsightsState state;

  const _ForecastContent({required this.state});

  @override
  Widget build(BuildContext context) {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Projected month spend ──────────────────────────────
        if (state.spendingVelocity > 0) ...[
          SectionHeader(title: appLocalizations!.monthProjection),
          const SizedBox(height: 12),
          SpendingVelocityCard(state: state),
          const SizedBox(height: 24),
        ],

        // ── 12-month savings rate trend ────────────────────────
        SectionHeader(title: appLocalizations!.savingsRateLast12Months),
        const SizedBox(height: 12),
        SavingsRateTrendChart(state: state),
        const SizedBox(height: 24),

        // ── This year monthly vs last year ────────────────────
        SectionHeader(title: appLocalizations.yearOverYearMonthlySpend),
        const SizedBox(height: 12),
        YearlyCompareChart(state: state),
      ],
    );
  }
}
