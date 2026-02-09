import 'package:flutter/foundation.dart';
import '../main.dart'; // для dbRepo

class SettingsModel extends ChangeNotifier {
  Map<String, double> _weights = {};
  double _targetHours = 14;
  bool _loading = true;
  String? _error;

  Map<String, double> get weights => _weights;
  double get targetHours => _targetHours;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadSettings() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final blocks = await dbRepo.getUserLifeBlocks();
      final target = await dbRepo.getTargetHours();

      final Map<String, double> newWeights = {};
      for (var b in blocks) {
        newWeights[b] = await dbRepo.getLifeBlockWeight(b);
      }

      _weights = newWeights;
      _targetHours = target;
    } catch (e) {
      _error = 'Ошибка загрузки: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void updateWeight(String block, double value) {
    _weights[block] = value;
    notifyListeners();
  }

  void updateTargetHours(double value) {
    _targetHours = value;
    notifyListeners();
  }

  Future<bool> saveSettings() async {
    try {
      await dbRepo.saveUserSettings(
        weights: _weights,
        targetHours: _targetHours,
      );
      return true;
    } catch (e) {
      _error = 'Ошибка сохранения: $e';
      notifyListeners();
      return false;
    }
  }
}
