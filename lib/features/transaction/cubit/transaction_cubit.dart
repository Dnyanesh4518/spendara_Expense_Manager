import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/transaction_repository.dart';
import '../model/transaction_model.dart';

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository _repo;

  TransactionCubit(this._repo) : super(const TransactionState());

  void load() {
    emit(state.copyWith(status: TransactionStatus.loading));
    try {
      final txns = _repo.getAll();
      emit(
        state.copyWith(transactions: txns, status: TransactionStatus.success),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> addTransaction(TransactionModel t) async {
    try {
      await _repo.add(t);
      load();
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> updateTransaction(TransactionModel t) async {
    try {
      await _repo.update(t);
      load();
    } catch (e) {
      emit(state.copyWith(status: TransactionStatus.error));
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _repo.delete(id);
      load();
    } catch (e) {
      emit(state.copyWith(status: TransactionStatus.error));
    }
  }

  Future<void> deleteMultiple(List<String> ids) async {
    try {
      for (final id in ids) {
        await _repo.delete(id);
      }
      load();
    } catch (e) {
      emit(state.copyWith(status: TransactionStatus.error));
    }
  }

  void setFilter(String filter) => emit(state.copyWith(filter: filter));

  void setQuery(String query) => emit(state.copyWith(query: query));
}
