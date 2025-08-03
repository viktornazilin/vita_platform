import 'package:hive/hive.dart';
import '../models/goal.dart';

class GoalService {
  final Box<Goal> _goalBox = Hive.box<Goal>('goals');

  List<Goal> get goals => _goalBox.values.toList();

  void addGoal(Goal goal) {
    _goalBox.put(goal.id, goal); // сохраняем цель с уникальным ID
  }

  void toggleGoal(String id) {
    final goal = _goalBox.get(id);
    if (goal != null) {
      goal.isCompleted = !goal.isCompleted;
      goal.save(); // обновляем сохранённый объект
    }
  }

  void deleteGoal(String id) {
    _goalBox.delete(id);
  }
}
