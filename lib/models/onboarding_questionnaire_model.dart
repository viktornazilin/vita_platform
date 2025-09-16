import 'package:flutter/foundation.dart';
import '../models/life_block.dart';
import '../services/user_service.dart';

/// Лёгкий, «крючковый» опросник: по одному вопросу на экран.
/// Все ответы сохраняются:
///  - если юзер залогинен — сразу в таблицу users (по колонкам);
///  - если гость — в драфт через UserService.saveGuestOnboardingDraft(...),
///    который перенесёт данные в users после регистрации/логина.
class OnboardingQuestionnaireModel extends ChangeNotifier {
  final UserService _userService;
  OnboardingQuestionnaireModel({UserService? service})
      : _userService = service ?? UserService();

  // --- ДАННЫЕ ---
  final Set<LifeBlock> selectedBlocks = {};
  final Map<String, String> dreamsByBlock = {}; // key = LifeBlock.name
  final Map<String, String> goalsByBlock = {};

  // Компактные метрики
  String? sleep;      // '4-5', '6-7', '8+'
  String? activity;   // 'daily', '3-4w', 'rare', 'none'
  int energy = 5;     // 0..10
  String? stress;     // 'daily', 'sometimes', 'rare', 'never'
  int finance = 3;    // 1..5
  final List<String> selectedPriorities = []; // до 3-х

  // Техсостояние
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorText;
  String? get errorText => _errorText;

  // --- UI helpers ---
  int currentStep = 0; // лимит приходит с экрана

  // ======== Мутаторы ========
  void toggleBlock(LifeBlock block) {
    selectedBlocks.contains(block)
        ? selectedBlocks.remove(block)
        : selectedBlocks.add(block);
    notifyListeners();
    _autosaveDraft(); // мгновенный автосейв при изменении важных полей
  }

  void setSleep(String v) { sleep = v; notifyListeners(); _autosaveDraft(); }
  void setActivity(String v) { activity = v; notifyListeners(); _autosaveDraft(); }
  void setEnergy(double v) { energy = v.round(); notifyListeners(); _autosaveDraft(); }
  void setStress(String v) { stress = v; notifyListeners(); _autosaveDraft(); }
  void setFinance(double v) { finance = v.round(); notifyListeners(); _autosaveDraft(); }

  void togglePriority(String p, {int max = 3}) {
    if (selectedPriorities.contains(p)) {
      selectedPriorities.remove(p);
    } else if (selectedPriorities.length < max) {
      selectedPriorities.add(p);
    }
    notifyListeners();
    _autosaveDraft();
  }

  /// Переход вперёд. [maxIndex] — индекс последнего шага (stepsLen - 1).
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

  void setBlockDream(LifeBlock block, String text) {
    dreamsByBlock[block.name] = text;
    // без лишних notify на каждый символ; автосейв сделаем по таймеру/на кнопке "Далее"
  }

  void setBlockGoal(LifeBlock block, String text) {
    goalsByBlock[block.name] = text;
  }

  // Собираем единый payload, который:
  // - для залогиненного юзера пойдёт в updateUserDetails (по колонкам),
  // - для гостя сохранится в локальный драфт (UserService перенесёт в users после логина).
  Map<String, dynamic> _buildPayload() => {
        'life_blocks': selectedBlocks.map((e) => e.name).toList(),
        'sleep': sleep,
        'activity': activity,
        'energy': energy,
        'stress': stress,
        'finance_satisfaction': finance,
        'priorities': selectedPriorities,
        'dreams_by_block': dreamsByBlock,
        'goals_by_block': goalsByBlock,
      };

  // ======== Submit ========
  Future<bool> submit() async {
    if (_isLoading) return false; // защита от двойного тапа
    _isLoading = true;
    _errorText = null;
    notifyListeners();

    try {
      final id = _userService.currentUser?['id'];
      final payload = {
        ..._buildPayload(),
        'has_completed_questionnaire': true,
      };

      if (id != null) {
        // сохраняем профиль (Supabase: таблица users, отдельные колонки)
        await _userService.updateUserDetails(payload);
        // продублируем флаг локально на всякий
        await _userService.setHasCompletedQuestionnaire(true);
      } else {
        // Гость — фиксируем завершение и сохраним драфт;
        // UserService перенесёт в users при логине/регистрации.
        await _userService.saveGuestOnboardingDraft(
          _buildPayload(),
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

  // ======== Draft (гость) ========
  Future<void> _autosaveDraft() async {
    try {
      // сохраняем текущий прогресс гостя (без отметки completed)
      await _userService.saveGuestOnboardingDraft(_buildPayload());
    } catch (_) {
      // игнорируем ошибки автосейва, чтобы не мешать UX
    }
  }
}
