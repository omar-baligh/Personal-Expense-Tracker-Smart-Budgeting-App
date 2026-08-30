import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_transaction_sheet.dart';
import '../../models/transaction.dart';
import '../../widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';

import 'cubit/transaction_cubit.dart';
import 'cubit/transaction_state.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddTransactionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Transactions'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            BlocBuilder<TransactionCubit, TransactionState>(
              builder: (context, state) {
                String currentQuery = '';
                if (state is TransactionLoaded) {
                  currentQuery = state.searchQuery;
                }
                return TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    context.read<TransactionCubit>().search(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: currentQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<TransactionCubit>().search('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<TransactionCubit, TransactionState>(
              builder: (context, state) {
                final currentFilter = (state is TransactionLoaded) ? state.typeFilter : null;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [null, TransactionType.income, TransactionType.expense, TransactionType.saving].map((type) {
                      final label = type == null ? 'All' : type.name[0].toUpperCase() + type.name.substring(1);
                      final isSelected = currentFilter == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (selected) {
                            context.read<TransactionCubit>().filterByType(selected ? type : null);
                          },
                          selectedColor: Colors.teal,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<TransactionCubit, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is TransactionLoaded) {
                    final filteredTransactions = state.filteredTransactions;

                    if (filteredTransactions.isEmpty) {
                      return const Center(child: Text('No transactions found'));
                    }


                    final grouped = <String, List<Transaction>>{};
                    for (var t in filteredTransactions) {
                      final dateStr = DateFormat('MMM dd').format(t.date).toUpperCase();
                      if (!grouped.containsKey(dateStr)) {
                        grouped[dateStr] = [];
                      }
                      grouped[dateStr]!.add(t);
                    }

                    final keys = grouped.keys.toList();

                    final flattened = <dynamic>[];
                    for (var key in keys) {
                      flattened.add(key);
                      flattened.addAll(grouped[key]!);
                    }

                    return ListView.builder(
                      itemCount: flattened.length,
                      itemBuilder: (context, index) {
                        final item = flattened[index];
                        if (item is String) {
                          return _buildDateGroup(item);
                        } else {
                          final t = item as Transaction;
                          return _buildTransactionItem(
                            id: t.id,
                            icon: t.icon,
                            title: t.title,
                            amount: '${t.amount >= 0 ? '+' : ''} \$${t.amount.abs().toStringAsFixed(2)}',
                            amountColor: t.type == TransactionType.income ? Colors.green : Colors.red,
                          );
                        }
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionSheet,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDateGroup(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        date,
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required String id,
    required IconData icon,
    required String title,
    required String amount,
    required Color amountColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Transaction description', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => context.read<TransactionCubit>().deleteTransaction(id),
                icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
