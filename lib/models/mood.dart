import 'package:hive/hive.dart';

part 'mood.g.dart';

@HiveType(typeId: 1)
class Mood extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  String emoji;

  @HiveField(2)
  String note;

  Mood({
    required this.date,
    required this.emoji,
    required this.note,
  });
}
