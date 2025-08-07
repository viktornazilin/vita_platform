import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final SupabaseClient _client = Supabase.instance.client;
  Map<String, dynamic>? _currentUserData;

  Map<String, dynamic>? get currentUser => _currentUserData;

  Future<void> init() async {
    final user = _client.auth.currentUser;
    if (user != null) {
      final res = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      _currentUserData = res;
    }
  }

  Future<void> register(String name, String email, String password) async {
    final authRes = await _client.auth.signUp(email: email, password: password);

    if (authRes.user == null) {
      throw Exception('Ошибка при регистрации');
    }

    await _client.from('users').insert({
      'id': authRes.user!.id,
      'email': email,
      'name': name,
      'created_at': DateTime.now().toIso8601String(),
    });

    _currentUserData = {
      'id': authRes.user!.id,
      'email': email,
      'name': name,
    };
  }

  Future<bool> login(String email, String password) async {
    final authRes = await _client.auth
        .signInWithPassword(email: email, password: password);

    if (authRes.user != null) {
      final res = await _client
          .from('users')
          .select()
          .eq('id', authRes.user!.id)
          .maybeSingle();
      _currentUserData = res;
      return true;
    }

    return false;
  }

  Future<void> logout() async {
    await _client.auth.signOut();
    _currentUserData = null;
  }

  bool get hasCompletedQuestionnaire =>
      _currentUserData?['has_completed_questionnaire'] == true;

  Future<void> markQuestionnaireComplete() async {
    final id = _currentUserData?['id'];
    if (id != null) {
      await _client.from('users').update({
        'has_completed_questionnaire': true,
      }).eq('id', id);

      _currentUserData!['has_completed_questionnaire'] = true;
    }
  }

  /// ✅ Добавь этот метод для обновления любых данных пользователя
  Future<void> updateUserDetails(Map<String, dynamic> updates) async {
    final id = _currentUserData?['id'];
    if (id != null) {
      await _client.from('users').update(updates).eq('id', id);
      _currentUserData?.addAll(updates); // Обновляем локально
    }
  }
}
