// models/login_model.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/user_service.dart';

class LoginModel extends ChangeNotifier {
  final UserService _userService;
  LoginModel({UserService? userService})
    : _userService = userService ?? UserService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorText;
  String? get errorText => _errorText;

  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _errorText = 'Пожалуйста, введите email и пароль';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorText = null;
    notifyListeners();

    try {
      final success = await _userService.login(email, password);
      if (!success) {
        _errorText = 'Неверный email или пароль';
        return false;
      }
      return true;
    } on AuthException catch (e) {
      _errorText = e.message;
      return false;
    } catch (e) {
      _errorText = 'Ошибка входа: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ➕ НОВОЕ: вход/регистрация через Google
  Future<void> loginWithGoogle() async {
    _isLoading = true;
    _errorText = null;
    notifyListeners();

    try {
      await _userService.signInWithGoogle();
      // Дальнейшую смену экрана делаем по событию auth state в UI
    } on AuthException catch (e) {
      _errorText = e.message;
    } catch (e) {
      _errorText = 'Ошибка Google входа: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
