import 'package:flutter/material.dart';
import '../services/goal_service.dart';
import '../widgets/goal_card.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final GoalService _goalService = GoalService();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));

  void _addGoal() {
  if (_titleController.text.isEmpty || _descController.text.isEmpty) return;

  final goal = Goal(
    id: const Uuid().v4(),
    title: _titleController.text,
    description: _descController.text,
    deadline: _selectedDate,
  );

  _goalService.addGoal(goal);

  _titleController.clear();
  _descController.clear();
  setState(() {});
}

  @override
  Widget build(BuildContext context) {
    final goals = _goalService.goals;

    return Scaffold(
      appBar: AppBar(title: const Text('My Goals')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Goal Title'),
                ),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                ElevatedButton(
                  onPressed: _addGoal,
                  child: const Text('Add Goal'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: goals.length,
              itemBuilder: (ctx, index) {
                final goal = goals[index];
                return GoalCard(
                  goal: goal,
                  onToggle: () {
                    _goalService.toggleGoal(goal.id);
                    setState(() {});
                  },
                  onDelete: () {
                    _goalService.deleteGoal(goal.id);
                    setState(() {});
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
