import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'secrets.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'services/db_repo.dart';
import 'services/notification_service.dart';
import 'services/notification_preferences.dart';
import 'services/push_notifications_service.dart';
import 'controllers/theme_controller.dart';
import 'controllers/locale_controller.dart';

// ✅ Web notifications (работают в браузере, пока приложение открыто)
import 'services/web_notifications_service.dart';

// Делаем репозиторий доступным по всему приложению
late final DbRepo dbRepo;

// ✅ глобальный сервис web-уведомлений (можно использовать в Settings и т.д.)
late final WebNotificationsService webNotifs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  dbRepo = DbRepo(Supabase.instance.client);

  // ✅ init web notifications (без запроса permission — его лучше делать по кнопке в UI)
  webNotifs = WebNotificationsService();
  await webNotifs.init();

  // ✅ init iOS/Android local notifications (тоже без запроса permission —
  // системный диалог показываем позже, через soft-ask экран в UI).
  // Регистрируем обработчик тапов по уведомлению/быстрым действиям здесь,
  // на верхнем уровне, т.к. dbRepo уже доступен глобально и не требует
  // контекста виджета — событие может прийти даже когда приложение было
  // полностью закрыто.
  await NotificationService.instance.init(
    onNotificationTap: _handleNotificationTap,
  );

  // Настройки уведомлений (мастер-тумблер, категории, время) должны быть
  // загружены ДО первого вызова resyncAllReminders() ниже — иначе первая
  // синхронизация в этой сессии отработает на дефолтах вместо сохранённых
  // пользовательских значений.
  await NotificationPreferences.instance.ensureLoaded();

  // Firebase — только ради push (FCM). На web currentPlatform кидает
  // UnsupportedError (flutterfire configure ещё не настроен под web),
  // поэтому просто пропускаем инициализацию там — push для space-активности
  // на web пока не входит в scope, есть только web-уведомления через
  // WebNotificationsService отдельно.
  if (!kIsWeb) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await PushNotificationsService.instance.init(
      onTokenReady: _handlePushTokenReady,
      onMessageOpened: _handlePushMessageOpened,
    );
  }

  // Проактивная синхронизация всех трёх типов напоминаний при каждом
  // старте приложения — не полагаемся на то, что пользователь в этот день
  // обязательно откроет экран целей/настроения/привычек, где сработала бы
  // реактивная синхронизация. Не блокируем запуск — не awaited.
  unawaited(resyncAllReminders());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()..load()),
        ChangeNotifierProvider(create: (_) => LocaleController()..init()),
      ],
      child: const VitaApp(),
    ),
  );
}

/// Обрабатывает нажатие на уведомление о цели или на одно из его быстрых
/// действий ("Готово" / "Отложить на 15 мин"). payload — это goal.id,
/// который мы передаём при планировании в NotificationService.
///
/// Пишем напрямую через dbRepo, а не через DayGoalsModel — на этом этапе
/// нет гарантии, что экран цели вообще смонтирован (уведомление могло
/// прилететь, когда приложение свёрнуто или закрыто). Когда пользователь
/// в следующий раз откроет экран целей, DayGoalsModel.load() подтянет
/// актуальное состояние с сервера как обычно.
void _handleNotificationTap(NotificationResponse response) {
  final goalId = response.payload;
  if (goalId == null || goalId.isEmpty) return;

  switch (response.actionId) {
    case NotificationService.actionMarkDone:
      dbRepo.toggleGoalCompleted(goalId, value: true);
      NotificationService.instance.cancelGoalReminder(goalId);
      break;
    case NotificationService.actionSnooze15:
      // Просто отменяем текущее и не планируем ничего нового прямо тут —
      // полноценный snooze (запланировать заново на +15 мин) добавим на
      // шаге с быстрыми действиями (Фаза 3 плана), когда будет откуда
      // взять title/startTime без похода в БД.
      NotificationService.instance.cancelGoalReminder(goalId);
      break;
    default:
      // Обычный тап по уведомлению (не по кнопке действия) — открыть
      // экран дня добавим, когда подключим deep link/навигацию из
      // корня приложения (нужен GlobalKey<NavigatorState> в app.dart).
      break;
  }
}

/// Вызывается при получении/обновлении FCM device-токена. Сохраняем его в
/// Supabase, привязанным к текущему user_id — именно на этот токен сервер
/// потом будет слать push через Firebase Cloud Messaging.
void _handlePushTokenReady(String token) {
  final uid = Supabase.instance.client.auth.currentUser?.id;
  if (uid == null) return;
  unawaited(dbRepo.savePushToken(token: token));
}

