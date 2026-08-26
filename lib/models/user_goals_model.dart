import 'dart:async';

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

    for (final g in filteredItems) {
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

  /// Все цели из БД, без фильтра по блоку.
  /// Фильтрация по lifeBlock должна происходить уже на уровне UI/геттеров.
  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      _items = await repo.getUserGoals(
        lifeBlock: null,
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

  /// Отфильтрованный список для отображения на экране.
  /// Но исходный _items всегда содержит все цели.
  List<UserGoal> get filteredItems {
    Iterable<UserGoal> result = _items;

    if (_selectedBlock != 'all') {
      final selected = _selectedBlock.trim().toLowerCase();
      result = result.where(
        (g) => g.lifeBlock.trim().toLowerCase() == selected,
      );
    }

    if (_selectedHorizon != null) {
      result = result.where((g) => g.horizon == _selectedHorizon);
    }

    final list = result.toList();

    list.sort((a, b) {
      if (a.sortOrder != b.sortOrder) {
        return a.sortOrder.compareTo(b.sortOrder);
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return list;
  }

  void setSelectedBlock(String block) {
    _selectedBlock = block;
    notifyListeners();
  }

  void setSelectedHorizon(GoalHorizon? horizon) {
    _selectedHorizon = horizon;
    load();
  }

  /// Раньше: await create/updateUserGoal -> await load() (и функция не
  /// возвращалась, пока сервер не ответит) — форма/шторка "зависала" на
  /// секунду перед закрытием.
  /// Теперь: временная (для новой цели) или обновлённая карточка появляется
  /// в списке сразу, функция возвращает управление немедленно, а запрос и
  /// тихая синхронизация со списком идут в фоне.
  Future<String?> upsert(UserGoalUpsert dto) async {
    error = null;
    final now = DateTime.now();
    final isNew = dto.id == null || dto.id!.isEmpty;

    if (isNew) {
      final tempId = 'temp-${now.microsecondsSinceEpoch}';
      final optimistic = UserGoal(
        id: tempId,
        userId: 'local',
        lifeBlock: dto.lifeBlock,
        horizon: dto.horizon,
        title: dto.title.trim(),
        description: dto.description,
        targetDate: dto.targetDate,
        isCompleted: dto.isCompleted,
        completedAt: dto.completedAt,
        sortOrder: dto.sortOrder,
        createdAt: now,
        updatedAt: now,
      );
      _items = [..._items, optimistic];
      notifyListeners();

      unawaited(_createInBackground(tempId: tempId, dto: dto));
    } else {
      final idx = _items.indexWhere((x) => x.id == dto.id);
      final previous = idx != -1 ? _items[idx] : null;

      if (previous != null) {
        final optimistic = previous.copyWith(
          lifeBlock: dto.lifeBlock,
          horizon: dto.horizon,
          title: dto.title.trim(),
          description: dto.description,
          targetDate: dto.targetDate,
          isCompleted: dto.isCompleted,
          completedAt: dto.completedAt,
          sortOrder: dto.sortOrder,
          updatedAt: now,
        );
        _items = [..._items];
        _items[idx] = optimistic;
        notifyListeners();
      }

      unawaited(_updateInBackground(id: dto.id!, dto: dto, previous: previous));
    }

    return null;
  }

  Future<void> _createInBackground({
    required String tempId,
    required UserGoalUpsert dto,
  }) async {
    try {
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
      await load();
    } catch (e) {
      _items = _items.where((x) => x.id != tempId).toList();
      error = '$e';
      notifyListeners();
    }
  }

  Future<void> _updateInBackground({
    required String id,
    required UserGoalUpsert dto,
    required UserGoal? previous,
  }) async {
    try {
      await repo.updateUserGoal(
        id: id,
        lifeBlock: dto.lifeBlock,
        horizon: dto.horizon,
        title: dto.title,
        description: dto.description,
        targetDate: dto.targetDate,
        sortOrder: dto.sortOrder,
        isCompleted: dto.isCompleted,
        completedAt: dto.completedAt,
      );
      await load();
    } catch (e) {
      if (previous != null) {
        final idx = _items.indexWhere((x) => x.id == id);
        if (idx != -1) {
          _items = [..._items];
          _items[idx] = previous;
        }
      }
      error = '$e';
      notifyListeners();
    }
  }

  /// Полностью оптимистично: цель уже загружена в _items, убираем сразу,
  /// восстанавливаем при ошибке.
  Future<String?> delete(String id) async {
    error = null;
    final idx = _items.indexWhere((x) => x.id == id);
    final previous = idx != -1 ? _items[idx] : null;

    if (previous != null) {
      _items = _items.where((x) => x.id != id).toList();
      notifyListeners();
    }

    unawaited(_deleteInBackground(id: id, previous: previous));

    return null;
  }

  Future<void> _deleteInBackground({
    required String id,
    required UserGoal? previous,
  }) async {
    try {
      await repo.deleteUserGoal(id);
    } catch (e) {
      if (previous != null) {
        _items = [..._items, previous];
        notifyListeners();
      }
      error = '$e';
      notifyListeners();
    }
  }

  /// Полностью оптимистично: переключаем isCompleted локально через
  /// copyWith, без ожидания сети и без полной перезагрузки списка.
  Future<String?> toggleCompleted(UserGoal goal) async {
    error = null;
    final idx = _items.indexWhere((x) => x.id == goal.id);
    if (idx == -1) return null;

    final previous = _items[idx];
    final newCompleted = !previous.isCompleted;
    final optimistic = previous.copyWith(
      isCompleted: newCompleted,
      completedAt: newCompleted ? DateTime.now() : null,
    );
    _items = [..._items];
    _items[idx] = optimistic;
    notifyListeners();

    unawaited(_toggleCompletedInBackground(
      id: goal.id,
      completed: newCompleted,
      previous: previous,
    ));

    return null;
  }

  Future<void> _toggleCompletedInBackground({
    required String id,
    required bool completed,
    required UserGoal previous,
  }) async {
    try {
      await repo.setUserGoalCompleted(id: id, completed: completed);
    } catch (e) {
      final idx = _items.indexWhere((x) => x.id == id);
      if (idx != -1) {
        _items = [..._items];
        _items[idx] = previous;
      }
      error = '$e';
      notifyListeners();
    }
  }

  List<UserGoal> goalsByHorizon(GoalHorizon horizon) {
    return filteredItems.where((g) => g.horizon == horizon).toList();
  }

  Future<void> createGoal({
    required String lifeBlock,
    required GoalHorizon horizon,
    required String title,
    String? description,
    DateTime? targetDate,
    int sortOrder = 0,
  }) => upsert(UserGoalUpsert(
        lifeBlock: lifeBlock,
        horizon: horizon,
        title: title,
        description: description,
        targetDate: targetDate,
        sortOrder: sortOrder,
      ));

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
  }) => upsert(UserGoalUpsert(
        id: id,
        lifeBlock: lifeBlock,
        horizon: horizon,
        title: title,
        description: description,
        targetDate: targetDate,
        sortOrder: sortOrder,
        isCompleted: isCompleted,
        completedAt: completedAt,
      ));
}