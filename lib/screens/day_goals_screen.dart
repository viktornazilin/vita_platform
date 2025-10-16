import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goal.dart';
import '../models/day_goals_model.dart';
import '../widgets/add_day_goal_sheet.dart';
import '../widgets/timeline_row.dart';
import '../widgets/edit_goal_sheet.dart';
import '../widgets/import_journal.dart';

/// Лучше читать из --dart-define: --dart-define=VISION_API_KEY=...
const String _kVisionApiKey = String.fromEnvironment('AIzaSyBBEjM1LYnJw1_SmsAJbZIl-y08xjF5X-s', defaultValue: '');

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

enum _FabAction { manual, scan }

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
        startTime: res.startTime,
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

  List<Goal> _sortedByStartTime(List<Goal> src) {
    final list = List<Goal>.from(src);
    list.sort((a, b) => a.startTime.compareTo(b.startTime));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DayGoalsModel>();
    final goals = _sortedByStartTime(vm.goals);
    final title = vm.lifeBlock ?? 'Все сферы';

    return Scaffold(
      appBar: AppBar(title: Text('${vm.formattedDate}  •  $title')),
      floatingActionButton: PopupMenuButton<_FabAction>(
        icon: const Icon(Icons.add),
        itemBuilder: (ctx) => const [
          PopupMenuItem(value: _FabAction.manual, child: Text('Добавить вручную')),
          PopupMenuItem(value: _FabAction.scan, child: Text('Загрузить фото ежедневника')),
        ],
        onSelected: (action) async {
          if (action == _FabAction.manual) {
            await _openAdd(context);
          } else {
            await importFromJournal(context, vm, visionApiKey: _kVisionApiKey);
          }
        },
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
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (ctx) => EditGoalSheet(
                            goal: g,
                            fixedLifeBlock: vm.lifeBlock,
                            availableBlocks: vm.availableBlocks,
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
                            startTime: res.startTime,
                          );
                        }
                      },
                    );
                  },
                ),
    );
  }
}
