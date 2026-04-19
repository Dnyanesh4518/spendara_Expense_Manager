import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/budget_repository.dart';
import '../model/budget_model.dart';

part 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final BudgetRepository _repo;

  BudgetCubit(this._repo) : super(const BudgetInitial());

  void load({int? month, int? year}) {
    emit(const BudgetLoading());
    try {
      final now = DateTime.now();
      final m = month ?? now.month;
      final y = year ?? now.year;
      final budget = _repo.getForMonth(m, y);
      emit(BudgetLoaded(current: budget, month: m, year: y));
    } catch (_) {
      emit(const BudgetInitial());
    }
  }

  Future<void> saveBudget(BudgetModel b) async {
    await _repo.save(b);
    load(month: b.month, year: b.year);
  }

  Future<void> deleteBudget(String id) async {
    final budget = _repo.getAll().firstWhere((b) => b.id == id);
    await _repo.delete(id);
    load(month: budget.month, year: budget.year);
  }
}
