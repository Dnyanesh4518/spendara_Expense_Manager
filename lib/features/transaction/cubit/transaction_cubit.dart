import 'package:Spendara/core/crashlytics/crashlytics_keys.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
      FirebaseCrashlytics.instance.log(CrashlyticsKeys.transactionCubitLoad);
      rethrow;
    }
  }

  Future<void> addTransaction(TransactionModel t) async {
    try {
      _repo.add(t);
      load();
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionStatus.error,
          errorMessage: e.toString(),
        ),
      );
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionModel t) async {
    try {
      _repo.update(t);
      load();
    } catch (e) {
      emit(state.copyWith(status: TransactionStatus.error));
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      _repo.delete(id);
      load();
    } catch (e) {
      emit(state.copyWith(status: TransactionStatus.error));
      rethrow;
    }
  }

  Future<void> deleteMultiple(List<String> ids) async {
    try {
      for (final id in ids) {
        _repo.delete(id);
      }
      load();
    } catch (e) {
      emit(state.copyWith(status: TransactionStatus.error));
    }
  }

  void setFilter(String filter) => emit(state.copyWith(filter: filter));

  void setQuery(String query) => emit(state.copyWith(query: query));
}
