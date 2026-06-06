import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import '../models/goal.dart';
import '../models/mood.dart';
import '../main.dart'; // dbRepo
import 'package:supabase_flutter/supabase_flutter.dart';

enum ReportPeriod { day, week, month }

class ReportsModel extends ChangeNotifier {
  bool _loading = true;
  bool get loading => _loading;

  ReportPeriod _period = ReportPeriod.month;
  ReportPeriod get period => _period;

  DateTime _anchor = DateTime.now();
  DateTime get anchor => _anchor;

  List<Goal> _allGoals = [];
  List<Mood> _allMoods = [];
  double _targetHours = 14;
  Map<String, double> _desiredLifeBalance = const {};

  List<Goal> get allGoals => _allGoals;
  List<Mood> get allMoods => _allMoods;
  double get targetHours => _targetHours;
  Map<String, double> get desiredLifeBalance => _desiredLifeBalance;

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();
    try {
      // ⬇️ GoalService убран: идём напрямую в dbRepo (GoalsRepoMixin)
      _allGoals = await dbRepo.fetchGoals();
      _allMoods = await dbRepo.fetchMoods(limit: 120);
      _targetHours = await dbRepo.getTargetHours();
      _desiredLifeBalance = await _loadDesiredLifeBalance();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }


  Future<Map<String, double>> _loadDesiredLifeBalance() async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null || userId.trim().isEmpty) return const {};

      final row = await client
          .from('users')
          .select('priorities, weights')
          .eq('id', userId)
          .maybeSingle();

      if (row == null) return const {};
      final priorities = (row['priorities'] as List?)
              ?.map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const <String>[];
      final weights = (row['weights'] as List?) ?? const [];
      if (priorities.isEmpty || weights.isEmpty) return const {};

      final out = <String, double>{};
      for (var i = 0; i < priorities.length && i < weights.length; i++) {
        final raw = weights[i];
        final value = raw is num ? raw.toDouble() : double.tryParse(raw.toString()) ?? 0.0;
        if (value <= 0) continue;
        out[_normalizeLifeBlockKey(priorities[i])] = value <= 1.0 ? value * 100 : value;
      }
      return Map.unmodifiable(out);
    } catch (_) {
      return const {};
    }
  }

  String _normalizeLifeBlockKey(String key) {
    final k = key.trim().toLowerCase();
    switch (k) {
      case 'health':
      case 'здоровье':
        return 'health';
      case 'career':
      case 'work':
      case 'карьера':
        return 'career';
      case 'family':
      case 'семья':
        return 'family';
      case 'relations':
      case 'relationship':
      case 'relationships':
      case 'отношения':
        return 'relations';
      case 'education':
      case 'study':
      case 'образование':
      case 'обучение':
        return 'education';
      case 'finance':
      case 'finances':
      case 'финансы':
        return 'finance';
      case 'hobby':
      case 'hobbies':
      case 'хобби':
        return 'hobby';
      case 'spirituality':
      case 'spirit':
      case 'духовность':
        return 'spirituality';
      default:
        return k;
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

    // NOTE: логика "done on time" у тебя была странная (deadline after now).
    // Оставляю как есть, чтобы не менять поведение.
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
