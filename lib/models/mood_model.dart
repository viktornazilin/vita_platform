import 'package:flutter/foundation.dart';
import '../models/mood.dart';
import '../services/db_repo.dart';

class MoodModel extends ChangeNotifier {
  final DbRepo repo; // инжектим репозиторий (Supabase/DB)
  MoodModel({required this.repo});

  final List<Mood> _moods = [];
  List<Mood> get moods => List.unmodifiable(_moods);

  bool _loading = false;
  bool get loading => _loading;

  Future<void> load({int limit = 30}) async {
    _loading = true;
    notifyListeners();
    try {
      final items = await repo.fetchMoods(limit: limit);
      _moods
        ..clear()
        ..addAll(items);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Возвращает `null`, если ок. Иначе текст ошибки.
  Future<String?> saveMood({
    required String emoji,
    required String note,
  }) async {
    try {
      await repo.upsertMood(date: DateTime.now(), emoji: emoji, note: note);
      await load(); // как и раньше — перезапрашиваем список
      return null;
    } catch (e) {
      return 'Не удалось сохранить настроение: $e';
    }
  }
}
