import 'package:flutter/material.dart';
import '../main.dart'; // dbRepo
import 'goal.dart';

class DayGoalsModel extends ChangeNotifier {
  final DateTime date;
  final String? lifeBlock;
  final List<String> availableBlocks;

  /// null + personalOnly=false => all visible goals: private + space goals.
  /// null + personalOnly=true  => only private goals.
  /// non-null                  => only goals from selected space.
  String? spaceId;
  bool personalOnly;

  DayGoalsModel({
    required this.date,
    required this.lifeBlock,
    this.availableBlocks = const [],
    this.spaceId,
    this.personalOnly = false,
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

  DateTime _dateOnlyUtc(DateTime value) =>
      DateTime.utc(value.year, value.month, value.day);

  DateTime _combineDateAndTimeUtc(DateTime value, TimeOfDay time) =>
      DateTime.utc(value.year, value.month, value.day, time.hour, time.minute);

  Future<void> setSpaceFilter({
    String? selectedSpaceId,
    bool onlyPersonal = false,
  }) async {
    spaceId = selectedSpaceId;
    personalOnly = onlyPersonal;
    await load();
  }

  Future<void> load() async {
    final myRev = ++_rev;

    _loading = true;
    notifyListeners();

    try {
      final allDay = await dbRepo.getGoalsByDate(
        DateTime.utc(date.year, date.month, date.day),
        lifeBlock: lifeBlock,
        spaceId: spaceId,
        personalOnly: personalOnly,
      );

      if (myRev != _rev) return;

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
    String? userGoalId,
    String? spaceId,
    String? assignedTo,
  }) async {
    final startDateTimeUtc = _combineDateAndTimeUtc(date, startTime);
    final normalizedSpaceId = _blankToNull(spaceId);

    await dbRepo.createGoal(
      title: title.trim(),
      description: description.trim(),
      deadline: _dayStartUtc(),
      lifeBlock: lifeBlockValue,
      importance: importance,
      emotion: emotion,
      spentHours: hours,
      startTime: startDateTimeUtc,
      userGoalId: userGoalId,
      spaceId: normalizedSpaceId,
      assignedTo: _blankToNull(assignedTo),
      visibility: normalizedSpaceId == null ? 'private' : 'space',
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
    DateTime? targetDate,
    String? userGoalId,
    String? spaceId,
    String? assignedTo,
  }) async {
    // ВАЖНО:
    // Раньше дата всегда бралась из DayGoalsModel.date, то есть из текущего
    // открытого дня. Поэтому при выборе новой даты в UI цель всё равно
    // сохранялась в старом дне.
    //
    // Теперь, если edit sheet/dialog передаёт targetDate, deadline и startTime
    // собираются именно на основе выбранной пользователем даты.
    final effectiveDate = targetDate ?? date;
    final deadlineUtc = _dateOnlyUtc(effectiveDate);
    final startDateTimeUtc = _combineDateAndTimeUtc(effectiveDate, startTime);
    final normalizedSpaceId = _blankToNull(spaceId);

    await dbRepo.updateGoalFields(
      goalId: id,
      title: title.trim(),
      description: description.trim(),
      deadline: deadlineUtc,
      lifeBlock: lifeBlockValue,
      importance: importance,
      emotion: emotion,
      spentHours: hours,
      startTime: startDateTimeUtc,
      userGoalId: userGoalId,
      spaceId: normalizedSpaceId,
      assignedTo: _blankToNull(assignedTo),
      visibility: normalizedSpaceId == null ? 'private' : 'space',
    );

    await load();
  }

  Future<void> deleteGoal(String id) async {
    await dbRepo.deleteGoal(id);
    await load();
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
