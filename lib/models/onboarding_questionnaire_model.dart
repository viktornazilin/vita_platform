import 'package:flutter/foundation.dart';
import '../models/life_block.dart';
import '../services/user_service.dart';

class OnboardingQuestionnaireModel extends ChangeNotifier {
  final UserService _userService;
  OnboardingQuestionnaireModel({UserService? service})
      : _userService = service ?? UserService();

  final Set<LifeBlock> selectedBlocks = {};
  final List<String> selectedPriorities = [];

  String? age;
  String? health;
  String? goals;
  String? dreams;
  String? strengths;
  String? weaknesses;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorText;
  String? get errorText => _errorText;

  void toggleBlock(LifeBlock block) {
    selectedBlocks.contains(block)
        ? selectedBlocks.remove(block)
        : selectedBlocks.add(block);
    notifyListeners();
  }

  void togglePriority(String priority) {
    selectedPriorities.contains(priority)
        ? selectedPriorities.remove(priority)
        : selectedPriorities.add(priority);
    notifyListeners();
  }

  Future<bool> submit() async {
    final id = _userService.currentUser?['id'];
    if (id == null) return false;

    _isLoading = true;
    _errorText = null;
    notifyListeners();

    try {
      await _userService.updateUserDetails({
        'age': int.tryParse(age ?? ''),
        'health': health ?? '',
        'goals': goals ?? '',
        'dreams': dreams ?? '',
        'strengths': strengths ?? '',
        'weaknesses': weaknesses ?? '',
        'priorities': selectedPriorities,
        'life_blocks': selectedBlocks.map((e) => e.name).toList(),
        'has_completed_questionnaire': true,
      });
      return true;
    } catch (e) {
      _errorText = 'Ошибка при сохранении: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
