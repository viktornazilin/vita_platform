import 'dart:async';

import 'package:flutter/material.dart';
import '../main.dart'; // dbRepo
import 'goal.dart';
import '../services/notification_service.dart';

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

  /// Ошибка последней фоновой синхронизации (создание/изменение/удаление).
  /// UI может показать это ненавязчиво (snackbar), не блокируя сам экран.
  String? error;

  // Защита от "гонок"
  int _rev = 0;

  String get formattedDate =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  DateTime _dayStartUtc() => DateTime.utc(date.year, date.month, date.day);

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

      // Синхронизируем локальные напоминания с тем, что реально загружено.
      // Идемпотентно и безопасно вызывать на каждый load(): id уведомления
      // детерминирован от goal.id, повторный schedule просто перезаписывает
      // существующее. Закрывает и кейс целей, созданных до появления этой
      // фичи — у них никогда не было запланировано напоминание, а тут оно
      // появится при первой же загрузке дня.
      _syncGoalReminders(filtered);
    } finally {
      if (myRev == _rev) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  /// Раньше: await toggleGoalCompleted -> await load() — пользователь видел
  /// задержку ~секунду на каждый тап по чекбоксу.
  /// Теперь: чекбокс переключается мгновенно локально и функция сразу же
  /// возвращает управление — запрос уходит в фон, не заставляя вызывающий
  /// код (и, соответственно, экран) ждать. Если сервер вернёт ошибку —
  /// состояние откатывается назад.
  Future<void> toggleComplete(Goal g) async {
    final idx = _goals.indexWhere((x) => x.id == g.id);
    if (idx == -1) return;

    final previous = _goals[idx];
    final optimistic = previous.copyWith(isCompleted: !previous.isCompleted);

    _goals = [..._goals];
    _goals[idx] = optimistic;
    notifyListeners();

    if (optimistic.isCompleted) {
      unawaited(NotificationService.instance.cancelGoalReminder(g.id));
    } else {
      unawaited(NotificationService.instance.scheduleGoalReminder(
        goalId: g.id,
        title: optimistic.title,
        startTime: optimistic.startTime,
      ));
    }

    unawaited(_toggleCompleteInBackground(
      goalId: g.id,
      value: optimistic.isCompleted,
      previous: previous,
    ));
  }

  Future<void> _toggleCompleteInBackground({
    required String goalId,
    required bool value,
    required Goal previous,
  }) async {
    try {
      await dbRepo.toggleGoalCompleted(goalId, value: value);
    } catch (e) {
      final idx = _goals.indexWhere((x) => x.id == goalId);
      if (idx != -1) {
        _goals = [..._goals];
        _goals[idx] = previous;
      }
      // Откатываем и напоминание в соответствие с восстановленным состоянием.
      if (previous.isCompleted) {
        unawaited(NotificationService.instance.cancelGoalReminder(goalId));
      } else {
        unawaited(NotificationService.instance.scheduleGoalReminder(
          goalId: goalId,
          title: previous.title,
          startTime: previous.startTime,
        ));
      }
      error = 'Не удалось сохранить: $e';
      notifyListeners();
    }
  }

  /// Раньше: await createGoal -> await load() (и функция не возвращалась,
  /// пока сервер не ответит) — форма/шторка "зависала" на секунду перед
  /// закрытием.
  /// Теперь: временная карточка цели появляется в списке сразу, функция
  /// возвращается немедленно (шторку можно закрывать сразу), а запрос и
  /// тихая синхронизация со списком идут в фоне.
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
    final tempId = 'temp-${DateTime.now().microsecondsSinceEpoch}';

    final optimisticGoal = Goal(
      id: tempId,
      userId: 'local',
      title: title.trim(),
      description: description.trim(),
      deadline: _dayStartUtc(),
      startTime: startDateTimeUtc,
      lifeBlock: lifeBlockValue,
      importance: importance,
      emotion: emotion,
      spentHours: hours,
      userGoalId: userGoalId,
      spaceId: normalizedSpaceId,
      assignedTo: _blankToNull(assignedTo),
      visibility: normalizedSpaceId == null ? 'private' : 'space',
    );

    _goals = [..._goals, optimisticGoal]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    notifyListeners();

    // Планируем напоминание сразу на tempId — ради честной мгновенности.
    // После успешной синхронизации с сервером (ниже) перепланируем его на
    // настоящий id, иначе кнопка "Готово" в уведомлении будет дёргать
    // несуществующую запись.
    unawaited(NotificationService.instance.scheduleGoalReminder(
      goalId: tempId,
      title: optimisticGoal.title,
      startTime: optimisticGoal.startTime,
    ));

    unawaited(_createGoalInBackground(tempId: tempId, goal: optimisticGoal));
  }

  Future<void> _createGoalInBackground({
    required String tempId,
    required Goal goal,
  }) async {
    try {
      await dbRepo.createGoal(
        title: goal.title,
        description: goal.description,
        deadline: goal.deadline,
        lifeBlock: goal.lifeBlock,
        importance: goal.importance,
        emotion: goal.emotion,
        spentHours: goal.spentHours,
        startTime: goal.startTime,
        userGoalId: goal.userGoalId,
        spaceId: goal.spaceId,
        assignedTo: goal.assignedTo,
        visibility: goal.visibility,
      );
      // Тихая синхронизация с реальными данными сервера (без loading-спиннера,
      // т.к. _loading здесь не трогаем — временная карточка уже видна).
      await _reconcileSilently();

      // Находим свежесозданную запись среди уже перезагруженных _goals по
      // совпадению содержимого (id не поможет — он изменился с tempId на
      // настоящий). Единственный способ надёжно связать их без похода в БД
      // за id: у dbRepo.createGoal нет возврата созданной записи, поэтому
      // сверяемся по полям. Не идеально при дублирующихся целях день-в-день
      // с одинаковым названием и временем, но это редкий и не критичный
      // случай — в худшем случае просто не будет "Готово"-кнопки в
      // уведомлении, само напоминание всё равно сработает.
      final match = _goals.where((x) =>
          x.id != tempId &&
          x.title == goal.title &&
          x.startTime == goal.startTime &&
          x.lifeBlock == goal.lifeBlock);
      if (match.isNotEmpty) {
        final real = match.first;
        unawaited(NotificationService.instance.cancelGoalReminder(tempId));
        if (!real.isCompleted) {
          unawaited(NotificationService.instance.scheduleGoalReminder(
            goalId: real.id,
            title: real.title,
            startTime: real.startTime,
          ));
        }
      }
    } catch (e) {
      unawaited(NotificationService.instance.cancelGoalReminder(tempId));
      _goals = _goals.where((x) => x.id != tempId).toList();
      error = 'Не удалось создать: $e';
      notifyListeners();
    }
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
    final effectiveDate = targetDate ?? date;
    final deadlineUtc = _dateOnlyUtc(effectiveDate);
    final startDateTimeUtc = _combineDateAndTimeUtc(effectiveDate, startTime);
    final normalizedSpaceId = _blankToNull(spaceId);

    final idx = _goals.indexWhere((x) => x.id == id);
    final previous = idx != -1 ? _goals[idx] : null;
    if (previous == null) return;

    final optimistic = previous.copyWith(
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
    _goals = [..._goals];
    _goals[idx] = optimistic;
    notifyListeners();

    // id тут уже настоящий (не temp), поэтому можно просто перепланировать
    // сразу — никакой реконсиляции id не требуется, в отличие от createGoal.
    if (optimistic.isCompleted) {
      unawaited(NotificationService.instance.cancelGoalReminder(id));
    } else {
      unawaited(NotificationService.instance.scheduleGoalReminder(
        goalId: id,
        title: optimistic.title,
        startTime: optimistic.startTime,
      ));
    }

    unawaited(_updateGoalInBackground(
      id: id,
      goal: optimistic,
      previous: previous,
    ));
  }

  Future<void> _updateGoalInBackground({
    required String id,
    required Goal goal,
    required Goal previous,
  }) async {
    try {
      await dbRepo.updateGoalFields(
        goalId: id,
        title: goal.title,
        description: goal.description,
        deadline: goal.deadline,
        lifeBlock: goal.lifeBlock,
        importance: goal.importance,
        emotion: goal.emotion,
        spentHours: goal.spentHours,
        startTime: goal.startTime,
        userGoalId: goal.userGoalId,
        spaceId: goal.spaceId,
        assignedTo: goal.assignedTo,
        visibility: goal.visibility,
      );
      await _reconcileSilently();
    } catch (e) {
      final idx = _goals.indexWhere((x) => x.id == id);
      if (idx != -1) {
        _goals = [..._goals];
        _goals[idx] = previous;
      }
      // Откат: возвращаем напоминание к тому, каким оно было до правки.
      if (previous.isCompleted) {
        unawaited(NotificationService.instance.cancelGoalReminder(id));
      } else {
        unawaited(NotificationService.instance.scheduleGoalReminder(
          goalId: id,
          title: previous.title,
          startTime: previous.startTime,
        ));
      }
      error = 'Не удалось сохранить изменения: $e';
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    final idx = _goals.indexWhere((x) => x.id == id);
    if (idx == -1) return;

    final previous = _goals[idx];
    _goals = _goals.where((x) => x.id != id).toList();
    notifyListeners();

    unawaited(NotificationService.instance.cancelGoalReminder(id));

    unawaited(_deleteGoalInBackground(id: id, previous: previous));
  }

  Future<void> _deleteGoalInBackground({
    required String id,
    required Goal previous,
  }) async {
    try {
      await dbRepo.deleteGoal(id);
    } catch (e) {
      final restored = [..._goals, previous]
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      _goals = restored;
      // Удаление не удалось — цель вернулась, возвращаем и напоминание.
      if (!previous.isCompleted) {
        unawaited(NotificationService.instance.scheduleGoalReminder(
          goalId: id,
          title: previous.title,
          startTime: previous.startTime,
        ));
      }
      error = 'Не удалось удалить: $e';
      notifyListeners();
    }
  }

  /// Приводит запланированные локальные напоминания в соответствие с тем,
  /// что сейчас в [goals]: выполненным целям напоминание не нужно, у
  /// невыполненных — должно быть запланировано (или обновлено, если
  /// время/заголовок изменились после правки на другом устройстве).
  void _syncGoalReminders(List<Goal> goals) {
    for (final g in goals) {
      if (g.isCompleted) {
        unawaited(NotificationService.instance.cancelGoalReminder(g.id));
      } else {
        unawaited(NotificationService.instance.scheduleGoalReminder(
          goalId: g.id,
          title: g.title,
          startTime: g.startTime,
        ));
      }
    }
  }

  /// Перезагружает список в фоне, не показывая _loading/спиннер — только
  /// подменяет данные, когда они готовы (временные карточки уже видны).
  Future<void> _reconcileSilently() async {
    final myRev = ++_rev;
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
      notifyListeners();
    } catch (_) {
      // Тихая синхронизация не удалась — временные данные останутся видны
      // до следующего успешного load(). Не показываем ошибку пользователю
      // здесь, т.к. сама операция (create/update) уже подтвердилась успешно.
    }
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}