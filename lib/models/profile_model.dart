import 'package:flutter/foundation.dart';
import '../models/xp.dart';
import '../services/db_repo.dart';

class ProfileModel extends ChangeNotifier {
  final DbRepo repo;
  ProfileModel({required this.repo});

  XP? _xp;
  XP? get xp => _xp;

  Map<String, dynamic>? _questionnaire;
  Map<String, dynamic>? get questionnaire => _questionnaire;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  bool get questionnaireCompleted =>
      (_questionnaire?['has_completed_questionnaire'] == true);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final xpData = await repo.getXP();
      final q = await repo.getQuestionnaireResults();
      _xp = xpData;
      _questionnaire = q;
    } catch (e) {
      _error = 'Ошибка загрузки: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
