import 'package:hive/hive.dart';

part 'xp.g.dart';

@HiveType(typeId: 2)
class XP extends HiveObject {
  @HiveField(0)
  int currentXP;

  @HiveField(1)
  int level;

  XP({this.currentXP = 0, this.level = 1});

  void addXP(int points) {
    currentXP += points;
    while (currentXP >= xpToLevelUp()) {
      currentXP -= xpToLevelUp();
      level++;
    }
  }

  int xpToLevelUp() {
    return 100 + (level - 1) * 25;
  }

  double progressPercent() {
    return currentXP / xpToLevelUp();
  }
}
