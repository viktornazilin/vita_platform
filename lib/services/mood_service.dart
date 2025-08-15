import '../models/mood.dart';
import '../main.dart';

class MoodService {
  Future<Mood?> getByDate(DateTime date) => dbRepo.getMoodByDate(date);

  Future<Mood> upsert({
    required DateTime date,
    required String emoji,
    String note = '',
  }) => dbRepo.upsertMood(date: date, emoji: emoji, note: note);

  Future<List<Mood>> fetch({int limit = 30}) => dbRepo.fetchMoods(limit: limit);
}
