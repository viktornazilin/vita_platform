import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Единое хранилище пользовательских настроек уведомлений.
///
/// Дизайн: NotificationService сам читает эти значения перед планированием
/// (см. изменения там) — значит экран настроек и остальной код (day_goals_model,
/// mood_model, main.dart) НЕ нужно трогать каждый раз, когда добавляется
/// новая настройка. Экран настроек просто дёргает сеттеры здесь, а
/// NotificationService уже сам решает — планировать/отменять/на какое время.
///
/// ChangeNotifier — чтобы экран настроек мог просто послушать инстанс и
/// перерисоваться при изменении (Provider.value или отдельный listener).
class NotificationPreferences extends ChangeNotifier {
  NotificationPreferences._();
  static final NotificationPreferences instance = NotificationPreferences._();

  static const _kMasterEnabled = 'notif_master_enabled';
  static const _kGoalsEnabled = 'notif_goals_enabled';
  static const _kGoalsMinutesBefore = 'notif_goals_minutes_before';
  static const _kReflectionEnabled = 'notif_reflection_enabled';
  static const _kReflectionHour = 'notif_reflection_hour';
  static const _kReflectionMinute = 'notif_reflection_minute';
  static const _kHabitsEnabled = 'notif_habits_enabled';
  static const _kHabitsHour = 'notif_habits_hour';
  static const _kHabitsMinute = 'notif_habits_minute';

  bool _loaded = false;
  bool get loaded => _loaded;

  bool masterEnabled = true;

  bool goalsEnabled = true;
  int goalsMinutesBefore = 15;

  bool reflectionEnabled = true;
  TimeOfDay reflectionTime = const TimeOfDay(hour: 21, minute: 0);

  bool habitsEnabled = true;
  TimeOfDay habitsTime = const TimeOfDay(hour: 20, minute: 0);

  /// Нужно вызвать один раз при старте приложения (main.dart), до того как
  /// что-либо в приложении попытается что-то запланировать — иначе первые
  /// вызовы schedule* в этой же сессии отработают на дефолтных значениях
  /// вместо сохранённых пользовательских.
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      masterEnabled = prefs.getBool(_kMasterEnabled) ?? true;
      goalsEnabled = prefs.getBool(_kGoalsEnabled) ?? true;
      goalsMinutesBefore = prefs.getInt(_kGoalsMinutesBefore) ?? 15;
      reflectionEnabled = prefs.getBool(_kReflectionEnabled) ?? true;
      reflectionTime = TimeOfDay(
        hour: prefs.getInt(_kReflectionHour) ?? 21,
        minute: prefs.getInt(_kReflectionMinute) ?? 0,
      );
      habitsEnabled = prefs.getBool(_kHabitsEnabled) ?? true;
      habitsTime = TimeOfDay(
        hour: prefs.getInt(_kHabitsHour) ?? 20,
        minute: prefs.getInt(_kHabitsMinute) ?? 0,
      );
    } catch (_) {
      // Если SharedPreferences недоступен (например, web в приватном
      // режиме) — остаёмся на дефолтах, объявленных выше как значения полей.
    } finally {
      _loaded = true;
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kMasterEnabled, masterEnabled);
      await prefs.setBool(_kGoalsEnabled, goalsEnabled);
      await prefs.setInt(_kGoalsMinutesBefore, goalsMinutesBefore);
      await prefs.setBool(_kReflectionEnabled, reflectionEnabled);
      await prefs.setInt(_kReflectionHour, reflectionTime.hour);
      await prefs.setInt(_kReflectionMinute, reflectionTime.minute);
      await prefs.setBool(_kHabitsEnabled, habitsEnabled);
      await prefs.setInt(_kHabitsHour, habitsTime.hour);
      await prefs.setInt(_kHabitsMinute, habitsTime.minute);
    } catch (_) {
      // Настройка уже применена в памяти и подействует в рамках текущей
      // сессии — если персист не удался, просто не переживёт перезапуск.
    }
  }

  Future<void> setMasterEnabled(bool value) async {
    masterEnabled = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setGoalsEnabled(bool value) async {
    goalsEnabled = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setGoalsMinutesBefore(int value) async {
    goalsMinutesBefore = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setReflectionEnabled(bool value) async {
    reflectionEnabled = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setReflectionTime(TimeOfDay value) async {
    reflectionTime = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setHabitsEnabled(bool value) async {
    habitsEnabled = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setHabitsTime(TimeOfDay value) async {
    habitsTime = value;
    notifyListeners();
    await _persist();
  }
}