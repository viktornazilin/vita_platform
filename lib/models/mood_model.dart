import 'dart:async';

import 'package:flutter/material.dart';
import '../models/mood.dart';
import '../services/db_repo.dart';
import '../services/notification_service.dart';

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class MoodModel extends ChangeNotifier {
  final DbRepo repo; // инжектим репозиторий (Supabase/DB)
  MoodModel({required this.repo});

  final List<Mood> _moods = [];
  List<Mood> get moods => List.unmodifiable(_moods);

  bool _loading = false;
  bool get loading => _loading;

  /// Ошибка последнего фонового сохранения — UI может показать её
  /// ненавязчиво (snackbar), не блокируя экран.
  String? error;

  bool get hasTodayEntry {
    final today = DateTime.now();
    return _moods.any((m) => _sameDay(m.date, today));
  }

  Future<void> load({int limit = 30}) async {
    _loading = true;
    notifyListeners();
    try {
      final items = await repo.fetchMoods(limit: limit);
      _moods
        ..clear()
        ..addAll(items);

      // Запись за сегодня уже есть — отменяем напоминание, если оно почему-то
      // осталось (например, было запланировано на другом устройстве). Нет
      // записи — подтверждаем/планируем напоминание на сегодняшний вечер.
      // Время и включённость категории NotificationService берёт из
      // NotificationPreferences сам — сюда их передавать не нужно.
      _syncEveningReflectionReminder();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _syncEveningReflectionReminder() {
    if (hasTodayEntry) {
      unawaited(NotificationService.instance.cancelEveningReflection());
    } else {
      unawaited(NotificationService.instance.scheduleEveningReflection());
    }
  }

  /// Раньше: await upsertMood -> await load() (и функция не возвращалась,
  /// пока сервер не ответит) — форма стояла с задержкой ~секунду перед тем,
  /// как запись появлялась / можно было закрыть экран.
  /// Теперь: запись за сегодня появляется/обновляется в списке сразу,
  /// функция возвращает управление немедленно, а запрос уходит в фон.
  /// Возвращает `null` сразу — реальная ошибка сети (если будет) отразится
  /// в поле `error` уже после того, как вызывающий код продолжил работу.
  Future<String?> saveMood({
    required String emoji,
    required String note,
  }) async {
    error = null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final existingIdx = _moods.indexWhere((m) => _sameDay(m.date, today));
    final previous = existingIdx != -1 ? _moods[existingIdx] : null;
    final tempId = previous?.id ?? 'temp-${now.microsecondsSinceEpoch}';

    final optimistic = Mood(
      id: tempId,
      userId: previous?.userId ?? 'local',
      date: today,
      emoji: emoji,
      note: note,
    );

    if (existingIdx != -1) {
      _moods[existingIdx] = optimistic;
    } else {
      _moods.insert(0, optimistic);
    }
    notifyListeners();

    // Отменяем напоминание сразу, оптимистично — незачем ждать подтверждения
    // с сервера, чтобы понять, что запись за сегодня только что сделана.
    // Если фоновое сохранение всё же провалится (см. catch ниже), запись
    // откатится, и там же вернём напоминание обратно.
    unawaited(NotificationService.instance.cancelEveningReflection());

    unawaited(_saveMoodInBackground(
      now: now,
      emoji: emoji,
      note: note,
      tempId: tempId,
      previous: previous,
    ));

    return null;
  }

  Future<void> _saveMoodInBackground({
    required DateTime now,
    required String emoji,
    required String note,
    required String tempId,
    required Mood? previous,
  }) async {
    try {
      await repo.upsertMood(date: now, emoji: emoji, note: note);
      // load() внутри уже сам вызывает _syncEveningReflectionReminder() —
      // отдельно ничего делать не нужно.
      await load();
    } catch (e) {
      final idx = _moods.indexWhere((m) => m.id == tempId);
      if (idx != -1) {
        if (previous != null) {
          _moods[idx] = previous;
        } else {
          _moods.removeAt(idx);
        }
      }
      // Сохранение не удалось — если после отката записи за сегодня больше
      // нет, возвращаем напоминание обратно (мы его отменили оптимистично
      // в saveMood, считая, что сохранение точно пройдёт).
      if (!hasTodayEntry) {
        unawaited(NotificationService.instance.scheduleEveningReflection());
      }
      error = 'Не удалось сохранить настроение: $e';
      notifyListeners();
    }
  }
}