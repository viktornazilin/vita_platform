import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 0)
class Goal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime deadline;

  @HiveField(4)
  bool isCompleted;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    this.isCompleted = false,
  });
}
