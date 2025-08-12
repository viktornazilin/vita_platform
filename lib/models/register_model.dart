import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/user_service.dart';

class RegisterModel extends ChangeNotifier {
  final _userService = UserService();

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      _error = 'Пароли не совпадают';
      notifyListeners();
      return false;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _userService.register(name, email, password);
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
}
