import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../models/day_goals_model.dart';
import '../widgets/add_day_goal_sheet.dart';
import '../widgets/timeline_row.dart';

class DayGoalsScreen extends StatelessWidget {
  final DateTime date;
  final String? lifeBlock;
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

class _DayGoalsView extends StatefulWidget {
  const _DayGoalsView();

  @override
  State<_DayGoalsView> createState() => _DayGoalsViewState();
}

class _DayGoalsViewState extends State<_DayGoalsView> {
  final _scroll = ScrollController();

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
        startTime: res.startTime, // ⬅️ прокинули время начала
      );

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 60));
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    }
  }

  // Сортируем только по времени начала (возрастание)
  List<Goal> _sortedByStartTime(List<Goal> src) {
    final list = List<Goal>.from(src);
    list.sort((a, b) => a.startTime.compareTo(b.startTime));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DayGoalsModel>();
    final goals = _sortedByStartTime(vm.goals); // ⬅️ сортировка по времени
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(context),
        label: const Text('Добавить цель'),
        icon: const Icon(Icons.add),
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : goals.isEmpty
              ? const Center(child: Text('Целей на этот день нет'))
              : ListView.builder(
                  controller: _scroll,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  itemCount: goals.length,
                  itemBuilder: (_, i) {
                    final g = goals[i];
                    return TimelineRow(
                      key: ValueKey(g.id),
                      goal: g,
                      index: i,
                      total: goals.length,
                      onToggle: () => vm.toggleComplete(g),
                      onDelete: () => vm.deleteGoal(g),
                      onEdit: () async {
                        final res = await showModalBottomSheet<AddGoalResult>(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (ctx) => AddDayGoalSheet(
                            fixedLifeBlock: vm.lifeBlock,
                            availableBlocks: vm.availableBlocks,
                            // если добавишь поддержку initial* в шите — сюда их передадим
                            // initialTitle: g.title,
                            // initialDescription: g.description,
                            // initialLifeBlock: g.lifeBlock,
                            // initialImportance: g.importance,
                            // initialEmotion: g.emotion,
                            // initialHours: g.spentHours,
                            // initialStartTime: TimeOfDay(hour: g.startTime.hour, minute: g.startTime.minute),
                          ),
                        );

                        if (res != null) {
                          await vm.updateGoal(
                            id: g.id,
                            title: res.title,
                            description: res.description,
                            lifeBlockValue: res.lifeBlock,
                            importance: res.importance,
                            emotion: res.emotion,
                            hours: res.hours,
                            startTime: res.startTime, // ⬅️ прокинули время в апдейт
                          );
                        }
                      },
                    );
                  },
                ),
    );
  }
}
