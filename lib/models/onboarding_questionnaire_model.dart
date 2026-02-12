import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/life_block.dart';
import '../services/user_service.dart';

// ✅ для записи целей в user_goals
import '../services/core/base_repo.dart';
import '../services/user_goals_repo_mixin.dart'; // UserGoalUpsert, GoalHorizon

/// Лёгкий опросник: по одному вопросу на экран.
/// Сохраняем:
///  - профиль/сферы/приоритеты — в users (или draft для гостя)
///  - цели — в user_goals (только если юзер залогинен)
class OnboardingQuestionnaireModel extends ChangeNotifier {
  final UserService _userService;

  /// ✅ репозиторий, который умеет upsertGoals (dbRepo)
  final BaseRepo goalsRepo;

  OnboardingQuestionnaireModel({UserService? service, required this.goalsRepo})
    : _userService = service ?? UserService();

  // --- ПРОФИЛЬ ---
  String? name;
  int? age;

  void setName(String? v) {
    name = (v?.trim().isEmpty ?? true) ? null : v!.trim();
    notifyListeners();
    _autosaveDraft();
  }

  void setAge(int? v) {
    age = v;
    notifyListeners();
    _autosaveDraft();
  }

  // --- СФЕРЫ ЖИЗНИ ---
  final Set<LifeBlock> selectedBlocks = {};

  void toggleBlock(LifeBlock block) {
    selectedBlocks.contains(block)
        ? selectedBlocks.remove(block)
        : selectedBlocks.add(block);
    notifyListeners();
    _autosaveDraft();
  }

  // --- ПРИОРИТЕТЫ (до 3-х) ---
  final List<String> selectedPriorities = [];

  void togglePriority(String p, {int max = 3}) {
    if (selectedPriorities.contains(p)) {
      selectedPriorities.remove(p);
    } else if (selectedPriorities.length < max) {
      selectedPriorities.add(p);
    }
    notifyListeners();
    _autosaveDraft();
  }

  // --- ЦЕЛИ ПО СФЕРАМ (локально в модели, но НЕ в users) ---
  // key = LifeBlock.name
  final Map<String, String> goalsTacticalByBlock = {};
  final Map<String, String> goalsMidByBlock = {};
  final Map<String, String> goalsLongByBlock = {};
  final Map<String, String> whyByBlock = {};

  Timer? _goalsDebounce;

  void _debouncedGoalsAutosave() {
    // ✅ не пишем цели в draft/users — только держим в памяти до submit
    // здесь делаем только notify (если нужно) и debounce, чтобы UI не лагал
    _goalsDebounce?.cancel();
    _goalsDebounce = Timer(const Duration(milliseconds: 300), () {
      // ничего не делаем: цели сохраняются только при submit() в user_goals
      // (для гостя — цели не сохраняем, иначе они "утекут" в users после логина)
    });
  }

  void setBlockGoalTactical(LifeBlock block, String text) {
    goalsTacticalByBlock[block.name] = text;
    _debouncedGoalsAutosave();
  }

  void setBlockGoalMid(LifeBlock block, String text) {
    goalsMidByBlock[block.name] = text;
    _debouncedGoalsAutosave();
  }

  void setBlockGoalLong(LifeBlock block, String text) {
    goalsLongByBlock[block.name] = text;
    _debouncedGoalsAutosave();
  }

  void setBlockWhy(LifeBlock block, String text) {
    whyByBlock[block.name] = text;
    _debouncedGoalsAutosave();
  }

  // --- UI helpers ---
  int currentStep = 0;

  void nextStep({required int maxIndex}) {
    if (currentStep < maxIndex) {
      currentStep++;
      notifyListeners();
    }
    _autosaveDraft();
  }

  void prevStep() {
    if (currentStep > 0) {
      currentStep--;
      notifyListeners();
    }
  }

  // --- Техсостояние ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorText;
  String? get errorText => _errorText;

  // ---------------------------------------------------------------------------
  // ✅ Payload для USERS (без целей!)
  // ---------------------------------------------------------------------------
  Map<String, dynamic> _buildUsersPayload() => {
    'name': name,
    'age': age,
    'life_blocks': selectedBlocks.map((e) => e.name).toList(),
    'priorities': selectedPriorities,
  };

  // ---------------------------------------------------------------------------
  // ✅ Build goals upserts for user_goals
  // ---------------------------------------------------------------------------
  List<UserGoalUpsert> _buildGoalsUpserts() {
    final out = <UserGoalUpsert>[];

    String normTitle(String raw) {
      final t = raw.trim();
      if (t.isEmpty) return '';
      final firstLine = t.split('\n').first.trim();
      if (firstLine.isEmpty) return '';
      return firstLine.length > 80 ? firstLine.substring(0, 80) : firstLine;
    }

    String? buildDesc(String blockName) {
      final why = (whyByBlock[blockName] ?? '').trim();
      if (why.isEmpty) return null;
      return 'Почему: $why';
    }

    void addGoal(String blockName, String raw, GoalHorizon h) {
      final title = normTitle(raw);
      if (title.isEmpty) return;

      out.add(
        UserGoalUpsert(
          id: null,
          lifeBlock: blockName,
          horizon: h,
          title: title,
          description: buildDesc(blockName) ?? '',
          targetDate: null,
        ),
      );
    }

    for (final b in selectedBlocks) {
      final key = b.name;

      addGoal(key, goalsTacticalByBlock[key] ?? '', GoalHorizon.tactical);
      addGoal(key, goalsMidByBlock[key] ?? '', GoalHorizon.mid);
      addGoal(key, goalsLongByBlock[key] ?? '', GoalHorizon.long);
    }

    return out;
  }

  // --- Submit ---
  Future<bool> submit() async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorText = null;
    notifyListeners();

    try {
      final id = _userService.currentUser?['id'];

      // 1) ✅ сохраняем USERS (без целей)
      final usersPayload = {
        ..._buildUsersPayload(),
        'has_completed_questionnaire': true,
      };

      if (id != null) {
        await _userService.updateUserDetails(usersPayload);
        await _userService.setHasCompletedQuestionnaire(true);

        // 2) ✅ сохраняем GOALS в user_goals (как GoalsByBlockCard)
        final goals = _buildGoalsUpserts();
        if (goals.isNotEmpty) {
          await (goalsRepo as dynamic).upsertGoals(goals);
        }
      } else {
        // гость — сохраняем только users draft (без целей)
        await _userService.saveGuestOnboardingDraft(
          _buildUsersPayload(),
          completed: true,
        );
      }

      return true;
    } catch (e) {
      _errorText = 'Ошибка при сохранении: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Draft (гость) ---
  Future<void> _autosaveDraft() async {
    try {
      // ✅ только профиль/сферы/приоритеты
      await _userService.saveGuestOnboardingDraft(_buildUsersPayload());
    } catch (_) {
      // игнорируем автосейв ошибки
    }
  }

  @override
  void dispose() {
    _goalsDebounce?.cancel();
    super.dispose();
  }
}
