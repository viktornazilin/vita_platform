// lib/models/user_goals_model.dart
import 'package:flutter/foundation.dart';

import '../services/user_goals_repo_mixin.dart'; // UserGoal, GoalHorizon, UserGoalUpsert
import '../services/core/base_repo.dart';

class UserGoalsModel extends ChangeNotifier {
  final BaseRepo repo;
  UserGoalsModel({required this.repo});

  bool loading = false;
  String? error;

  // grouped[lifeBlock][horizon] = list
  Map<String, Map<GoalHorizon, List<UserGoal>>> grouped = {};

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final list = await (repo as dynamic)
          .listGoals(); // from UserGoalsRepoMixin
      grouped = _group(list);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Map<String, Map<GoalHorizon, List<UserGoal>>> _group(List<UserGoal> list) {
    final out = <String, Map<GoalHorizon, List<UserGoal>>>{};

    for (final g in list) {
      final b = g.lifeBlock;
      out.putIfAbsent(
        b,
        () => {
          GoalHorizon.tactical: <UserGoal>[],
          GoalHorizon.mid: <UserGoal>[],
          GoalHorizon.long: <UserGoal>[],
        },
      );
      out[b]![g.horizon]!.add(g);
    }

    // сортировка: свежие сверху (createdAt) или по targetDate
    for (final b in out.keys) {
      for (final h in GoalHorizon.values) {
        out[b]![h]!.sort((a, c) {
          final ad = a.targetDate ?? a.createdAt ?? DateTime(1970);
          final cd = c.targetDate ?? c.createdAt ?? DateTime(1970);
          return cd.compareTo(ad);
        });
      }
    }

    return out;
  }

  Future<String?> upsert(UserGoalUpsert dto) async {
    try {
      await (repo as dynamic).upsertGoals([dto]);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> delete(String id) async {
    try {
      await (repo as dynamic).deleteGoal(id);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
