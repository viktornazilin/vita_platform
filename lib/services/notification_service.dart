import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'notification_preferences.dart';

/// Единая точка входа для локальных уведомлений в Ladna.
///
/// Дизайн-решения:
/// - Один сервис-синглтон, инициализируется один раз при старте приложения
///   (см. `NotificationService.instance.init()` в `main.dart`).
/// - Разрешение на уведомления запрашивается ОТДЕЛЬНО от инициализации
///   (`requestPermission()`), чтобы можно было показать свой soft-ask экран
///   перед системным диалогом iOS — если направить это сразу с холодного
///   старта, конверсия в разрешённое существенно ниже.
/// - id уведомления детерминированно выводится из id цели (`goalNotificationId`),
///   чтобы при повторном планировании (после редактирования) не плодить
///   дубликаты — просто пересоздаём уведомление с тем же id.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Действие "Отметить готово" прямо из уведомления (Шаг 4/5, включим позже
  /// когда прикрутим обработку нажатий к DayGoalsModel).
  static const String actionMarkDone = 'mark_done';
  static const String actionSnooze15 = 'snooze_15';

  static const String _goalReminderCategoryId = 'goal_reminder';

  Future<void> init({
    void Function(NotificationResponse response)? onNotificationTap,
  }) async {
    // flutter_local_notifications не поддерживает web вообще, а
    // Platform.isIOS/isAndroid (dart:io) кидает UnsupportedError в рантайме
    // на web, а не просто возвращает false. На web этот сервис — no-op,
    // веб-уведомления обрабатывает отдельный WebNotificationsService
    // (services/web_notifications_service.dart). Раз _initialized тут
    // остаётся false, все остальные методы ниже (schedule*/cancel*) тоже
    // тихо no-op благодаря их собственным `if (!_initialized) return;`.
    if (kIsWeb) return;
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (e) {
      // Если не удалось определить пояс устройства — откатываемся на UTC,
      // чтобы приложение не падало; уведомления всё ещё будут работать,
      // просто с меньшей точностью до момента следующего успешного вызова.
      debugPrint('NotificationService: failed to resolve local timezone: $e');
    }

    const iosSettings = DarwinInitializationSettings(
      // Не просим разрешение автоматически при первом показе локального
      // уведомления — управляем этим сами через requestPermission().
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: [
        DarwinNotificationCategory(
          _goalReminderCategoryId,
          actions: [
            DarwinNotificationAction.plain(
              actionMarkDone,
              'Готово',
              options: {DarwinNotificationActionOption.foreground},
            ),
            DarwinNotificationAction.plain(
              actionSnooze15,
              'Отложить на 15 мин',
            ),
          ],
          options: {
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
          },
        ),
      ],
    );

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final initSettings = InitializationSettings(
      iOS: iosSettings,
      android: androidSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
    );

    _initialized = true;
  }

  /// Показывает системный запрос разрешения. Вызывать только после того,
  /// как пользователь подтвердил на своём (soft-ask) экране, что хочет
  /// включить уведомления — см. Шаг 5.
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    if (Platform.isIOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return granted ?? false;
    }

    if (Platform.isAndroid) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return granted ?? false;
    }

    return false;
  }

  /// Проверяет текущее состояние разрешения без показа диалога (для UI —
  /// например, чтобы показать баннер "включить в настройках", если человек
  /// когда-то отклонил системный диалог).
  Future<bool> hasPermission() async {
    if (kIsWeb) return false;
    if (Platform.isIOS) {
      final settings = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      return settings?.isEnabled ?? false;
    }
    if (Platform.isAndroid) {
      final enabled = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      return enabled ?? false;
    }
    return false;
  }

  /// Детерминированный int id из id цели — 32-битный положительный, т.к.
  /// плагин требует int id, а id цели у нас String (uuid/temp-...).
  int goalNotificationId(String goalId) => goalId.hashCode & 0x7fffffff;

  /// Планирует напоминание о цели за [minutesBefore] минут до её начала
  /// (если не передано — берётся из NotificationPreferences.goalsMinutesBefore).
  /// Если напоминания о целях выключены (мастер-тумблер или тумблер
  /// категории) — вместо планирования тихо отменяет то, что могло быть
  /// запланировано раньше. Если время уже прошло — ничего не планирует
  /// (тихо выходит), чтобы не пытаться запланировать уведомление в
  /// прошлом (плагин на это упадёт с исключением на iOS).
  Future<void> scheduleGoalReminder({
    required String goalId,
    required String title,
    required DateTime startTime,
    String? body,
    int? minutesBefore,
  }) async {
    if (!_initialized) return;

    final prefs = NotificationPreferences.instance;
    await prefs.ensureLoaded();
    if (!prefs.masterEnabled || !prefs.goalsEnabled) {
      await cancelGoalReminder(goalId);
      return;
    }

    final effectiveMinutesBefore = minutesBefore ?? prefs.goalsMinutesBefore;
    final fireAt = startTime.subtract(Duration(minutes: effectiveMinutesBefore));
    final now = DateTime.now();
    if (fireAt.isBefore(now)) return;

    final tzFireAt = tz.TZDateTime.from(fireAt, tz.local);
    final id = goalNotificationId(goalId);

    await _plugin.zonedSchedule(
      id,
      title,
      body ?? 'Начало через $effectiveMinutesBefore мин',
      tzFireAt,
      NotificationDetails(
        iOS: const DarwinNotificationDetails(
          categoryIdentifier: _goalReminderCategoryId,
          interruptionLevel: InterruptionLevel.active,
        ),
        android: const AndroidNotificationDetails(
          'goal_reminders',
          'Напоминания о целях',
          channelDescription: 'Напоминания о запланированных на день целях',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: goalId,
    );
  }

  /// Отменяет запланированное напоминание для конкретной цели. Безопасно
  /// вызывать, даже если для неё ничего не было запланировано (например,
  /// цель была создана в прошлом и напоминание изначально не ставилось).
  Future<void> cancelGoalReminder(String goalId) async {
    if (!_initialized) return;
    await _plugin.cancel(goalNotificationId(goalId));
  }

  /// Полная переустановка напоминания — используется при редактировании
  /// цели (проще отменить и создать заново, чем вычислять дельту).
  Future<void> rescheduleGoalReminder({
    required String goalId,
    required String title,
    required DateTime startTime,
    String? body,
    int? minutesBefore,
  }) async {
    await cancelGoalReminder(goalId);
    await scheduleGoalReminder(
      goalId: goalId,
      title: title,
      startTime: startTime,
      body: body,
      minutesBefore: minutesBefore,
    );
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> pending() async {
    if (!_initialized) return [];
    return _plugin.pendingNotificationRequests();
  }

  // ---------------------------------------------------------------------
  // Вечерняя рефлексия / напоминание про настроение (Phase 2)
  // ---------------------------------------------------------------------
  //
  // В отличие от напоминаний о целях, здесь нет заранее известного момента
  // из данных — условие динамическое ("если запись настроения сегодня ещё
  // не сделана"). Поэтому: id фиксированный (максимум одно такое
  // уведомление активно в любой момент), а модель настроения сама решает,
  // когда звать schedule/cancel — см. интеграцию в mood_model.dart.

  static const int eveningReflectionNotificationId = 900001;

  /// Планирует напоминание на [time] сегодняшнего (или указанного [forDay])
  /// дня. Если [time] не передан — берётся NotificationPreferences.reflectionTime.
  /// Если вечерняя рефлексия выключена в настройках — отменяет вместо
  /// планирования. Если время на сегодня уже прошло — тихо ничего не
  /// делает: не хотим слать напоминание "задним числом" при следующем
  /// открытии приложения тем же вечером после времени напоминания.
  Future<void> scheduleEveningReflection({
    TimeOfDay? time,
    DateTime? forDay,
    String? title,
    String? body,
  }) async {
    if (!_initialized) return;

    final prefs = NotificationPreferences.instance;
    await prefs.ensureLoaded();
    if (!prefs.masterEnabled || !prefs.reflectionEnabled) {
      await cancelEveningReflection();
      return;
    }

    final effectiveTime = time ?? prefs.reflectionTime;
    final day = forDay ?? DateTime.now();
    final fireAt = DateTime(
        day.year, day.month, day.day, effectiveTime.hour, effectiveTime.minute);
    if (fireAt.isBefore(DateTime.now())) return;

    final tzFireAt = tz.TZDateTime.from(fireAt, tz.local);

    await _plugin.zonedSchedule(
      eveningReflectionNotificationId,
      title ?? 'Как прошёл день?',
      body ?? 'Пара секунд — и запись в дневнике настроения готова',
      tzFireAt,
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.active,
        ),
        android: AndroidNotificationDetails(
          'daily_reflection',
          'Вечерняя рефлексия',
          channelDescription: 'Напоминание заполнить настроение за день',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Вызывается сразу после сохранения записи настроения за сегодня —
  /// смысла напоминать о том, что уже сделано, больше нет.
  Future<void> cancelEveningReflection() async {
    if (!_initialized) return;
    await _plugin.cancel(eveningReflectionNotificationId);
  }

  // ---------------------------------------------------------------------
  // Напоминания по привычкам (Phase 2)
  // ---------------------------------------------------------------------
  //
  // Решили не слать отдельное уведомление на каждую привычку (это спамно
  // при 4-5 привычках, все на одно и то же время) — вместо этого один сводный
  // пуш "Осталось невыполненных привычек: N" на единое время для всех.
  // pendingCount пересчитывается снаружи (см. интеграцию в
  // home_launcher_sheet.dart) и передаётся при каждом sync-вызове.

  static const int habitsReminderNotificationId = 900002;

  Future<void> scheduleHabitsReminder({
    TimeOfDay? time,
    required int pendingCount,
    DateTime? forDay,
  }) async {
    if (!_initialized) return;

    final prefs = NotificationPreferences.instance;
    await prefs.ensureLoaded();
    if (!prefs.masterEnabled || !prefs.habitsEnabled) {
      await cancelHabitsReminder();
      return;
    }

    if (pendingCount <= 0) {
      await cancelHabitsReminder();
      return;
    }

    final effectiveTime = time ?? prefs.habitsTime;
    final day = forDay ?? DateTime.now();
    final fireAt = DateTime(
        day.year, day.month, day.day, effectiveTime.hour, effectiveTime.minute);
    if (fireAt.isBefore(DateTime.now())) return;

    final tzFireAt = tz.TZDateTime.from(fireAt, tz.local);
    final body = pendingCount == 1
        ? 'Осталась 1 невыполненная привычка сегодня'
        : 'Осталось невыполненных привычек сегодня: $pendingCount';

    await _plugin.zonedSchedule(
      habitsReminderNotificationId,
      'Не забудь про привычки',
      body,
      tzFireAt,
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.active,
        ),
        android: AndroidNotificationDetails(
          'habits_reminders',
          'Напоминания о привычках',
          channelDescription: 'Сводное напоминание о невыполненных привычках',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelHabitsReminder() async {
    if (!_initialized) return;
    await _plugin.cancel(habitsReminderNotificationId);
  }

  // ---------------------------------------------------------------------
  // Персональные напоминания по привычкам — оставлены на будущее (Phase 3,
  // если решим дать каждой привычке своё время). Пока не используются.
  // ---------------------------------------------------------------------

  int habitNotificationId(String habitId) =>
      'habit-$habitId'.hashCode & 0x7fffffff;

  Future<void> scheduleHabitReminder({
    required String habitId,
    required String title,
    required TimeOfDay time,
    DateTime? forDay,
    String? body,
  }) async {
    if (!_initialized) return;

    final day = forDay ?? DateTime.now();
    final fireAt =
        DateTime(day.year, day.month, day.day, time.hour, time.minute);
    if (fireAt.isBefore(DateTime.now())) return;

    final tzFireAt = tz.TZDateTime.from(fireAt, tz.local);
    final id = habitNotificationId(habitId);

    await _plugin.zonedSchedule(
      id,
      title,
      body ?? 'Не забудь про привычку сегодня',
      tzFireAt,
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.active,
        ),
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Напоминания о привычках',
          channelDescription: 'Напоминания выполнить привычку',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'habit:$habitId',
    );
  }

  Future<void> cancelHabitReminder(String habitId) async {
    if (!_initialized) return;
    await _plugin.cancel(habitNotificationId(habitId));
  }
}