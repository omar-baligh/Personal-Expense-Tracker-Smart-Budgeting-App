import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/transaction.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _transactionSubscription;
  StreamSubscription? _userSubscription;

  TransactionCubit() : super(TransactionInitial()) {
    _userSubscription = _auth.userChanges().listen((user) {
      if (user != null) {
        _initTransactions(user.uid);
      } else {
        _transactionSubscription?.cancel();
        emit(TransactionInitial());
      }
    });
  }

  void _initTransactions(String uid) {
    _transactionSubscription?.cancel();
    _transactionSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      final transactions = snapshot.docs
          .map((doc) => Transaction.fromMap(doc.data(), doc.id))
          .toList();
      
      String query = '';
      String? category;
      TransactionType? type;
      
      if (state is TransactionLoaded) {
        final currentState = state as TransactionLoaded;
        query = currentState.searchQuery;
        category = currentState.categoryFilter;
        type = currentState.typeFilter;
      }

      _applyFilters(transactions, query, category, type);
    });
  }

  Future<void> addTransaction(Transaction transaction) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .add(transaction.toMap());
      } catch (e) {
        emit(TransactionError('Failed to add transaction: $e'));
      }
    }
  }

  Future<void> deleteTransaction(String id) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .doc(id)
            .delete();
      } catch (e) {
        emit(TransactionError('Failed to delete transaction: $e'));
      }
    }
  }

  void search(String query) {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      _applyFilters(currentState.transactions, query, currentState.categoryFilter, currentState.typeFilter);
    }
  }

  void filterByCategory(String? category) {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      _applyFilters(currentState.transactions, currentState.searchQuery, category, currentState.typeFilter);
    }
  }

  void filterByType(TransactionType? type) {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      _applyFilters(currentState.transactions, currentState.searchQuery, currentState.categoryFilter, type);
    }
  }

  void _applyFilters(List<Transaction> transactions, String query, String? category, TransactionType? type) {
    List<Transaction> filtered = transactions;

    if (query.isNotEmpty) {
      filtered = filtered.where((t) => t.title.toLowerCase().contains(query.toLowerCase())).toList();
    }

    if (category != null && category.isNotEmpty) {
      filtered = filtered.where((t) => t.category == category).toList();
    }

    if (type != null) {
      filtered = filtered.where((t) => t.type == type).toList();
    }

    emit(TransactionLoaded(
      transactions: transactions,
      filteredTransactions: filtered,
      searchQuery: query,
      categoryFilter: category,
      typeFilter: type,
    ));
  }

  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    _userSubscription?.cancel();
    return super.close();
  }
}
