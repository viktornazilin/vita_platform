import 'package:hive/hive.dart';
import '../models/app_user.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;

  UserService._internal();

  late Box<AppUser> _box;
  AppUser? _currentUser;

  Future<void> init() async {
    _box = await Hive.openBox<AppUser>('users');
    _currentUser = _box.get('current');
  }

  AppUser? get currentUser => _currentUser;

  bool get hasCompletedQuestionnaire =>
      _currentUser?.hasCompletedQuestionnaire == true;

  Future<void> register(String name, String email, String password) async {
    final newUser = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      password: password,
    );

    _currentUser = newUser;
    await _box.put('current', newUser);
  }

  Future<bool> login(String email, String password) async {
    final user = _box.get('current');
    if (user != null && user.email == email && user.password == password) {
      _currentUser = user;
      return true;
    }
    return false;
  }

  Future<void> saveUser(AppUser user) async {
    _currentUser = user;
    await _box.put('current', user);
  }

  void markQuestionnaireComplete() {
    if (_currentUser != null) {
      _currentUser!.hasCompletedQuestionnaire = true;
      _box.put('current', _currentUser!);
    }
  }
}
