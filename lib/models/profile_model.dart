import 'package:flutter/foundation.dart';
import '../models/xp.dart';
import '../services/db_repo.dart';

class ProfileModel extends ChangeNotifier {
  final DbRepo repo;
  ProfileModel({required this.repo});

  // XP
  XP? _xp;
  XP? get xp => _xp;

  // Сырая строка users (может быть null)
  Map<String, dynamic>? _questionnaire;
  Map<String, dynamic>? get questionnaire => _questionnaire;

  // UI
  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  // Новые поля
  bool questionnaireCompleted = false;

  String? sleep;               // '4-5' | '6-7' | '8+'
  String? activity;            // 'daily' | '3-4w' | 'rare' | 'none'
  int?    energy;              // 0..10
  String? stress;              // 'daily' | 'sometimes' | 'rare' | 'never'
  int?    financeSatisfaction; // 1..5

  List<String> priorities = <String>[];
  List<String> lifeBlocks = <String>[];

  Map<String, String> dreamsByBlock = <String, String>{};
  Map<String, String> goalsByBlock  = <String, String>{};

  String? archetype;
  bool hasSeenIntro = false;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // XP как раньше
      _xp = await repo.getXP();

      // Строка пользователя из users (может вернуться null)
      final row = await repo.getQuestionnaireResults(); // Map<String, dynamic>?
      _questionnaire = row;
      final Map<String, dynamic> data = row ?? const <String, dynamic>{};

      questionnaireCompleted = data['has_completed_questionnaire'] == true;

      sleep    = data['sleep'] as String?;
      activity = data['activity'] as String?;
      energy   = (data['energy'] as num?)?.toInt();
      stress   = data['stress'] as String?;
      financeSatisfaction = (data['finance_satisfaction'] as num?)?.toInt();

      priorities = _toStringList(data['priorities']);
      lifeBlocks = _toStringList(data['life_blocks']);

      dreamsByBlock = _toStringMap(data['dreams_by_block']);
      goalsByBlock  = _toStringMap(data['goals_by_block']);

      archetype    = data['archetype'] as String?;
      hasSeenIntro = data['has_seen_intro'] == true;

    } catch (e) {
      _error = 'Ошибка загрузки: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  List<String> _toStringList(dynamic v) {
    if (v is List) {
      return v.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    }
    return <String>[];
    }

  Map<String, String> _toStringMap(dynamic v) {
    if (v is Map) {
      return v.map((k, val) => MapEntry(k.toString(), val?.toString() ?? ''));
    }
    return <String, String>{};
  }
}
