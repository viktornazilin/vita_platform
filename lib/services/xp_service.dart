import '../main.dart';

class XPService {
  int xp = 0;

  Future<void> addXPForGoalCreated({required String lifeBlock}) async {
    final weight = await dbRepo.getLifeBlockWeight(lifeBlock);
    final points = 10 * weight; // за постановку задачи
    await dbRepo.addXP(points.toInt());
  }

  Future<void> addXPForGoalCompleted({
    required String lifeBlock,
    required double hoursSpent,
  }) async {
    final weight = await dbRepo.getLifeBlockWeight(lifeBlock);
    final points = (20 * weight + hoursSpent).toInt();
    await dbRepo.addXP(points);
  }

  Future<void> checkDailyHoursAndBonus(DateTime date) async {
    final targetHours = await dbRepo.getTargetHours();
    final totalHours = await dbRepo.getTotalHoursSpentOnDate(date);

    if (totalHours >= targetHours) {
      await dbRepo.addXP(50); // бонус
    }
  }
}
