part of 'transaction_cubit.dart';

enum TransactionStatus { initial, loading, success, error }

class TransactionState extends Equatable {
  final List<TransactionModel> transactions;
  final String filter; // 'All' | 'Income' | 'Expense'
  final String query;
  final TransactionStatus status;
  final String? errorMessage;

  const TransactionState({
    this.transactions = const [],
    this.filter = 'All',
    this.query = '',
    this.status = TransactionStatus.initial,
    this.errorMessage,
  });

  List<TransactionModel> get filtered => transactions.where((t) {
    final matchFilter =
        filter == 'All' ||
        (filter == 'Income' && !t.isExpense) ||
        (filter == 'Expense' && t.isExpense);
    final q = query.toLowerCase();
    final matchQuery =
        q.isEmpty ||
        t.category.toLowerCase().contains(q) ||
        t.notes.toLowerCase().contains(q);
    return matchFilter && matchQuery;
  }).toList();

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    String? filter,
    String? query,
    TransactionStatus? status,
    String? errorMessage,
  }) => TransactionState(
    transactions: transactions ?? this.transactions,
    filter: filter ?? this.filter,
    query: query ?? this.query,
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    transactions,
    filter,
    query,
    status,
    errorMessage,
  ];
}
