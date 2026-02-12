import 'package:flutter/material.dart';
import '../main.dart'; // dbRepo
import 'goal.dart';

class DayGoalsModel extends ChangeNotifier {
  final DateTime date;
  final String? lifeBlock;
  final List<String> availableBlocks;

  DayGoalsModel({
    required this.date,
    required this.lifeBlock,
    this.availableBlocks = const [],
  });

  List<Goal> _goals = [];
  List<Goal> get goals => _goals;

  bool _loading = false;
  bool get loading => _loading;

  // Защита от "гонок"
  int _rev = 0;

  String get formattedDate =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  DateTime _dayStartUtc() => DateTime.utc(date.year, date.month, date.day);
  DateTime _dayEndUtc() => _dayStartUtc().add(const Duration(days: 1));

  Future<void> load() async {
    final myRev = ++_rev;

    _loading = true;
    notifyListeners();

    try {
      // GoalService убран — идём напрямую в dbRepo
      // Передаём "чистый день" в UTC, как у тебя было
      final allDay = await dbRepo.getGoalsByDate(
        DateTime.utc(date.year, date.month, date.day),
        lifeBlock: lifeBlock,
      );

      if (myRev != _rev) return;

      // lifeBlock уже отфильтрован на уровне запроса, но оставим защиту
      final filtered = lifeBlock == null
          ? allDay
          : allDay.where((g) => g.lifeBlock == lifeBlock).toList();

      filtered.sort((a, b) => a.startTime.compareTo(b.startTime));
      _goals = filtered;
    } finally {
      if (myRev == _rev) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> toggleComplete(Goal g) async {
    await dbRepo.toggleGoalCompleted(g.id, value: !g.isCompleted);
    await load();
  }

  Future<void> createGoal({
    required String title,
    required String description,
    required String lifeBlockValue,
    required int importance,
    required String emotion,
    required double hours,
    required TimeOfDay startTime,
  }) async {
    final startDateTimeUtc = DateTime.utc(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );

    await dbRepo.createGoal(
      title: title.trim(),
      description: description.trim(),
      deadline: _dayStartUtc(), // "день" в UTC
      lifeBlock: lifeBlockValue,
      importance: importance,
      emotion: emotion,
      spentHours: hours,
      startTime: startDateTimeUtc,
    );

    await load();
  }

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
      startTime: DateTime.utc(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      ),
      deadline: _dayStartUtc(),
    );

    await dbRepo.updateGoal(updated);
    await load();
  }

  Future<void> deleteGoal(String id) async {
    await dbRepo.deleteGoal(id);
    await load();
  }
}
