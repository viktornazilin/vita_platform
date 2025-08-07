import '../main.dart';
import '../models/goal.dart';

class GoalService {
  // ---- Life blocks
  Future<List<String>> getUserLifeBlocks() {
  return dbRepo.getUserLifeBlocks();
}


  // ---- Goals
  Future<List<Goal>> fetchGoals({String? lifeBlock}) {
    return dbRepo.fetchGoals(lifeBlock: lifeBlock);
  }

  Future<Goal> createGoal({
    required String title,
    String description = '',
    required DateTime deadline,
    required String lifeBlock,
    int importance = 1,
    String emotion = '',
    double spentHours = 1.0,
  }) async {
    final created = await dbRepo.createGoal(
      title: title,
      description: description,
      deadline: deadline,
      lifeBlock: lifeBlock,
      importance: importance,
      emotion: emotion,
      spentHours: spentHours,
    );

    // XP: постановка задачи
    await dbRepo.addXP(5);

    // Бонус за дневную норму часов
    final totalHours = await dbRepo.getTotalHoursSpentOnDate(DateTime.now());
    final targetHours = await dbRepo.getTargetHours();
    if (totalHours >= targetHours) {
      await dbRepo.addXP(20);
    }

    return created;
  }

  Future<void> deleteGoal(String id) {
    return dbRepo.deleteGoal(id);
  }

  // Отметить выполнение (вдруг понадобится из UI)
  Future<void> toggleCompleted(String id, {bool? value}) {
    return dbRepo.toggleGoalCompleted(id, value: value);
  }

  // ---- Aggregates / settings (пробрасываем к репозиторию)
  Future<double> getTotalHoursSpentOnDate(DateTime date) {
    return dbRepo.getTotalHoursSpentOnDate(date);
  }

  Future<double> getTargetHours() {
    return dbRepo.getTargetHours();
  }
}
