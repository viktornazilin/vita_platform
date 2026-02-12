import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'xp.dart';

class ProfileModel extends ChangeNotifier {
  ProfileModel({required this.repo});
  final dynamic repo;

  final _sb = Supabase.instance.client;

  bool loading = false;
  String? error;

  // === columns from public.users ===
  String? email;
  String? name;
  DateTime? createdAt;

  bool hasCompletedQuestionnaire = false;
  int? age;

  bool hasSeenIntro = false;
  String? archetype;

  Map<String, dynamic>? onboarding;

  String? sleep; // '4-5'|'6-7'|'8+'
  String? activity; // 'daily'|'3-4w'|'rare'|'none'
  int? energy; // 0..10
  String? stress; // 'daily'|'sometimes'|'rare'|'never'
  int? financeSatisfaction; // 1..5

  Map<String, String> dreamsByBlock = {};
  Map<String, String> goalsByBlock = {};
  List<String> priorities = [];
  List<String> lifeBlocks = [];

  double targetHours = 14;
  List<double> weights = [];

  // ✅ FIX: XP теперь объект, как ожидает XPProgressBar
  XP? xp;

  String get _uid => _sb.auth.currentUser!.id;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final row = await _sb
          .from('users')
          .select('*')
          .eq('id', _uid)
          .maybeSingle();

      if (row == null) {
        // на случай если триггер не создал строку
        await _sb.from('users').insert({
          'id': _uid,
          'email': _sb.auth.currentUser?.email,
        });

        // дефолтный XP, чтобы UI не падал
        xp = XP(userId: _uid, currentXP: 0, level: 1);

        loading = false;
        notifyListeners();
        return;
      }

      email = row['email'] as String?;
      name = row['name'] as String?;
      createdAt = row['created_at'] is String
          ? DateTime.tryParse(row['created_at'])
          : row['created_at'];

      hasCompletedQuestionnaire =
          (row['has_completed_questionnaire'] as bool?) ?? false;
      age = row['age'] as int?;

      hasSeenIntro = (row['has_seen_intro'] as bool?) ?? false;
      archetype = row['archetype'] as String?;

      onboarding = (row['onboarding'] is Map)
          ? (row['onboarding'] as Map).cast<String, dynamic>()
          : null;

      sleep = row['sleep'] as String?;
      activity = row['activity'] as String?;
      energy = row['energy'] as int?;
      stress = row['stress'] as String?;
      financeSatisfaction = row['finance_satisfaction'] as int?;

      dreamsByBlock = _jsonToStringMap(row['dreams_by_block']);
      goalsByBlock = _jsonToStringMap(row['goals_by_block']);

      priorities = ((row['priorities'] as List?) ?? [])
          .map((e) => '$e')
          .toList();
      lifeBlocks = ((row['life_blocks'] as List?) ?? [])
          .map((e) => '$e')
          .toList();

      targetHours = (row['target_hours'] as num?)?.toDouble() ?? 14;
      weights = ((row['weights'] as List?) ?? [])
          .map((e) => (e as num).toDouble())
          .toList();

      // ✅ Load XP (из отдельной таблицы или репо)
      await _loadXp();
    } catch (e) {
      error = 'Не удалось загрузить профиль: $e';
    }

    loading = false;
    notifyListeners();
  }

  Map<String, String> _jsonToStringMap(dynamic v) {
    if (v is Map) {
      return v.map((k, val) => MapEntry('$k', val == null ? '' : '$val'));
    }
    return {};
  }

  /// ✅ Подстрой под твою БД.
  /// Если у тебя таблица называется иначе — поменяй 'xp' и поля.
  Future<void> _loadXp() async {
    try {
      // Вариант 1: если есть таблица public.xp с колонками user_id, current_xp, level
      final row = await _sb
          .from('xp')
          .select('*')
          .eq('user_id', _uid)
          .maybeSingle();

      if (row == null) {
        // создаём запись, чтобы потом апдейтить без проблем
        await _sb.from('xp').insert({
          'user_id': _uid,
          'current_xp': 0,
          'level': 1,
        });
        xp = XP(userId: _uid, currentXP: 0, level: 1);
      } else {
        xp = XP.fromMap((row as Map).cast<String, dynamic>());
      }
    } catch (_) {
      // если таблицы нет/не настроено — просто не ломаем UI
      xp ??= XP(userId: _uid, currentXP: 0, level: 1);
    }
  }

  Future<String?> savePatch(Map<String, dynamic> patch) async {
    try {
      await _sb.from('users').update(patch).eq('id', _uid);
      await load();
      return null;
    } catch (e) {
      return 'Не удалось сохранить изменения: $e';
    }
  }

  // ===== editable setters =====
  Future<String?> setName(String? v) => savePatch({'name': v});
  Future<String?> setAge(int? v) => savePatch({'age': v});

  Future<String?> setArchetype(String? v) => savePatch({'archetype': v});
  Future<String?> setHasSeenIntro(bool v) => savePatch({'has_seen_intro': v});

  Future<String?> setSleep(String? v) =>
      savePatch({'sleep': v, 'has_completed_questionnaire': true});
  Future<String?> setActivity(String? v) =>
      savePatch({'activity': v, 'has_completed_questionnaire': true});
  Future<String?> setEnergy(int? v) =>
      savePatch({'energy': v, 'has_completed_questionnaire': true});
  Future<String?> setStress(String? v) =>
      savePatch({'stress': v, 'has_completed_questionnaire': true});
  Future<String?> setFinance(int? v) => savePatch({
    'finance_satisfaction': v,
    'has_completed_questionnaire': true,
  });

  Future<String?> setLifeBlocks(List<String> v) =>
      savePatch({'life_blocks': v});
  Future<String?> setPriorities(List<String> v) => savePatch({'priorities': v});

  Future<String?> setTargetHours(double v) => savePatch({'target_hours': v});

  Future<String?> setDreamForBlock(String block, String text) async {
    final next = {...dreamsByBlock}..[block] = text;
    return savePatch({'dreams_by_block': next});
  }

  Future<String?> setGoalForBlock(String block, String text) async {
    final next = {...goalsByBlock}..[block] = text;
    return savePatch({'goals_by_block': next});
  }

  // =========================
  // ✅ Delete account (Supabase RPC)
  // Требует SQL-функцию public.delete_my_account()
  // =========================
  bool deletingAccount = false;

  Future<String?> deleteAccount() async {
    if (deletingAccount) return null;
    deletingAccount = true;
    notifyListeners();

    try {
      // 1) удаляем ВСЕ данные + auth.users через RPC
      await _sb.rpc('delete_my_account');

      // 2) на всякий случай выходим из сессии локально
      try {
        await _sb.auth.signOut();
      } catch (_) {}

      return null;
    } catch (e) {
      return 'Не удалось удалить аккаунт: $e';
    } finally {
      deletingAccount = false;
      notifyListeners();
    }
  }
}
