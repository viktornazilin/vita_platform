import '../models/mood.dart';
import '../main.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class MoodService {
  Future<Mood?> getByDate(DateTime date) =>
      dbRepo.getMoodByDate(_dateOnly(date));

  Future<Mood> upsert({
    required DateTime date,
    required String emoji,
    String note = '',
  }) =>
      dbRepo.upsertMood(date: _dateOnly(date), emoji: emoji, note: note);

  Future<void> deleteByDate(DateTime date) =>
      dbRepo.deleteMoodByDate(_dateOnly(date));

  Future<List<Mood>> fetch({int limit = 30}) => dbRepo.fetchMoods(limit: limit);

  /// Для календаря/ленты по периодам
  Future<List<Mood>> fetchRange({
    required DateTime from,
    required DateTime to,
  }) =>
      dbRepo.fetchMoodsRange(
        from: _dateOnly(from),
        to: _dateOnly(to),
      );
}