/// Вызывается, когда пользователь тапнул по push-уведомлению (активность в
/// пространстве, еженедельная сводка и т.д.) и это открыло/переключило
/// приложение на передний план.
///
/// TODO: реальная навигация на нужный экран (например, сразу в цель или в
/// пространство) добавится вместе с deep link-инфраструктурой — то же
/// ограничение, что и в _handleNotificationTap выше.
void _handlePushMessageOpened(RemoteMessage message) {
  debugPrint('Push opened: ${message.data}');
}

/// Пересчитывает, сколько привычек ещё не выполнено на [day], и
/// планирует/отменяет сводное напоминание по привычкам соответственно.
/// Общая функция для трёх точек вызова:
/// - main() при каждом старте приложения (проактивно);
/// - home_launcher_sheet.dart сразу после сохранения (реактивно);
/// - экран настроек уведомлений, когда пользователь снова включает
///   категорию "Привычки" после того, как выключил её.
Future<void> syncHabitsReminder(DateTime day) async {
  try {
    final habits = await dbRepo.listHabits();
    if (habits.isEmpty) {
      await NotificationService.instance.cancelHabitsReminder();
      return;
    }

    final dayOnly = DateTime(day.year, day.month, day.day);
    final entriesByHabitId = await dbRepo.getHabitEntriesForDay(dayOnly);
    final pending = habits.where((h) {
      final e = entriesByHabitId[h.id];
      final done = (e?['done'] as bool?) ?? false;
      return !done;
    }).length;

    // time не передаём — NotificationService сам возьмёт его из
    // NotificationPreferences (и там же проверит, включена ли категория).
    await NotificationService.instance.scheduleHabitsReminder(
      pendingCount: pending,
      forDay: dayOnly,
    );
  } catch (_) {
    // Тихо игнорируем — это ненавязчивая фоновая синхронизация напоминания,
    // а не критичная операция; при следующем удобном случае (открытие
    // приложения или сохранение привычек) попробуем снова.
  }
}

/// Пересчитывает и (пере)планирует напоминания по всем целям на [day] —
/// используется вместо DayGoalsModel.load(), когда живой экземпляр модели
/// сейчас не смонтирован (например, вызов из экрана настроек или при
/// старте приложения).
Future<void> syncGoalReminders(DateTime day) async {
  try {
    final dayUtc = DateTime.utc(day.year, day.month, day.day);
    final goals = await dbRepo.getGoalsByDate(
      dayUtc,
      lifeBlock: null,
      spaceId: null,
      personalOnly: false,
    );
    for (final g in goals) {
      if (g.isCompleted) {
        await NotificationService.instance.cancelGoalReminder(g.id);
      } else {
        await NotificationService.instance.scheduleGoalReminder(
          goalId: g.id,
          title: g.title,
          startTime: g.startTime,
        );
      }
    }
  } catch (_) {
    // См. комментарий в syncHabitsReminder — та же логика терпимости.
  }
}

/// Проверяет, есть ли запись настроения за сегодня, и планирует/отменяет
/// вечернюю рефлексию — standalone-версия того, что MoodModel.load() уже
/// делает сама, для случаев без живого экземпляра модели под рукой.
Future<void> syncEveningReflectionReminder() async {
  try {
    final moods = await dbRepo.fetchMoods(limit: 1);
    final today = DateTime.now();
    final hasToday = moods.any((m) =>
        m.date.year == today.year &&
        m.date.month == today.month &&
        m.date.day == today.day);

    if (hasToday) {
      await NotificationService.instance.cancelEveningReflection();
    } else {
      await NotificationService.instance.scheduleEveningReflection();
    }
  } catch (_) {
    // См. комментарий в syncHabitsReminder — та же логика терпимости.
  }
}

/// Пересинхронизирует все три типа напоминаний сразу. Используется при
/// старте приложения и в экране настроек уведомлений — когда пользователь
/// заново включает мастер-тумблер (или конкретную категорию) после того,
/// как выключил его, нужно сразу же запланировать актуальное состояние, а
/// не ждать, пока он сам откроет экран целей/настроения/привычек.
Future<void> resyncAllReminders() async {
  await Future.wait([
    syncGoalReminders(DateTime.now()),
    syncEveningReflectionReminder(),
    syncHabitsReminder(DateTime.now()),
  ]);
}