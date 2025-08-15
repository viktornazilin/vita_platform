import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/life_block.dart';
import '../services/user_service.dart';

/// Лёгкий, «крючковый» опросник: по одному вопросу на экран.
/// Ключевое требование — сохранить выбранные сферы (life_blocks).
class OnboardingQuestionnaireModel extends ChangeNotifier {
  final UserService _userService;
  OnboardingQuestionnaireModel({UserService? service})
    : _userService = service ?? UserService();

  // --- ОБЯЗАТЕЛЬНО ОСТАЁТСЯ ---
  final Set<LifeBlock> selectedBlocks = {};
  final Map<String, String> dreamsByBlock = {}; // key = LifeBlock.name
  final Map<String, String> goalsByBlock = {};
  // --- Новые компактные метрики ---
  // Сон (часы, «коридоры»)
  String? sleep; // '4-5', '6-7', '8+'
  // Активность
  String? activity; // 'daily', '3-4w', 'rare', 'none'
  // Энергия сегодня (0..10)
  int energy = 5;
  // Стресс (частота)
  String? stress; // 'daily', 'sometimes', 'rare', 'never'
  // Удовлетворенность финансами (1..5)
  int finance = 3;
  // Приоритеты на 3-6 мес (до 3 шт.)
  final List<String> selectedPriorities = [];

  // Техсостояние
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorText;
  String? get errorText => _errorText;

  // --- Локальные ключи для гостей ---
  static const _prefsKey = 'vita_onboarding_draft';
  static const _prefsCompletedKey = 'vita_onboarding_completed';

  // --- UI helpers ---
  int currentStep = 0;
  static const int totalSteps = 7; // 1 блок + 5 метрик + приоритеты

  // ======== Мутаторы ========
  void toggleBlock(LifeBlock block) {
    selectedBlocks.contains(block)
        ? selectedBlocks.remove(block)
        : selectedBlocks.add(block);
    notifyListeners();
  }

  void setSleep(String v) {
    sleep = v;
    notifyListeners();
  }

  void setActivity(String v) {
    activity = v;
    notifyListeners();
  }

  void setEnergy(double v) {
    energy = v.round();
    notifyListeners();
  }

  void setStress(String v) {
    stress = v;
    notifyListeners();
  }

  void setFinance(double v) {
    finance = v.round();
    notifyListeners();
  }

  void togglePriority(String p, {int max = 3}) {
    if (selectedPriorities.contains(p)) {
      selectedPriorities.remove(p);
    } else {
      if (selectedPriorities.length < max) {
        selectedPriorities.add(p);
      }
    }
    notifyListeners();
  }

  void nextStep() {
    if (currentStep < totalSteps - 1) {
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

  void setBlockDream(LifeBlock block, String text) {
    dreamsByBlock[block.name] = text;
    // notify не обязателен на каждый символ
  }

  void setBlockGoal(LifeBlock block, String text) {
    goalsByBlock[block.name] = text;
  }

  // ======== Submit ========
  Future<bool> submit() async {
    _isLoading = true;
    _errorText = null;
    notifyListeners();

    try {
      final id = _userService.currentUser?['id'];

      final payload = <String, dynamic>{
        // жизненно важно: сферы
        'life_blocks': selectedBlocks.map((e) => e.name).toList(),
        // компактные метрики
        'sleep': sleep,
        'activity': activity,
        'energy': energy,
        'stress': stress,
        'finance_satisfaction': finance,
        'priorities': selectedPriorities,
        // отметим прохождние онбординга
        'has_completed_questionnaire': true,
        'dreams_by_block': dreamsByBlock,
        'goals_by_block': goalsByBlock,
        'has_completed_questionnaire': true,
      };

      if (id != null) {
        // сразу в профиль (Supabase)
        await _userService.updateUserDetails(payload);
      } else {
        // Гость — сохраняем локально, чтобы потом синкнуть после логина
        await _saveDraftAsCompleted();
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

  // ======== Draft (гость) ========
  Future<void> _autosaveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = {
        'life_blocks': selectedBlocks.map((e) => e.name).toList(),
        'sleep': sleep,
        'activity': activity,
        'energy': energy,
        'stress': stress,
        'finance_satisfaction': finance,
        'priorities': selectedPriorities,
      };
      await prefs.setString(
        _prefsKey,
        map.toString(),
      ); // компактно; при желании — jsonEncode
    } catch (_) {
      /* игнор */
    }
  }

  Future<void> _saveDraftAsCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsCompletedKey, true);
      await _autosaveDraft();
    } catch (_) {
      /* игнор */
    }
  }
}
