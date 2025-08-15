import '../main.dart';
import '../models/goal.dart';

class GoalService {
  // dbRepo уже инициализирован в main.dart
  // Если хотите DI — принимайте DbRepo в конструкторе.

  Future<List<String>> getUserLifeBlocks() => dbRepo.getUserLifeBlocks();

  Future<List<Goal>> fetchGoals({String? lifeBlock}) =>
      dbRepo.fetchGoals(lifeBlock: lifeBlock);

  Future<List<Goal>> getGoalsByDate(DateTime date, {String? lifeBlock}) async {
    final all = await dbRepo.getGoalsByDate(date);
    return lifeBlock == null ? all : all.where((g) => g.lifeBlock == lifeBlock).toList();
  }

  Future<Goal> createGoal({
    required String title,
    String description = '',
    required DateTime deadline,
    required String lifeBlock,
    int importance = 1,
    String emotion = '',
    double spentHours = 1.0,
    required DateTime startTime,
  }) async {
    final created = await dbRepo.createGoal(
      title: title,
      description: description,
      deadline: deadline,
      lifeBlock: lifeBlock,
      importance: importance,
      emotion: emotion,
      spentHours: spentHours,
      startTime: startTime,
    );

    // оркестрация XP — оставляем тут
    await dbRepo.addXP(5);
    final totalHours = await dbRepo.getTotalHoursSpentOnDate(DateTime.now());
    final targetHours = await dbRepo.getTargetHours();
    if (totalHours >= targetHours) {
      await dbRepo.addXP(20);
    }
    return created;
  }

  Future<void> deleteGoal(String id) => dbRepo.deleteGoal(id);

  Future<void> completeGoal(String id) =>
      dbRepo.toggleGoalCompleted(id, value: true);

  Future<void> toggleCompleted(String id, {bool? value}) =>
      dbRepo.toggleGoalCompleted(id, value: value);

  Future<double> getTotalHoursSpentOnDate(DateTime date) =>
      dbRepo.getTotalHoursSpentOnDate(date);

  Future<double> getTargetHours() => dbRepo.getTargetHours();

  Future<void> updateGoal(Goal goal) => dbRepo.updateGoal(goal);
}
