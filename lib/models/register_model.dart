// models/register_model.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/user_service.dart';

class RegisterModel extends ChangeNotifier {
  final _userService = UserService();

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  // ✅ GDPR / Legal flags
  bool termsAccepted = false; // MUST
  bool analyticsAccepted = false; // optional
  bool marketingAccepted = false; // optional (если нужно)

  void setTerms(bool v) {
    termsAccepted = v;
    notifyListeners();
  }

  void setAnalytics(bool v) {
    analyticsAccepted = v;
    notifyListeners();
  }

  void setMarketing(bool v) {
    marketingAccepted = v;
    notifyListeners();
  }

  String? validateLegal() {
    if (!termsAccepted) return 'Нужно принять Условия использования';
    return null;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    // ✅ Legal gate BEFORE any network calls
    final legalErr = validateLegal();
    if (legalErr != null) {
      _error = legalErr;
      notifyListeners();
      return false;
    }

    if (password != confirmPassword) {
      _error = 'Пароли не совпадают';
      notifyListeners();
      return false;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _userService.register(
        name,
        email,
        password,
        // ✅ передай согласия, чтобы сохранить их как metadata/в профиль (см. UserService ниже)
        analyticsAccepted: analyticsAccepted,
        marketingAccepted: marketingAccepted,
        termsAccepted: termsAccepted,
      );
      _loading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Ошибка регистрации: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
    return false;
  }

  Future<void> registerWithGoogle() async {
    final legalErr = validateLegal();
    if (legalErr != null) {
      _error = legalErr;
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _userService.signInWithGoogle(
        analyticsAccepted: analyticsAccepted,
        marketingAccepted: marketingAccepted,
        termsAccepted: termsAccepted,
      );
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Ошибка Google регистрации: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ✅ NEW: Apple ID
  Future<void> registerWithApple() async {
    final legalErr = validateLegal();
    if (legalErr != null) {
      _error = legalErr;
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _userService.signInWithApple(
        analyticsAccepted: analyticsAccepted,
        marketingAccepted: marketingAccepted,
        termsAccepted: termsAccepted,
      );
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Ошибка Apple ID: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
