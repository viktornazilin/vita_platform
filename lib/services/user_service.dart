import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  // ⚠️ поменяй на свою схему, если используешь другую (см. AndroidManifest/Info.plist)
  static const String _mobileRedirect = 'vitaplatform://auth-callback';

  Map<String, dynamic>? _currentUserData;
  Map<String, dynamic>? get currentUser => _currentUserData;

  /// Загружает профиль из БД, если есть активный пользователь.
  Future<void> init() async {
    final user = _client.auth.currentUser;
    if (user != null) {
      await _ensureUserRow(user); // если строки нет — создадим
      _currentUserData = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();
    } else {
      _currentUserData = null;
    }
  }

  /// Регистрация по email/паролю + создание строки в таблице users.
  Future<void> register(String name, String email, String password) async {
    final authRes = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );
    if (authRes.user == null) {
      throw Exception('Ошибка при регистрации');
    }

    await _upsertUserRow(
      id: authRes.user!.id,
      email: email,
      name: name,
    );

    _currentUserData = await _client
        .from('users')
        .select()
        .eq('id', authRes.user!.id)
        .maybeSingle();
  }

  /// Вход по email/паролю + загрузка профиля.
  Future<bool> login(String email, String password) async {
    final authRes = await _client.auth
        .signInWithPassword(email: email, password: password);

    if (authRes.user != null) {
      await _ensureUserRow(authRes.user!);
      _currentUserData = await _client
          .from('users')
          .select()
          .eq('id', authRes.user!.id)
          .maybeSingle();
      return true;
    }
    return false;
  }

  /// ✅ Вход/регистрация через Google OAuth (универсальный поток).
  /// На мобильных вернет в приложение по deep link, сессию поднимет Supabase.
  Future<void> signInWithGoogle() async {
    final redirect = kIsWeb ? null : _mobileRedirect;
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirect,
      queryParams: const {
        'access_type': 'offline', // refresh token
        'prompt': 'consent',
      },
      // Если позже нужен календарь — добавь scope:
      // scopes: 'openid profile email https://www.googleapis.com/auth/calendar.readonly',
    );
    // После редиректа слушай onAuthStateChange в UI и дерни init() или refreshCurrentUser().
  }

  /// Выход + очистка кеша.
  Future<void> logout() async {
    await _client.auth.signOut();
    _currentUserData = null;
  }

  bool get hasCompletedQuestionnaire =>
      _currentUserData?['has_completed_questionnaire'] == true;

  Future<void> markQuestionnaireComplete() async {
    final id = _currentUserData?['id'];
    if (id != null) {
      await _client
          .from('users')
          .update({'has_completed_questionnaire': true}).eq('id', id);
      _currentUserData!['has_completed_questionnaire'] = true;
    }
  }

  /// Обновление произвольных полей профиля.
  Future<void> updateUserDetails(Map<String, dynamic> updates) async {
    final id = _currentUserData?['id'];
    if (id != null) {
      await _client.from('users').update(updates).eq('id', id);
      _currentUserData = {...?_currentUserData, ...updates};
    }
  }

  /// 🔄 Вызови после события signedIn, чтобы подтянуть профиль.
  Future<void> refreshCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      _currentUserData = null;
      return;
    }
    await _ensureUserRow(user);
    _currentUserData = await _client
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();
  }

  // -------------------- private helpers --------------------

  /// Гарантирует, что строка в public.users существует для auth.users.
  Future<void> _ensureUserRow(User user) async {
    final existing = await _client
        .from('users')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    if (existing == null) {
      await _upsertUserRow(
        id: user.id,
        email: user.email,
        name: _extractNameFromMetadata(user),
      );
    }
  }

  Future<void> _upsertUserRow({
    required String id,
    String? email,
    String? name,
  }) async {
    await _client.from('users').upsert({
      'id': id,
      'email': email,
      'name': name,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  String? _extractNameFromMetadata(User user) {
    // Supabase кладёт в rawUserMetaData поля от провайдера (Google: full_name/name/picture)
    final meta = user.userMetadata ?? {};
    return (meta['full_name'] ?? meta['name'] ?? meta['given_name']) as String?;
  }
}
