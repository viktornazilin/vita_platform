import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  // ⚠️ поменяй на свою схему, если используешь другую (см. AndroidManifest/Info.plist)
  static const String _mobileRedirect = 'vitaplatform://auth-callback';

  // локальные ключи для гостей
  static const _prefSeenIntro = 'vita_seen_intro';
  static const _prefArchetype = 'vita_archetype';

  Map<String, dynamic>? _currentUserData;
  Map<String, dynamic>? get currentUser => _currentUserData;

  // -------- NEW: публичные флаги/геттеры для стартового флоу --------
  bool get hasSeenEpicIntro {
    // если залогинен — читаем из профиля, иначе — опираемся на локальный pref
    final v = _currentUserData?['has_seen_intro'];
    if (v is bool) return v;
    return _cachedSeenIntro ?? false;
  }

  String? get selectedArchetype {
    final v = _currentUserData?['archetype'];
    if (v is String && v.isNotEmpty) return v;
    return _cachedArchetype;
  }

  bool get hasCompletedQuestionnaire =>
      _currentUserData?['has_completed_questionnaire'] == true;

  // локальный кэш для гостей
  bool? _cachedSeenIntro;
  String? _cachedArchetype;

  // ==================== жизненный цикл ====================

  /// Загружает профиль из БД, если есть активный пользователь.
  /// Плюс подтягивает локальные значения (для гостей) и синхронизирует после логина.
  Future<void> init() async {
    await _loadLocalGuestPrefs();

    final user = _client.auth.currentUser;
    if (user != null) {
      await _ensureUserRow(user); // если строки нет — создадим
      _currentUserData = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      // если у гостя были сохранены интро/архетип → синкнем в профиль
      await _syncGuestOnLogin();
      // перезагрузим профиль после синка (если был)
      _currentUserData = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();
    } else {
      _currentUserData = null;
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

    await _syncGuestOnLogin();
    _currentUserData = await _client
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();
  }

  // ==================== аутентификация ====================

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

    // синк гостевых значений в профиль (если были)
    await _syncGuestOnLogin();
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

      await _syncGuestOnLogin();
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
  Future<void> signInWithGoogle() async {
    final redirect = kIsWeb ? null : _mobileRedirect;
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirect,
      queryParams: const {
        'access_type': 'offline',
        'prompt': 'consent',
      },
      // scopes: 'openid profile email https://www.googleapis.com/auth/calendar.readonly',
    );
    // После редиректа слушай onAuthStateChange в UI и дерни init() или refreshCurrentUser().
  }

  /// Выход + очистка кеша.
  Future<void> logout() async {
    await _client.auth.signOut();
    _currentUserData = null;
    // намеренно НЕ очищаем локальные prefs — чтобы гость не потерял выбор архетипа/интро
  }

  // ==================== профиль и атрибуты ====================

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

  // -------- NEW: интро и архетип --------

  /// Отмечаем, что пользователь видел эпичный пролог (гость или юзер).
  Future<void> markEpicIntroSeen() async {
    // сохраним локально
    _cachedSeenIntro = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefSeenIntro, true);

    // если залогинен — апдейтим профиль
    final id = _currentUserData?['id'];
    if (id != null) {
      await _client.from('users').update({'has_seen_intro': true}).eq('id', id);
      _currentUserData = {...?_currentUserData, 'has_seen_intro': true};
    }
  }

  /// Сохраняем выбранный архетип (гость или юзер).
  Future<void> saveArchetype(String key) async {
    _cachedArchetype = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefArchetype, key);

    final id = _currentUserData?['id'];
    if (id != null) {
      await _client.from('users').update({'archetype': key}).eq('id', id);
      _currentUserData = {...?_currentUserData, 'archetype': key};
    }
  }

  // ==================== private helpers ====================

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
      // дефолты для новых колонок
      'has_seen_intro': _cachedSeenIntro ?? false,
      'archetype': _cachedArchetype,
    });
  }

  String? _extractNameFromMetadata(User user) {
    final meta = user.userMetadata ?? {};
    return (meta['full_name'] ?? meta['name'] ?? meta['given_name']) as String?;
  }

  Future<void> _loadLocalGuestPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedSeenIntro = prefs.getBool(_prefSeenIntro) ?? false;
    _cachedArchetype = prefs.getString(_prefArchetype);
  }

  /// Если гость что-то выбрал до логина — переносим в профиль.
  Future<void> _syncGuestOnLogin() async {
    final id = _currentUserData?['id'];
    if (id == null) return;

    final updates = <String, dynamic>{};
    if ((_currentUserData?['has_seen_intro'] != true) && (_cachedSeenIntro == true)) {
      updates['has_seen_intro'] = true;
    }
    if ((_currentUserData?['archetype'] == null || (_currentUserData?['archetype'] as String?)?.isEmpty == true) &&
        (_cachedArchetype != null && _cachedArchetype!.isNotEmpty)) {
      updates['archetype'] = _cachedArchetype;
    }

    if (updates.isNotEmpty) {
      await _client.from('users').update(updates).eq('id', id);
      _currentUserData = {...?_currentUserData, ...updates};
    }
  }
}
