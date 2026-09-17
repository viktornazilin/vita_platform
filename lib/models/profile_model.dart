import 'dart:async';

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

  // Старые пользователи (до введения платной подписки) — бесплатны навсегда.
  // Фактическое решение "пускать/не пускать" принимает AccessGate при
  // старте приложения независимо от этого поля (не полагается на
  // ProfileModel, который может быть ещё не загружен на этом этапе) — тут
  // оно просто для UI (например, скрыть блок управления подпиской в
  // настройках для таких пользователей).
  bool isGrandfathered = false;

  bool hasSeenIntro = false;
  String? archetype;
  String? preferredLanguage; // ru / en / de / ... / null => system

  Map<String, dynamic>? onboarding;

  String? sleep;
  String? activity;
  int? energy;
  String? stress;
  int? financeSatisfaction;

  Map<String, String> dreamsByBlock = {};
  Map<String, String> goalsByBlock = {};
  List<String> priorities = [];
  List<String> lifeBlocks = [];

  double targetHours = 14;
  List<double> weights = [];

  XP? xp;

  String get _uid => _sb.auth.currentUser!.id;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final row = await _sb.from('users').select('*').eq('id', _uid).maybeSingle();

      if (row == null) {
        await _sb.from('users').insert({
          'id': _uid,
          'email': _sb.auth.currentUser?.email,
          'target_hours': 14,
        });

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
      isGrandfathered = (row['is_grandfathered'] as bool?) ?? false;

      hasSeenIntro = (row['has_seen_intro'] as bool?) ?? false;
      archetype = row['archetype'] as String?;
      preferredLanguage = row['preferred_language'] as String?;

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

      priorities = ((row['priorities'] as List?) ?? []).map((e) => '$e').toList();
      lifeBlocks = _normalizeLifeBlocks(row['life_blocks']);

      targetHours = (row['target_hours'] as num?)?.toDouble() ?? 14;
      weights = ((row['weights'] as List?) ?? [])
          .map((e) => (e as num).toDouble())
          .toList();

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

  String _normalizeLifeBlock(String raw) {
    final v = raw.trim().toLowerCase();
    if (v.isEmpty) return '';

    switch (v) {
      case 'general':
      case 'общий':
      case 'общее':
      case 'общие':
      case 'без категории':
        return 'general';

      case 'health':
      case 'здоровье':
      case 'healthcare':
      case 'wellbeing':
      case 'well-being':
      case 'sport':
      case 'спорт':
        return 'health';

      case 'career':
      case 'карьера':
      case 'работа':
      case 'job':
      case 'work':
      case 'business':
      case 'бизнес':
        return 'career';

      case 'family':
      case 'семья':
        return 'family';

      case 'finance':
      case 'finances':
      case 'финансы':
      case 'money':
      case 'financial':
      case 'деньги':
        // Profile UI uses `finance` as the canonical key.
        return 'finance';

      case 'education':
      case 'learning':
      case 'study':
      case 'учеба':
      case 'учёба':
      case 'образование':
      case 'обучение':
        return 'education';

      case 'hobby':
      case 'hobbies':
      case 'хобби':
        return 'hobbies';

      case 'spirituality':
      case 'spirit':
      case 'духовность':
        return 'spirituality';

      case 'relationships':
      case 'relationship':
      case 'relations':
      case 'отношения':
        return 'relationships';

      case 'self':
      case 'selfdevelopment':
      case 'self-development':
      case 'personal':
      case 'personal growth':
      case 'личное':
      case 'саморазвитие':
        return 'self';

      case 'travel':
      case 'traveling':
      case 'путешествия':
        return 'travel';

      case 'home':
      case 'house':
      case 'дом':
        return 'home';

      default:
        return v;
    }
  }

  List<String> _normalizeLifeBlocks(dynamic value) {
    final raw = ((value as List?) ?? const [])
        .map((e) => _normalizeLifeBlock('$e'))
        .where((e) => e.isNotEmpty)
        .toList();

    final seen = <String>{};
    final out = <String>[];

    for (final key in raw) {
      if (seen.add(key)) out.add(key);
    }

    return out;
  }

  Future<void> _loadXp() async {
    try {
      final row = await _sb.from('xp').select('*').eq('user_id', _uid).maybeSingle();

      if (row == null) {
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
      xp ??= XP(userId: _uid, currentXP: 0, level: 1);
    }
  }

  /// Раньше: await update -> await load() (полная перезагрузка профиля) —
  /// каждое изменение (имя, возраст, язык и т.д.) занимало ~секунду видимой
  /// задержки.
  /// Теперь: значения полей меняются локально сразу же, notifyListeners()
  /// вызывается мгновенно, а запрос в Supabase уходит в фоне. Если сервер
  /// вернёт ошибку — значения откатываются к прежним и выставляется `error`.
  Future<String?> savePatch(Map<String, dynamic> patch) async {
    final previous = _applyPatchLocally(patch);
    notifyListeners();

    unawaited(_savePatchOnServer(patch: patch, previous: previous));
    return null;
  }

  Future<void> _savePatchOnServer({
    required Map<String, dynamic> patch,
    required Map<String, dynamic> previous,
  }) async {
    try {
      await _sb.from('users').update(patch).eq('id', _uid);
    } catch (e) {
      _applyPatchLocally(previous);
      error = 'Не удалось сохранить изменения: $e';
      notifyListeners();
    }
  }

  /// Применяет патч к соответствующим локальным полям и возвращает мапу с
  /// прежними значениями (для отката при ошибке).
  Map<String, dynamic> _applyPatchLocally(Map<String, dynamic> patch) {
    final previous = <String, dynamic>{};

    for (final key in patch.keys) {
      switch (key) {
        case 'name':
          previous['name'] = name;
          name = patch['name'] as String?;
          break;
        case 'age':
          previous['age'] = age;
          age = patch['age'] as int?;
          break;
        case 'archetype':
          previous['archetype'] = archetype;
          archetype = patch['archetype'] as String?;
          break;
        case 'has_seen_intro':
          previous['has_seen_intro'] = hasSeenIntro;
          hasSeenIntro = (patch['has_seen_intro'] as bool?) ?? hasSeenIntro;
          break;
        case 'sleep':
          previous['sleep'] = sleep;
          sleep = patch['sleep'] as String?;
          break;
        case 'activity':
          previous['activity'] = activity;
          activity = patch['activity'] as String?;
          break;
        case 'energy':
          previous['energy'] = energy;
          energy = patch['energy'] as int?;
          break;
        case 'stress':
          previous['stress'] = stress;
          stress = patch['stress'] as String?;
          break;
        case 'finance_satisfaction':
          previous['finance_satisfaction'] = financeSatisfaction;
          financeSatisfaction = patch['finance_satisfaction'] as int?;
          break;
        case 'has_completed_questionnaire':
          previous['has_completed_questionnaire'] = hasCompletedQuestionnaire;
          hasCompletedQuestionnaire =
              (patch['has_completed_questionnaire'] as bool?) ??
                  hasCompletedQuestionnaire;
          break;
        case 'life_blocks':
          previous['life_blocks'] = lifeBlocks;
          lifeBlocks = _normalizeLifeBlocks(patch['life_blocks']);
          break;
        case 'priorities':
          previous['priorities'] = priorities;
          priorities = ((patch['priorities'] as List?) ?? [])
              .map((e) => '$e')
              .toList();
          break;
        case 'target_hours':
          previous['target_hours'] = targetHours;
          targetHours = (patch['target_hours'] as num?)?.toDouble() ?? targetHours;
          break;
        case 'preferred_language':
          previous['preferred_language'] = preferredLanguage;
          preferredLanguage = patch['preferred_language'] as String?;
          break;
        case 'dreams_by_block':
          previous['dreams_by_block'] = dreamsByBlock;
          dreamsByBlock = _jsonToStringMap(patch['dreams_by_block']);
          break;
        case 'goals_by_block':
          previous['goals_by_block'] = goalsByBlock;
          goalsByBlock = _jsonToStringMap(patch['goals_by_block']);
          break;
        default:
          // Неизвестный ключ патча — просто отправится на сервер как есть,
          // без локального отражения (нет соответствующего поля в модели).
          break;
      }
    }

    return previous;
  }

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

  Future<String?> setLifeBlocks(List<String> v) => savePatch({'life_blocks': _normalizeLifeBlocks(v)});
  Future<String?> setPriorities(List<String> v) => savePatch({'priorities': v});
  Future<String?> setTargetHours(double v) => savePatch({'target_hours': v});
  Future<String?> setPreferredLanguage(String? v) =>
      savePatch({'preferred_language': v});

  Future<String?> setDreamForBlock(String block, String text) async {
    final next = {...dreamsByBlock}..[block] = text;
    return savePatch({'dreams_by_block': next});
  }

  Future<String?> setGoalForBlock(String block, String text) async {
    final next = {...goalsByBlock}..[block] = text;
    return savePatch({'goals_by_block': next});
  }

  bool deletingAccount = false;

  // Удаление аккаунта — необратимое и критичное действие, поэтому здесь
  // намеренно оставлен блокирующий спиннер (deletingAccount), а не
  // optimistic update: пользователь должен видеть, что операция реально
  // идёт, а не решить, что можно закрыть экран раньше времени.
  Future<String?> deleteAccount() async {
    if (deletingAccount) return null;
    deletingAccount = true;
    notifyListeners();

    try {
      await _sb.rpc('delete_my_account');
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