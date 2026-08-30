import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../transactions/add_transaction_sheet.dart';
import '../../widgets/custom_app_bar.dart';
import '../transactions/cubit/transaction_cubit.dart';
import '../transactions/cubit/transaction_state.dart';
import '../../models/transaction.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Overview'),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TransactionLoaded) {
            final transactions = state.transactions;
            double totalIncome = 0;
            double totalSpent = 0;
            final Map<String, double> categorySpent = {};

            for (var t in transactions) {
              if (t.type == TransactionType.income) {
                totalIncome += t.amount;
              } else {
                final absAmount = t.amount.abs();
                totalSpent += absAmount;
                categorySpent[t.category] = (categorySpent[t.category] ?? 0) + absAmount;
              }
            }

            final double netBalance = totalIncome - totalSpent;
            final recentTransactions = transactions.reversed.take(5).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF004D40),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMMM yyyy').format(DateTime.now()).toUpperCase(),
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Net Balance',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${netBalance.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),


                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Income',
                          '\$${totalIncome.toInt()}',
                          Icons.arrow_upward,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Spent',
                          '\$${totalSpent.toInt()}',
                          Icons.arrow_downward,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Saved',
                          '\$${netBalance.toInt()}',
                          Icons.savings,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),


                  const Text(
                    'Top Categories',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryProgress(
                    'Housing',
                    categorySpent['Housing'] ?? 0,
                    1800.00,
                    Colors.teal,
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryProgress(
                    'Food',
                    categorySpent['Food'] ?? 0,
                    500.00,
                    Colors.green,
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryProgress(
                    'Shopping',
                    categorySpent['Shopping'] ?? 0,
                    200.00,
                    Colors.orange,
                  ),
                  const SizedBox(height: 32),


                  const Text(
                    'Recent Activity',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...recentTransactions.map((t) => Column(
                        children: [
                          _buildActivityItem(
                            t.title,
                            '${DateFormat('MMM dd').format(t.date)} · ${t.category}',
                            '${t.amount >= 0 ? '+' : '-'}\$${t.amount.abs().toStringAsFixed(2)}',
                            t.icon,
                            (t.type == TransactionType.income ? Colors.blue : Colors.teal).withValues(alpha: 0.1),
                            t.type == TransactionType.income ? Colors.blue : Colors.teal,
                            t.type == TransactionType.income,
                          ),
                          const Divider(height: 1),
                        ],
                      )),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddTransactionSheet(),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryProgress(
    String label,
    double spent,
    double total,
    Color color,
  ) {
    final double percentage = (spent / total).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              '\$${spent.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade200,
            color: color,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(percentage * 100).toInt()}% of \$${total.toInt()}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String amount,
    IconData icon,
    Color bgColor,
    Color iconColor,
    bool isIncome,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: bgColor,
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: Text(
        amount,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isIncome ? Colors.green : Colors.black,
        ),
      ),
    );
  }
}
