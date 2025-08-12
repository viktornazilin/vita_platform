import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goal.dart';
import '../models/day_goals_model.dart';
import '../widgets/goal_path.dart';
import '../widgets/add_day_goal_sheet.dart';

class DayGoalsScreen extends StatelessWidget {
  final DateTime date;
  final String? lifeBlock; // null => показать все блоки
  final List<String> availableBlocks;

  const DayGoalsScreen({
    super.key,
    required this.date,
    required this.lifeBlock,
    this.availableBlocks = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DayGoalsModel(
        date: date,
        lifeBlock: lifeBlock,
        availableBlocks: availableBlocks,
      )..load(),
      child: const _DayGoalsView(),
    );
  }
}

class _DayGoalsView extends StatelessWidget {
  const _DayGoalsView();

  Future<void> _openAdd(BuildContext context) async {
    final vm = context.read<DayGoalsModel>();
    final res = await showModalBottomSheet<AddGoalResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => AddDayGoalSheet(
        fixedLifeBlock: vm.lifeBlock,
        availableBlocks: vm.availableBlocks,
      ),
    );

    if (res != null) {
      await vm.createGoal(
        title: res.title,
        description: res.description,
        lifeBlockValue: res.lifeBlock,
        importance: res.importance,
        emotion: res.emotion,
        hours: res.hours,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DayGoalsModel>();
    final title = vm.lifeBlock ?? 'Все сферы';

    return Scaffold(
      appBar: AppBar(
        title: Text('${vm.formattedDate}  •  $title'),
        actions: [
          IconButton(
            onPressed: () => _openAdd(context),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.goals.isEmpty
              ? const Center(child: Text('Целей на этот день нет'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: GoalPath(
                    goals: vm.goals,
                    onToggle: vm.toggleComplete,
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(context),
        label: const Text('Добавить цель'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
