import 'package:flutter/foundation.dart';
import '../models/life_block.dart';
import '../services/user_service.dart';

/// Лёгкий опросник: по одному вопросу на экран.
/// Сохраняем:
///  - если юзер залогинен — в users (по колонкам/джсонам);
///  - если гость — в драфт через UserService.saveGuestOnboardingDraft(...),
///    который перенесёт данные в users после регистрации/логина.
class OnboardingQuestionnaireModel extends ChangeNotifier {
  final UserService _userService;
  OnboardingQuestionnaireModel({UserService? service})
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

  // --- ЦЕЛИ ПО СФЕРАМ (новая структура) ---
  // key = LifeBlock.name
  final Map<String, String> goalsTacticalByBlock = {};
  final Map<String, String> goalsMidByBlock = {};
  final Map<String, String> goalsLongByBlock = {};
  final Map<String, String> whyByBlock = {};

  void setBlockGoalTactical(LifeBlock block, String text) {
    goalsTacticalByBlock[block.name] = text;
    // без notify на каждый символ
  }

  void setBlockGoalMid(LifeBlock block, String text) {
    goalsMidByBlock[block.name] = text;
  }

  void setBlockGoalLong(LifeBlock block, String text) {
    goalsLongByBlock[block.name] = text;
  }

  void setBlockWhy(LifeBlock block, String text) {
    whyByBlock[block.name] = text;
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

  // --- Payload ---
  Map<String, dynamic> _buildPayload() => {
    // профиль
    'name': name,
    'age': age,

    // выбор сфер / приоритеты
    'life_blocks': selectedBlocks.map((e) => e.name).toList(),
    'priorities': selectedPriorities,

    // новая детализация целей
    'goals_tactical_by_block': goalsTacticalByBlock,
    'goals_mid_by_block': goalsMidByBlock,
    'goals_long_by_block': goalsLongByBlock,
    'why_by_block': whyByBlock,
  };

  // --- Submit ---
  Future<bool> submit() async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorText = null;
    notifyListeners();

    try {
      final id = _userService.currentUser?['id'];
      final payload = {..._buildPayload(), 'has_completed_questionnaire': true};

      if (id != null) {
        await _userService.updateUserDetails(payload);
        await _userService.setHasCompletedQuestionnaire(true);
      } else {
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

  // --- Draft (гость) ---
  Future<void> _autosaveDraft() async {
    try {
      await _userService.saveGuestOnboardingDraft(_buildPayload());
    } catch (_) {
      // игнорируем автосейв ошибки
    }
  }
}
