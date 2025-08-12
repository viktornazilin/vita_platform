import 'package:flutter/foundation.dart';
import '../models/goal.dart';
import '../services/goal_service.dart';

class DayGoalsModel extends ChangeNotifier {
  final GoalService _service;
  final DateTime date;
  final String? lifeBlock;
  final List<String> availableBlocks;

  DayGoalsModel({
    GoalService? service,
    required this.date,
    required this.lifeBlock,
    this.availableBlocks = const [],
  }) : _service = service ?? GoalService();

  List<Goal> _goals = [];
  List<Goal> get goals => _goals;

  bool _loading = false;
  bool get loading => _loading;

  String get formattedDate =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    final allDay = await _service.getGoalsByDate(date);
    final filtered = lifeBlock == null
        ? allDay
        : allDay.where((g) => g.lifeBlock == lifeBlock).toList();

    filtered.sort((a, b) =>
        a.isCompleted == b.isCompleted ? 0 : (a.isCompleted ? 1 : -1));

    _goals = filtered;
    _loading = false;
    notifyListeners();
  }

  Future<void> toggleComplete(Goal g) async {
    await _service.completeGoal(g.id);
    await load();
  }

  Future<void> createGoal({
    required String title,
    required String description,
    required String lifeBlockValue,
    required int importance,
    required String emotion,
    required double hours,
  }) async {
    await _service.createGoal(
      title: title.trim(),
      description: description.trim(),
      deadline: DateTime(date.year, date.month, date.day),
      lifeBlock: lifeBlockValue,
      importance: importance,
      emotion: emotion,
      spentHours: hours,
    );
    await load();
  }
}
