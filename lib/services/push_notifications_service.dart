import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Единая точка входа для FCM (Firebase Cloud Messaging) push-уведомлений.
///
/// Отличие от NotificationService (локальные уведомления): здесь
/// приложение НЕ решает само, когда показать уведомление — сервер
/// (Supabase Edge Function) отправляет push в конкретный момент события
/// (кто-то назначил задачу, завершил общую цель и т.д.), и iOS показывает
/// его через APNs, даже если приложение полностью закрыто.
///
/// Разрешение на уведомления в iOS общее для локальных и push — если
/// пользователь уже разрешил через NotificationService (soft-ask),
/// FirebaseMessaging.requestPermission() здесь просто подтвердит то же
/// самое состояние и зарегистрирует устройство для получения remote push.
class PushNotificationsService {
  PushNotificationsService._();
  static final PushNotificationsService instance = PushNotificationsService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Вызывается при получении/обновлении device-токена — main.dart подключит
  /// сюда сохранение токена в Supabase (привязка к user_id).
  void Function(String token)? onTokenReady;

  /// Вызывается, когда пользователь тапнул по push и открыл приложение
  /// (как из фона, так и из полностью закрытого состояния через
  /// getInitialMessage).
  void Function(RemoteMessage message)? onMessageOpened;

  StreamSubscription<String>? _tokenSub;

  Future<void> init({
    void Function(String token)? onTokenReady,
    void Function(RemoteMessage message)? onMessageOpened,
  }) async {
    this.onTokenReady = onTokenReady;
    this.onMessageOpened = onMessageOpened;

    // На web FCM работает совсем иначе (нужен VAPID-ключ, service worker) и
    // сюда не входит — веб-push у нас уже отдельно через WebNotificationsService.
    if (kIsWeb) return;

    // Показывать push баннером, даже если приложение в этот момент открыто
    // (foreground) — без этого iOS по умолчанию просто молчит, пока
    // приложение активно.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onMessageOpened?.call(message);
    });

    // Если приложение было полностью закрыто и открылось по тапу на push.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      onMessageOpened?.call(initialMessage);
    }

    await _refreshToken();
    _tokenSub?.cancel();
    _tokenSub = _messaging.onTokenRefresh.listen((token) {
      onTokenReady?.call(token);
    });
  }

  /// Запрашивает системное разрешение (общее с локальными уведомлениями —
  /// если уже разрешено через NotificationService, здесь просто вернёт тот
  /// же granted-статус) и после этого пытается получить/обновить токен.
  Future<bool> requestPermissionAndRegister() async {
    if (kIsWeb) return false;

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

    if (granted) {
      await _refreshToken();
    }
    return granted;
  }

  Future<void> _refreshToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        onTokenReady?.call(token);
      }
    } catch (e) {
      debugPrint('PushNotificationsService: failed to get FCM token: $e');
    }
  }

  Future<void> deleteToken() async {
    if (kIsWeb) return;
    try {
      await _messaging.deleteToken();
    } catch (_) {
      // Не критично — токен в БД останется, следующий getToken() при
      // следующем запуске перезапишет его актуальным.
    }
  }
}

/// Top-level функция — обязательное требование firebase_messaging для
/// обработки push, пришедшего пока приложение в фоне/закрыто (выполняется
/// в отдельном изоляте, поэтому не может быть методом класса/замыканием).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Сейчас ничего не делаем — iOS сам показывает push из системного APNs
  // payload (alert/badge/sound), доставленного пока приложение не активно.
  // Сюда можно будет добавить, например, тихую синхронизацию локального
  // состояния (silent push), если понадобится в будущем.
}
