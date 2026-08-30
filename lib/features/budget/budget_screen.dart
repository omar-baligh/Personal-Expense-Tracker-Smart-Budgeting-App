import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../transactions/add_transaction_sheet.dart';
import '../../widgets/custom_app_bar.dart';

import '../transactions/cubit/transaction_cubit.dart';
import '../transactions/cubit/transaction_state.dart';
import '../../models/transaction.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final Map<String, double> categoryBudgets = {
      'Housing': 1800.0,
      'Food': 500.0,
      'Transport': 200.0,
      'Health': 100.0,
      'Savings': 1000.0,
    };

    return Scaffold(
      appBar: const CustomAppBar(title: 'Budget'),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TransactionLoaded) {
            final transactions = state.transactions;

            final Map<String, double> spentPerCategory = {};
            double totalSpent = 0;

            for (var t in transactions) {
              if (t.type == TransactionType.expense || t.type == TransactionType.saving) {
                final amount = t.amount.abs();
                spentPerCategory[t.category] = (spentPerCategory[t.category] ?? 0) + amount;
                totalSpent += amount;
              }
            }

            double totalBudget = categoryBudgets.values.reduce((a, b) => a + b);
            double totalRemaining = totalBudget - totalSpent;
            double totalPercentage = (totalSpent / totalBudget).clamp(0.0, 1.0);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Monthly Budget',
                          style: TextStyle(
                            color: Colors.teal,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '\$${totalBudget.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF004D40),
                              ),
                            ),
                            Text(
                              '\$${totalRemaining.toInt()} left',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.teal.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: totalPercentage,
                            backgroundColor: Colors.white,
                            color: Colors.teal,
                            minHeight: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${(totalPercentage * 100).toInt()}% used — \$${totalSpent.toInt()} spent',
                          style: const TextStyle(
                            color: Colors.teal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Categories',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),


                  _buildDynamicCategoryCard(
                    title: 'Housing',
                    spent: spentPerCategory['Housing'] ?? 0,
                    total: categoryBudgets['Housing']!,
                    icon: Icons.home,
                    barColor: const Color(0xFF004D40),
                    bgColor: const Color(0xFFE0F7FA),
                    iconBgColor: Colors.teal.shade100,
                  ),
                  const SizedBox(height: 12),


                  _buildDynamicCategoryCard(
                    title: 'Food',
                    spent: spentPerCategory['Food'] ?? 0,
                    total: categoryBudgets['Food']!,
                    icon: Icons.restaurant,
                    barColor: Colors.green.shade900,
                    bgColor: Colors.green.shade50,
                    iconBgColor: Colors.green.shade100,
                  ),
                  const SizedBox(height: 12),


                  _buildDynamicCategoryCard(
                    title: 'Transport',
                    spent: spentPerCategory['Transport'] ?? 0,
                    total: categoryBudgets['Transport']!,
                    icon: Icons.commute,
                    barColor: const Color(0xFF827717),
                    bgColor: const Color(0xFFFFF9C4),
                    iconBgColor: Colors.yellow.shade100,
                  ),
                  const SizedBox(height: 12),


                  _buildDynamicCategoryCard(
                    title: 'Savings',
                    spent: spentPerCategory['Savings'] ?? 0,
                    total: categoryBudgets['Savings']!,
                    icon: Icons.savings,
                    barColor: Colors.pink.shade700,
                    bgColor: Colors.pink.shade50,
                    iconBgColor: Colors.pink.shade100,
                  ),
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

  Widget _buildDynamicCategoryCard({
    required String title,
    required double spent,
    required double total,
    required IconData icon,
    required Color barColor,
    required Color bgColor,
    required Color iconBgColor,
  }) {
    final double remaining = total - spent;
    final double percentage = (spent / total).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: iconBgColor,
                child: Icon(icon, color: barColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '\$${remaining.toStringAsFixed(2)} remaining',
                      style: TextStyle(
                        color: barColor.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${spent.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                ' of \$${total.toInt()}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.white,
              color: barColor,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(percentage * 100).toInt()}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: barColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
