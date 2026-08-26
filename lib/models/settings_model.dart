import 'dart:async';

import 'package:flutter/foundation.dart';
import '../main.dart'; // для dbRepo

class SettingsModel extends ChangeNotifier {
  Map<String, double> _weights = {};
  double _targetHours = 14;
  bool _loading = true;
  String? _error;

  /// true, пока фоновое сохранение ещё не подтверждено сервером — можно
  /// использовать для маленького ненавязчивого индикатора ("Сохранение…"),
  /// не блокируя при этом сам экран/кнопку.
  bool saving = false;

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

  /// Раньше: экран/кнопка "Сохранить" ждали await saveSettings() перед тем,
  /// как продолжить (например, закрыть экран) — видимая задержка.
  /// Теперь: возвращаемся сразу (значения уже применены локально через
  /// updateWeight/updateTargetHours), а запись в БД уходит в фоне. Если
  /// сохранение не удастся — `error` обновится и экран (если ещё открыт)
  /// сможет показать это ненавязчиво.
  Future<bool> saveSettings() async {
    final weightsSnapshot = Map<String, double>.from(_weights);
    final targetHoursSnapshot = _targetHours;

    saving = true;
    notifyListeners();

    unawaited(_saveSettingsOnServer(
      weights: weightsSnapshot,
      targetHours: targetHoursSnapshot,
    ));

    return true;
  }

  Future<void> _saveSettingsOnServer({
    required Map<String, double> weights,
    required double targetHours,
  }) async {
    try {
      await dbRepo.saveUserSettings(
        weights: weights,
        targetHours: targetHours,
      );
    } catch (e) {
      _error = 'Ошибка сохранения: $e';
    } finally {
      saving = false;
      notifyListeners();
    }
  }
}