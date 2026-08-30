import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/goal.dart';
import 'cubit/goal_cubit.dart';

class AddGoalSheet extends StatefulWidget {
  const AddGoalSheet({super.key});

  @override
  State<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<AddGoalSheet> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _deadlineController = TextEditingController(text: '06/01/2027');
  Color _selectedColor = Colors.teal.shade200;

  final List<Color> _colors = [
    Colors.teal.shade200,
    Colors.blue.shade100,
    Colors.yellow.shade200,
    Colors.red.shade100,
    Colors.green.shade100,
    Colors.pink.shade100,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  void _onCreateGoal() {
    final name = _nameController.text;
    final target = double.tryParse(_targetController.text) ?? 0.0;

    if (name.isEmpty || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid goal details')),
      );
      return;
    }

    final newGoal = Goal(
      id: DateTime.now().toString(),
      title: name,
      dueDate: 'Jun 1', // Simplified for demo
      currentAmount: 0,
      targetAmount: target,
      backgroundColor: _selectedColor.withValues(alpha: 0.3),
      progressColor: _selectedColor.withValues(alpha: 0.8),
      buttonColor: Colors.teal.shade800,
    );

    context.read<GoalCubit>().addGoal(newGoal);
    Navigator.pop(context);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'New Goal',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ActionChip(
                label: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
                backgroundColor: Colors.teal.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildField(label: 'Goal name', hint: 'e.g. Vacation fund', controller: _nameController),
                const SizedBox(height: 16),
                _buildField(label: 'Target amount', hint: '0', controller: _targetController, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildField(label: 'Deadline', hint: '06/01/2027', controller: _deadlineController, suffixIcon: Icons.calendar_today),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _colors.map((color) {
                          final isSelected = _selectedColor == color;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = color),
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: color,
                              child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.black54) : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onCreateGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00695C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Create Goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({required String label, required String hint, required TextEditingController controller, IconData? suffixIcon, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 20) : null,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }
}
