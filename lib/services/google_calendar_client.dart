import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleCalendarClient {
  GoogleCalendarClient({http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final http.Client _http;

  static const _base = 'https://www.googleapis.com/calendar/v3';

  Future<Map<String, dynamic>> insertEvent({
    required String accessToken,
    String calendarId = 'primary',
    required Map<String, dynamic> event,
  }) async {
    final uri = Uri.parse('$_base/calendars/$calendarId/events');
    final res = await _http.post(
      uri,
      headers: _headers(accessToken),
      body: jsonEncode(event),
    );
    _ensureOk(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> patchEvent({
    required String accessToken,
    String calendarId = 'primary',
    required String eventId,
    required Map<String, dynamic> patch,
  }) async {
    final uri = Uri.parse('$_base/calendars/$calendarId/events/$eventId');
    final res = await _http.patch(
      uri,
      headers: _headers(accessToken),
      body: jsonEncode(patch),
    );
    _ensureOk(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> deleteEvent({
    required String accessToken,
    String calendarId = 'primary',
    required String eventId,
  }) async {
    final uri = Uri.parse('$_base/calendars/$calendarId/events/$eventId');
    final res = await _http.delete(uri, headers: _headers(accessToken));
    if (res.statusCode == 404) return; // уже удалено
    _ensureOk(res);
  }

  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json; charset=utf-8',
  };

  void _ensureOk(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw Exception('Google Calendar API error ${res.statusCode}: ${res.body}');
  }
}
