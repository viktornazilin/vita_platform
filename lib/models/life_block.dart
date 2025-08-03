import 'package:hive/hive.dart';

part 'life_block.g.dart';

@HiveType(typeId: 5)
enum LifeBlock {
  @HiveField(0)
  health,

  @HiveField(1)
  career,

  @HiveField(2)
  family,

  @HiveField(3)
  finances,

  @HiveField(4)
  education,

  @HiveField(5)
  hobbies,

  @HiveField(6)
  spirituality,

  @HiveField(7)
  relationships,
}

String getBlockLabel(LifeBlock block) {
  switch (block) {
    case LifeBlock.health:
      return "Здоровье";
    case LifeBlock.career:
      return "Карьера";
    case LifeBlock.family:
      return "Семья";
    case LifeBlock.finances:
      return "Финансы";
    case LifeBlock.education:
      return "Образование";
    case LifeBlock.hobbies:
      return "Хобби";
    case LifeBlock.spirituality:
      return "Духовность";
    case LifeBlock.relationships:
      return "Отношения";
  }
}
