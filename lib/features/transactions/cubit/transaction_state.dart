import 'package:equatable/equatable.dart';
import '../../../models/transaction.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final List<Transaction> filteredTransactions;
  final String searchQuery;
  final String? categoryFilter;
  final TransactionType? typeFilter;

  const TransactionLoaded({
    required this.transactions,
    required this.filteredTransactions,
    this.searchQuery = '',
    this.categoryFilter,
    this.typeFilter,
  });

  @override
  List<Object?> get props => [
        transactions,
        filteredTransactions,
        searchQuery,
        categoryFilter,
        typeFilter,
      ];

  TransactionLoaded copyWith({
    List<Transaction>? transactions,
    List<Transaction>? filteredTransactions,
    String? searchQuery,
    String? categoryFilter,
    TransactionType? typeFilter,
    bool clearCategory = false,
    bool clearType = false,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: clearCategory ? null : (categoryFilter ?? this.categoryFilter),
      typeFilter: clearType ? null : (typeFilter ?? this.typeFilter),
    );
  }
}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
