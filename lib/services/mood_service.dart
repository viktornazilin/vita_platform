import 'package:hive/hive.dart';
import '../models/mood.dart';

class MoodService {
  final Box<Mood> _moodBox = Hive.box<Mood>('moods');

  List<Mood> get moods => _moodBox.values.toList();

  void addMood(String emoji, String note) {
    final mood = Mood(
      date: DateTime.now(),
      emoji: emoji,
      note: note,
    );
    _moodBox.add(mood); // сохраняем в Hive
  }
}
