import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  // 'ru' | 'en' | 'de' | 'fr' | 'es' | 'tr' | 'system'
  static const _prefKey = 'vita_locale';

  Locale? _locale; // null = system
  Locale? get locale => _locale;

  bool _ready = false;
  bool get isReady => _ready;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_prefKey) ?? 'system';

    _locale = _decode(v);
    _ready = true;
    notifyListeners();
  }

  Future<void> setSystem() async => setLocale(null);

  /// ✅ принимает Locale? (null => system)
  Future<void> setLocale(Locale? locale) async {
    // null => system
    if (locale == null) {
      _locale = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, 'system');
      return;
    }

    // сохраняем только язык
    _locale = Locale(locale.languageCode);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _locale!.languageCode);
  }

  String get currentCode => _locale?.languageCode ?? 'system';

  Locale? _decode(String v) {
    switch (v) {
      case 'system':
        return null;
      case 'ru':
      case 'en':
      case 'de':
      case 'fr':
      case 'es':
      case 'tr':
        return Locale(v);
      default:
        return null;
    }
  }
}
