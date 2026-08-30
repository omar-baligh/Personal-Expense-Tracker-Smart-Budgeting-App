import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/transaction.dart';
import 'cubit/transaction_cubit.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  String _transactionType = 'Expense';
  String _selectedCategory = 'Food';
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onAddTransaction() {
    final description = _descriptionController.text;
    final amountText = _amountController.text;

    if (description.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final amount = double.tryParse(amountText) ?? 0.0;
    final type = _transactionType == 'Income'
        ? TransactionType.income
        : _transactionType == 'Savings'
            ? TransactionType.saving
            : TransactionType.expense;

    final newTransaction = Transaction(
      id: DateTime.now().toString(),
      title: description,
      amount: type == TransactionType.income ? amount : -amount,
      date: DateTime.now(),
      category: _selectedCategory,
      type: type,
      icon: _getIconForCategory(_selectedCategory),
    );

    context.read<TransactionCubit>().addTransaction(newTransaction);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction added successfully!'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Housing':
        return Icons.home_outlined;
      case 'Salary':
        return Icons.work_outline;
      case 'Savings':
        return Icons.savings_outlined;
      case 'Transport':
        return Icons.commute;
      case 'Health':
        return Icons.medical_services_outlined;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Transaction',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: ['Expense', 'Income', 'Savings'].map((type) {
              final isSelected = _transactionType == type;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    onPressed: () => setState(() {
                      _transactionType = type;
                      if (type == 'Income') {
                        _selectedCategory = 'Salary';
                      } else if (type == 'Savings') {
                        _selectedCategory = 'Savings';
                      } else if (_selectedCategory == 'Salary' ||
                          _selectedCategory == 'Savings') {
                        _selectedCategory = 'Food';
                      }
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected ? Colors.teal : Colors.grey[100],
                      foregroundColor: isSelected ? Colors.white : Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(type),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _buildField(
            label: 'Description',
            hint: 'e.g. Coffee at Blue Bottle',
            controller: _descriptionController,
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Amount (USD)',
            hint: '0.00',
            controller: _amountController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: ValueKey(_selectedCategory),
            initialValue: _selectedCategory,
            items: [
              'Food',
              'Housing',
              'Transport',
              'Health',
              'Shopping',
              'Salary',
              'Savings'
            ].map((cat) {
              return DropdownMenuItem(value: cat, child: Text(cat));
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedCategory = val;
                  if (val == 'Salary') _transactionType = 'Income';
                  if (val == 'Savings') _transactionType = 'Saving';
                });
              }
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Date',
            hint: '08/22/2026',
            suffixIcon: Icons.calendar_today,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.teal)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _onAddTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add Transaction'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    IconData? suffixIcon,
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 20) : null,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
