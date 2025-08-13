import '../main.dart';
import '../models/goal.dart';

class GoalService {
  // ---- Life blocks
  Future<List<String>> getUserLifeBlocks() {
    return dbRepo.getUserLifeBlocks();
  }

  // ---- Goals (общие)
  Future<List<Goal>> fetchGoals({String? lifeBlock}) {
    return dbRepo.fetchGoals(lifeBlock: lifeBlock);
  }

  // Цели на конкретную дату (lifeBlock необязателен: null => все блоки)
  Future<List<Goal>> getGoalsByDate(DateTime date, {String? lifeBlock}) async {
    final all = await dbRepo.getGoalsByDate(date);
    if (lifeBlock == null) return all;
    return all.where((g) => g.lifeBlock == lifeBlock).toList();
  }

  /// Создать новую цель (с учетом времени начала)
  Future<Goal> createGoal({
    required String title,
    String description = '',
    required DateTime deadline,
    required String lifeBlock,
    int importance = 1,
    String emotion = '',
    double spentHours = 1.0,
    required DateTime startTime, // <-- добавили
  }) async {
    final created = await dbRepo.createGoal(
      title: title,
      description: description,
      deadline: deadline,
      lifeBlock: lifeBlock,
      importance: importance,
      emotion: emotion,
      spentHours: spentHours,
      startTime: startTime, // <-- передаем в БД
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

  // Отметить выполнение (ставим true)
  Future<void> completeGoal(String id) {
    return dbRepo.toggleGoalCompleted(id, value: true);
  }

  // Тоггл (если нужен из UI)
  Future<void> toggleCompleted(String id, {bool? value}) {
    return dbRepo.toggleGoalCompleted(id, value: value);
  }

  // ---- Aggregates / settings
  Future<double> getTotalHoursSpentOnDate(DateTime date) {
    return dbRepo.getTotalHoursSpentOnDate(date);
  }

  Future<double> getTargetHours() {
    return dbRepo.getTargetHours();
  }

  Future<void> updateGoal(Goal goal) async {
    await dbRepo.updateGoal(goal);
  }
}
