import 'package:flutter/material.dart';

import '../models/user_goal.dart';

class UserGoalsModel extends ChangeNotifier {
  final dynamic repo;

  UserGoalsModel({required this.repo});

  bool loading = false;
  String? error;

  List<UserGoal> _items = [];
  List<UserGoal> get items => List.unmodifiable(_items);

  String _selectedBlock = 'all';
  String get selectedBlock => _selectedBlock;

  GoalHorizon? _selectedHorizon;
  GoalHorizon? get selectedHorizon => _selectedHorizon;

  Map<String, Map<GoalHorizon, List<UserGoal>>> get grouped {
    final out = <String, Map<GoalHorizon, List<UserGoal>>>{};

    for (final g in _items) {
      final byH = out.putIfAbsent(g.lifeBlock, () => {});
      final list = byH.putIfAbsent(g.horizon, () => <UserGoal>[]);
      list.add(g);
    }

    for (final byH in out.values) {
      for (final list in byH.values) {
        list.sort((a, b) {
          if (a.sortOrder != b.sortOrder) {
            return a.sortOrder.compareTo(b.sortOrder);
          }
          return b.createdAt.compareTo(a.createdAt);
        });
      }
    }

    return out;
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      _items = await repo.getUserGoals(
        lifeBlock: _selectedBlock == 'all' ? null : _selectedBlock,
        horizon: _selectedHorizon,
        includeCompleted: true,
      );
    } catch (e) {
      error = '$e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setSelectedBlock(String block) {
    _selectedBlock = block;
    load();
  }

  void setSelectedHorizon(GoalHorizon? horizon) {
    _selectedHorizon = horizon;
    load();
  }

  Future<String?> upsert(UserGoalUpsert dto) async {
    try {
      if (dto.id == null || dto.id!.isEmpty) {
        await repo.createUserGoal(
          lifeBlock: dto.lifeBlock,
          horizon: dto.horizon,
          title: dto.title,
          description: dto.description,
          targetDate: dto.targetDate,
          sortOrder: dto.sortOrder,
          isCompleted: dto.isCompleted,
          completedAt: dto.completedAt,
        );
      } else {
        await repo.updateUserGoal(
          id: dto.id!,
          lifeBlock: dto.lifeBlock,
          horizon: dto.horizon,
          title: dto.title,
          description: dto.description,
          targetDate: dto.targetDate,
          sortOrder: dto.sortOrder,
          isCompleted: dto.isCompleted,
          completedAt: dto.completedAt,
        );
      }

      await load();
      return null;
    } catch (e) {
      return '$e';
    }
  }

  Future<String?> delete(String id) async {
    try {
      await repo.deleteUserGoal(id);
      await load();
      return null;
    } catch (e) {
      return '$e';
    }
  }

  Future<String?> toggleCompleted(UserGoal goal) async {
    try {
      await repo.setUserGoalCompleted(
        id: goal.id,
        completed: !goal.isCompleted,
      );
      await load();
      return null;
    } catch (e) {
      return '$e';
    }
  }

  List<UserGoal> goalsByHorizon(GoalHorizon horizon) {
    return _items.where((g) => g.horizon == horizon).toList();
  }

  Future<void> createGoal({
    required String lifeBlock,
    required GoalHorizon horizon,
    required String title,
    String? description,
    DateTime? targetDate,
    int sortOrder = 0,
  }) async {
    await repo.createUserGoal(
      lifeBlock: lifeBlock,
      horizon: horizon,
      title: title,
      description: description,
      targetDate: targetDate,
      sortOrder: sortOrder,
      isCompleted: false,
      completedAt: null,
    );
    await load();
  }

  Future<void> updateGoal({
    required String id,
    required String lifeBlock,
    required GoalHorizon horizon,
    required String title,
    String? description,
    DateTime? targetDate,
    required int sortOrder,
    bool isCompleted = false,
    DateTime? completedAt,
  }) async {
    await repo.updateUserGoal(
      id: id,
      lifeBlock: lifeBlock,
      horizon: horizon,
      title: title,
      description: description,
      targetDate: targetDate,
      sortOrder: sortOrder,
      isCompleted: isCompleted,
      completedAt: completedAt,
    );
    await load();
  }
}