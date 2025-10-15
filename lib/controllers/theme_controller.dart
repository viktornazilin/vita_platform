import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _kSeedKey = 'app_seed_color';
  static const _kModeKey = 'app_theme_mode';

  Color _seed = const Color(0xFF6750A4); // дефолтный seed
  ThemeMode _mode = ThemeMode.system;

  Color get seedColor => _seed;
  ThemeMode get mode => _mode;

  ThemeData get lightTheme =>
      ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light));
  ThemeData get darkTheme =>
      ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark));

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final hex = sp.getInt(_kSeedKey);
    if (hex != null) _seed = Color(hex);
    final modeIndex = sp.getInt(_kModeKey);
    if (modeIndex != null && modeIndex >= 0 && modeIndex <= 2) {
      _mode = ThemeMode.values[modeIndex];
    }
    notifyListeners();
  }

  Future<void> setSeedColor(Color c) async {
    _seed = c;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kSeedKey, c.value);
  }

  Future<void> setMode(ThemeMode m) async {
    _mode = m;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kModeKey, m.index);
  }
}
