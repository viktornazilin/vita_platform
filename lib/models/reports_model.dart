import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import '../models/goal.dart';
import '../models/mood.dart';
import '../services/goal_service.dart';
import '../main.dart'; // dbRepo

enum ReportPeriod { day, week, month }

class ReportsModel extends ChangeNotifier {
  final GoalService _goalService = GoalService();

  bool _loading = true;
  bool get loading => _loading;

  ReportPeriod _period = ReportPeriod.month;
  ReportPeriod get period => _period;

  DateTime _anchor = DateTime.now();
  DateTime get anchor => _anchor;

  List<Goal> _allGoals = [];
  List<Mood> _allMoods = [];
  double _targetHours = 14;

  List<Goal> get allGoals => _allGoals;
  List<Mood> get allMoods => _allMoods;
  double get targetHours => _targetHours;

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();
    try {
      _allGoals = await _goalService.fetchGoals();
      _allMoods = await dbRepo.fetchMoods(limit: 120);
      _targetHours = await _goalService.getTargetHours();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setPeriod(ReportPeriod p) {
    if (_period == p) return;
    _period = p;
    notifyListeners();
  }

  void prev() {
    switch (_period) {
      case ReportPeriod.day:
        _anchor = _anchor.subtract(const Duration(days: 1));
        break;
      case ReportPeriod.week:
        _anchor = _anchor.subtract(const Duration(days: 7));
        break;
      case ReportPeriod.month:
        _anchor = DateTime(_anchor.year, _anchor.month - 1, 1);
        break;
    }
    notifyListeners();
  }

  void next() {
    switch (_period) {
      case ReportPeriod.day:
        _anchor = _anchor.add(const Duration(days: 1));
        break;
      case ReportPeriod.week:
        _anchor = _anchor.add(const Duration(days: 7));
        break;
      case ReportPeriod.month:
        _anchor = DateTime(_anchor.year, _anchor.month + 1, 1);
        break;
    }
    notifyListeners();
  }

  DateTimeRange get range {
    switch (_period) {
      case ReportPeriod.day:
        final start = DateTime(_anchor.year, _anchor.month, _anchor.day);
        return DateTimeRange(
          start: start,
          end: start.add(const Duration(days: 1)),
        );
      case ReportPeriod.week:
        final start = _anchor.subtract(
          Duration(days: (_anchor.weekday % 7)),
        ); // вс = 0
        final s = DateTime(start.year, start.month, start.day);
        return DateTimeRange(start: s, end: s.add(const Duration(days: 7)));
      case ReportPeriod.month:
        final s = DateTime(_anchor.year, _anchor.month, 1);
        final e = DateTime(_anchor.year, _anchor.month + 1, 1);
        return DateTimeRange(start: s, end: e);
    }
  }

  String get rangeLabel {
    switch (_period) {
      case ReportPeriod.day:
        return '${_anchor.day.toString().padLeft(2, '0')}.${_anchor.month.toString().padLeft(2, '0')}.${_anchor.year}';
      case ReportPeriod.week:
        final r = range;
        return '${r.start.day}.${r.start.month} — ${r.end.subtract(const Duration(days: 1)).day}.${r.end.month}';
      case ReportPeriod.month:
        return '${_anchor.year}.${_anchor.month.toString().padLeft(2, '0')}';
    }
  }

  Iterable<Goal> get goalsInRange => _allGoals.where(
    (g) =>
        g.deadline.isAfter(
          range.start.subtract(const Duration(microseconds: 1)),
        ) &&
        g.deadline.isBefore(range.end),
  );

  Iterable<Mood> get moodsInRange => _allMoods.where(
    (m) =>
        m.date.isAfter(range.start.subtract(const Duration(microseconds: 1))) &&
        m.date.isBefore(range.end),
  );

  Map<String, int> get doneByBlock => groupBy(
    goalsInRange.where((g) => g.isCompleted),
    (Goal g) => g.lifeBlock.isEmpty ? 'unknown' : g.lifeBlock,
  ).map((k, v) => MapEntry(k, v.length));

  Map<DateTime, double> get hoursByDay =>
      groupBy(
        goalsInRange,
        (Goal g) => DateTime(g.deadline.year, g.deadline.month, g.deadline.day),
      ).map(
        (d, list) =>
            MapEntry(d, list.fold<double>(0.0, (s, g) => s + g.spentHours)),
      );

  Map<String, int> get moodRatio => groupBy(
    moodsInRange,
    (Mood m) => m.emoji,
  ).map((k, v) => MapEntry(k, v.length));

  double get totalHours =>
      goalsInRange.fold<double>(0.0, (s, g) => s + g.spentHours);

  double get plannedHours {
    switch (_period) {
      case ReportPeriod.day:
        return _targetHours;
      case ReportPeriod.week:
        return _targetHours * 7;
      case ReportPeriod.month:
        return _targetHours *
            DateUtils.getDaysInMonth(_anchor.year, _anchor.month);
    }
  }

  double get efficiency =>
      plannedHours == 0 ? 0.0 : (totalHours / plannedHours).clamp(0.0, 1.0);

  // Доп. метрики (как в исходнике)
  double get avgTimePerGoal {
    final goals = goalsInRange.toList();
    if (goals.isEmpty) return 0.0;
    return goals.fold<double>(0.0, (s, g) => s + g.spentHours) / goals.length;
  }

  int get percentDoneOnTime {
    final goals = goalsInRange.toList();
    final completed = goals.where((g) => g.isCompleted).toList();
    if (completed.isEmpty) return 0;
    final onTime = completed
        .where((g) => g.deadline.isAfter(DateTime.now()))
        .length;
    return ((onTime / completed.length) * 100).round();
  }

  List<MapEntry<DateTime, double>> get top3DaysByHours {
    final byDay =
        groupBy(
              goalsInRange,
              (Goal g) =>
                  DateTime(g.deadline.year, g.deadline.month, g.deadline.day),
            ).entries
            .map(
              (e) => MapEntry(
                e.key,
                e.value.fold<double>(0.0, (s, g) => s + g.spentHours),
              ),
            )
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return byDay.take(3).toList();
  }
}
