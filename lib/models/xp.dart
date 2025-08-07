class XP {
  final String userId;
  final int currentXP;
  final int level;

  XP({
    required this.userId,
    this.currentXP = 0,
    this.level = 1,
  });

  factory XP.fromMap(Map<String, dynamic> map) => XP(
        userId: map['user_id'] as String,
        currentXP: (map['current_xp'] ?? 0) as int,
        level: (map['level'] ?? 1) as int,
      );

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'current_xp': currentXP,
        'level': level,
      };

  int xpToLevelUp() => 100 + (level - 1) * 25;

  double progressPercent() => currentXP / xpToLevelUp();

  XP addXP(int points) {
    var newXP = currentXP + points;
    var newLevel = level;
    while (newXP >= (100 + (newLevel - 1) * 25)) {
      newXP -= (100 + (newLevel - 1) * 25);
      newLevel++;
    }
    return XP(userId: userId, currentXP: newXP, level: newLevel);
  }
}
