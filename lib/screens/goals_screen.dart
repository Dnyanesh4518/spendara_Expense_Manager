import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/dashboard/cubit/dashboard_cubit.dart';
import '../features/goals/cubit/goal_cubit.dart';
import '../features/goals/model/goals_model.dart';
import '../features/goals/view/add_edit_goal_screen.dart';
import '../features/goals/view/deposit_sheet.dart';
import '../features/insights/cubit/insights_cubit.dart';
import '../l10n/generated/app_localizations.dart';
import '../routes/transitions.dart';
import '../widgets/widgets.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  Widget build(BuildContext context) {
    AppLocalizations? appLocalizations = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    return BlocConsumer<GoalCubit, GoalState>(
      listener: (context, state) {
        if (state.status == GoalStatus.success) {
          context.read<DashboardCubit>().load();
          context.read<InsightsCubit>().load();
        }
      },
      builder: (context, state) {
        if (state.status == GoalStatus.loading ||
            state.status == GoalStatus.initial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                titleSpacing: 20,
                title: Text(
                  appLocalizations?.goals ?? 'Goals',
                  style: tt.headlineMedium,
                ),
              ),
              if (state.goals.isEmpty)
                SliverFillRemaining(
                  child: GoalsEmptyState(onAdd: () => _openAddGoal(context)),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Overview card ──────────────────
                      OverviewCard(state: state),
                      const SizedBox(height: 24),

                      SectionHeader(
                        title:
                            appLocalizations?.activeGoals ??
                            'Active goals (${state.goals.length})',
                      ),
                      const SizedBox(height: 12),

                      // ── Goal cards ─────────────────────
                      ...state.goals.map(
                        (g) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GoalCard(
                            goal: g,
                            onDeposit: () => DepositSheet.show(context, g),
                            onEdit: () => _openEditGoal(context, g),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openAddGoal(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _openAddGoal(BuildContext context) {
    Navigator.of(context).push(slideUp(const AddEditGoalScreen()));
  }

  void _openEditGoal(BuildContext context, GoalModel goal) {
    Navigator.of(context).push(slideUp(AddEditGoalScreen(existing: goal)));
  }
}
