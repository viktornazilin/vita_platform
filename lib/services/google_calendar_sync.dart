// lib/services/google_calendar_sync.dart

import '../models/goal.dart';
import 'google_calendar_service.dart';

class CalendarSyncResult {
  final int created;
  final int updated;
  final int skipped;
  final int failed;

  const CalendarSyncResult({
    this.created = 0,
    this.updated = 0,
    this.skipped = 0,
    this.failed = 0,
  });

  int get total => created + updated + skipped + failed;

  CalendarSyncResult copyWith({
    int? created,
    int? updated,
    int? skipped,
    int? failed,
  }) {
    return CalendarSyncResult(
      created: created ?? this.created,
      updated: updated ?? this.updated,
      skipped: skipped ?? this.skipped,
      failed: failed ?? this.failed,
    );
  }

  @override
  String toString() =>
      'created=$created, updated=$updated, skipped=$skipped, failed=$failed';
}

class GoogleCalendarSync {
  final GoogleCalendarService service;

  GoogleCalendarSync({required this.service});

  /// Пока MVP: просто заглушка, чтобы UI работал.
  /// Здесь позже будет:
  /// - получить goals из репозитория
  /// - создать/обновить события в Google Calendar
  Future<CalendarSyncResult> syncAllGoalsToCalendar({
    required List<Goal> goals,
  }) async {
    int created = 0;
    int updated = 0;
    int skipped = 0;
    int failed = 0;

    for (final g in goals) {
      try {
        // TODO: реальная логика маппинга goal -> event и upsert в Google
        // Например:
        // await service.upsertEventFromGoal(g);
        skipped++;
      } catch (_) {
        failed++;
      }
    }

    return CalendarSyncResult(
      created: created,
      updated: updated,
      skipped: skipped,
      failed: failed,
    );
  }
}
