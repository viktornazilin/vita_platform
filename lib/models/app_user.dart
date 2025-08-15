import 'package:hive/hive.dart';
import 'life_block.dart'; // добавь, если используешь LifeBlock

@HiveType(typeId: 4)
class AppUser extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String email;

  @HiveField(2)
  String password;

  @HiveField(3)
  String? name;

  @HiveField(4)
  int? age;

  @HiveField(5)
  String? health;

  @HiveField(6)
  String? goals;

  @HiveField(7)
  String? dreams;

  @HiveField(8)
  String? strengths;

  @HiveField(9)
  String? weaknesses;

  @HiveField(10)
  List<String>? priorities;

  @HiveField(11)
  List<LifeBlock>? lifeBlocks;

  @HiveField(12)
  bool hasCompletedQuestionnaire;

  AppUser({
    required this.id,
    required this.email,
    required this.password,
    this.name,
    this.age,
    this.health,
    this.goals,
    this.dreams,
    this.strengths,
    this.weaknesses,
    this.priorities,
    this.lifeBlocks,
    this.hasCompletedQuestionnaire = false,
  });
}

