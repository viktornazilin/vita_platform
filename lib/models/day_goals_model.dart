import 'package:flutter/material.dart'; // TimeOfDay
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

  /// Загружаем цели на день и сортируем по времени начала
  Future<void> load() async {
    _loading = true;
    notifyListeners();

    final allDay = await _service.getGoalsByDate(date);

    final filtered = lifeBlock == null
        ? allDay
        : allDay.where((g) => g.lifeBlock == lifeBlock).toList();

    // Сортировка по времени начала (возрастание), независимо от выполнения
    filtered.sort((a, b) => a.startTime.compareTo(b.startTime));

    _goals = filtered;
    _loading = false;
    notifyListeners();
  }

  /// Переключить выполнение (в обе стороны)
  Future<void> toggleComplete(Goal g) async {
    await _service.toggleCompleted(g.id, value: !g.isCompleted);
    await load();
  }

  /// Создать новую цель (конвертируем TimeOfDay -> DateTime)
  Future<void> createGoal({
    required String title,
    required String description,
    required String lifeBlockValue,
    required int importance,
    required String emotion,
    required double hours,
    required TimeOfDay startTime,
  }) async {
    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );

    await _service.createGoal(
      title: title.trim(),
      description: description.trim(),
      deadline: DateTime(date.year, date.month, date.day),
      lifeBlock: lifeBlockValue,
      importance: importance,
      emotion: emotion,
      spentHours: hours,
      startTime: startDateTime,
    );
    await load();
  }

  /// Обновить существующую цель (конвертируем TimeOfDay -> DateTime)
  Future<void> updateGoal({
    required String id,
    required String title,
    required String description,
    required String lifeBlockValue,
    required int importance,
    required String emotion,
    required double hours,
    required TimeOfDay startTime,
  }) async {
    final old = _goals.firstWhere((g) => g.id == id);

    final updated = old.copyWith(
      title: title.trim(),
      description: description.trim(),
      lifeBlock: lifeBlockValue,
      importance: importance,
      emotion: emotion,
      spentHours: hours,
      startTime: DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      ),
    );

    await _service.updateGoal(updated);
    await load();
  }

  /// Удалить цель
  Future<void> deleteGoal(Goal goal) async {
    await _service.deleteGoal(goal.id);
    await load();
  }
}
