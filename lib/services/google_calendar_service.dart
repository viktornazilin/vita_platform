// lib/services/google_calendar_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:http/http.dart' as http;

class GoogleCalendarService {
  GoogleCalendarService({GoogleSignIn? signIn})
    : _signIn =
          signIn ??
          GoogleSignIn(
            // ВАЖНО: для Web нужен clientId
            clientId: kIsWeb ? _webClientId : null,
            scopes: <String>[
              gcal.CalendarApi.calendarEventsScope,
              // если хочешь читать список календарей:
              gcal.CalendarApi.calendarReadonlyScope,
            ],
          );

  static const String _webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );

  final GoogleSignIn _signIn;

  bool get isConnected => _signIn.currentUser != null;
  GoogleSignInAccount? get currentUser => _signIn.currentUser;

  Future<void> connect() async {
    if (kIsWeb && _webClientId.isEmpty) {
      throw Exception(
        'GOOGLE_WEB_CLIENT_ID пуст. Запусти flutter с '
        '--dart-define=GOOGLE_WEB_CLIENT_ID=... (Web OAuth Client ID)',
      );
    }

    // 1) Получаем пользователя (silent -> interactive)
    GoogleSignInAccount? user = _signIn.currentUser;
    user ??= await _signIn.signInSilently();
    user ??= await _signIn.signIn();
    if (user == null) {
      throw Exception('Google sign-in cancelled');
    }

    // 2) ЯВНО запрашиваем нужные scopes (на Web без этого часто нет accessToken)
    final ok = await _signIn.requestScopes(<String>[
      gcal.CalendarApi.calendarEventsScope,
      gcal.CalendarApi.calendarReadonlyScope,
    ]);

    if (!ok) {
      // Пользователь не дал доступ к календарю
      throw Exception('Calendar permission not granted (scopes rejected).');
    }

    // 3) Пытаемся получить токен
    var auth = await user.authentication;
    if (auth.accessToken != null && auth.accessToken!.isNotEmpty) return;

    // 4) Если accessToken всё ещё null — форсим новый consent
    // (обычно значит, что раньше вход был без нужных scope и Google не перевыдал токен)
    await _signIn.disconnect();
    user = await _signIn.signIn();
    if (user == null) {
      throw Exception('Google sign-in cancelled');
    }

    // scopes ещё раз (после disconnect)
    final ok2 = await _signIn.requestScopes(<String>[
      gcal.CalendarApi.calendarEventsScope,
      gcal.CalendarApi.calendarReadonlyScope,
    ]);
    if (!ok2) {
      throw Exception('Calendar permission not granted (scopes rejected).');
    }

    auth = await user.authentication;
    if (auth.accessToken == null || auth.accessToken!.isEmpty) {
      throw Exception('No accessToken. Проверь scopes и GOOGLE_WEB_CLIENT_ID.');
    }
  }

  Future<void> signOut({bool revokeAccess = true}) async {
    await _signIn.signOut();
    if (revokeAccess) {
      await _signIn.disconnect();
    }
  }

  Future<gcal.CalendarApi> _api() async {
    await connect();
    final user = _signIn.currentUser!;
    final authInfo = await user.authentication;

    final headers = <String, String>{
      'Authorization': 'Bearer ${authInfo.accessToken}',
      'X-Goog-AuthUser': '0',
    };

    return gcal.CalendarApi(_GoogleAuthClient(headers));
  }

  Future<List<gcal.CalendarListEntry>> listCalendars() async {
    final api = await _api();
    final res = await api.calendarList.list();
    return res.items ?? <gcal.CalendarListEntry>[];
  }

  Future<List<gcal.Event>> listEvents({
    required String calendarId,
    required DateTime timeMin,
    required DateTime timeMax,
  }) async {
    final api = await _api();
    final resp = await api.events.list(
      calendarId,
      timeMin: timeMin,
      timeMax: timeMax,
      singleEvents: true,
      orderBy: 'startTime',
    );
    return resp.items ?? <gcal.Event>[];
  }

  Future<String> upsertGoalAsEvent({
    required String calendarId,
    required String title,
    required String description,
    required DateTime start,
    required DateTime end,
    String? eventId,
    String? timeZone,
  }) async {
    return upsertEvent(
      calendarId: calendarId,
      summary: title,
      description: description,
      start: start,
      end: end,
      timeZone: timeZone,
      eventId: eventId,
    );
  }

  /// Создаёт событие (если eventId == null) или обновляет (если eventId задан).
  Future<String> upsertEvent({
    required String calendarId,
    required String summary,
    String? description,
    DateTime? start,
    DateTime? end,
    String? timeZone,
    String? eventId,
    String? location,
    List<String> extendedPrivateTags = const [],
  }) async {
    final api = await _api();

    final event = gcal.Event()
      ..summary = summary
      ..description = description
      ..location = location
      ..start = (start == null)
          ? null
          : (gcal.EventDateTime()
              ..dateTime = start
              ..timeZone = timeZone)
      ..end = (end == null)
          ? null
          : (gcal.EventDateTime()
              ..dateTime = end
              ..timeZone = timeZone)
      ..extendedProperties = (extendedPrivateTags.isEmpty)
          ? null
          : (gcal.EventExtendedProperties()
              ..private = {'nest_tags': extendedPrivateTags.join(',')});

    if (eventId == null || eventId.isEmpty) {
      final created = await api.events.insert(event, calendarId);
      return created.id ?? '';
    } else {
      final updated = await api.events.patch(event, calendarId, eventId);
      return updated.id ?? eventId;
    }
  }

  Future<void> deleteEvent({
    required String calendarId,
    required String eventId,
  }) async {
    final api = await _api();
    await api.events.delete(calendarId, eventId);
  }
}

class _GoogleAuthClient extends http.BaseClient {
  _GoogleAuthClient(this._headers);
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
