import 'dart:convert'; // NEW
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  static const String _mobileRedirect = 'vitaplatform://auth-callback';

  // локальные ключи для гостей
  static const _prefSeenIntro = 'vita_seen_intro';
  static const _prefArchetype = 'vita_archetype';
  static const _prefOnboardingCompleted = 'vita_onboarding_completed';
  static const _prefOnboardingDraft = 'vita_onboarding_draft_json'; // NEW

  Map<String, dynamic>? _currentUserData;
  Map<String, dynamic>? get currentUser => _currentUserData;

  // -------- флаги/геттеры для стартового флоу --------
  bool get hasSeenEpicIntro {
    final v = _currentUserData?['has_seen_intro'];
    if (v is bool) return v;
    return _cachedSeenIntro ?? false;
  }

  String? get selectedArchetype {
    final v = _currentUserData?['archetype'];
    if (v is String && v.isNotEmpty) return v;
    return _cachedArchetype;
  }

  bool get hasCompletedQuestionnaire {
    final v = _currentUserData?['has_completed_questionnaire'];
    if (v == true) return true;
    return _cachedOnboardingCompleted ?? false;
  }

  // локальный кэш для гостей
  bool? _cachedSeenIntro;
  String? _cachedArchetype;
  bool? _cachedOnboardingCompleted;
  Map<String, dynamic>? _cachedOnboardingDraft; // NEW

  // ==================== жизненный цикл ====================

  Future<void> init() async {
    await _loadLocalGuestPrefs();

    final user = _client.auth.currentUser;
    if (user != null) {
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

  Future<void> register(String name, String email, String password) async {
    final authRes = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );
    if (authRes.user == null) {
      throw Exception('Ошибка при регистрации');
    }

    await _upsertUserRow(id: authRes.user!.id, email: email, name: name);

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
  }

  Future<bool> login(String email, String password) async {
    final authRes = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

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
      queryParams: const {'access_type': 'offline', 'prompt': 'consent'},
    );
    // После редиректа слушай onAuthStateChange в UI и дерни init() или refreshCurrentUser().
  }

  Future<void> logout() async {
    await _client.auth.signOut();
    _currentUserData = null;
    // намеренно не чистим prefs — гость не потеряет выбор
  }

  // ==================== профиль и атрибуты ====================

  Future<void> markQuestionnaireComplete() async {
    await setHasCompletedQuestionnaire(true);
  }

  /// универсальный сеттер — работает и для гостя, и для юзера.
  Future<void> setHasCompletedQuestionnaire(bool v) async {
    _cachedOnboardingCompleted = v;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefOnboardingCompleted, v);
    } catch (_) {
      /* ignore */
    }

    final id = _currentUserData?['id'];
    if (id != null) {
      await _client
          .from('users')
          .update({'has_completed_questionnaire': v})
          .eq('id', id);
      _currentUserData = {
        ...?_currentUserData,
        'has_completed_questionnaire': v,
      };
    }
  }

  /// Обновление произвольных полей профиля.
  Future<void> updateUserDetails(Map<String, dynamic> updates) async {
    final id = _currentUserData?['id'];
    if (id != null) {
      await _client.from('users').update(updates).eq('id', id);
      _currentUserData = {...?_currentUserData, ...updates};
    }
    if (updates.containsKey('has_completed_questionnaire')) {
      final v = updates['has_completed_questionnaire'] == true;
      await setHasCompletedQuestionnaire(v);
    }
  }

  // -------- интро и архетип --------

  Future<void> markEpicIntroSeen() async {
    _cachedSeenIntro = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefSeenIntro, true);

    final id = _currentUserData?['id'];
    if (id != null) {
      await _client.from('users').update({'has_seen_intro': true}).eq('id', id);
      _currentUserData = {...?_currentUserData, 'has_seen_intro': true};
    }
  }

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

  // -------- NEW: драфт анкеты гостя --------

  /// Сохранить/обновить черновик анкеты (гость). Если [completed] = true, отмечаем как завершённый.
  Future<void> saveGuestOnboardingDraft(
    Map<String, dynamic> data, {
    bool completed = false,
  }) async {
    _cachedOnboardingDraft = data;
    if (completed) _cachedOnboardingCompleted = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefOnboardingDraft, jsonEncode(data));
    if (completed) {
      await prefs.setBool(_prefOnboardingCompleted, true);
    }
  }

  /// Очистить черновик анкеты гостя.
  Future<void> clearGuestOnboardingDraft() async {
    _cachedOnboardingDraft = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefOnboardingDraft);
    // флаг completed чистим только после успешного переноса
    await prefs.remove(_prefOnboardingCompleted);
  }

  // ==================== private helpers ====================

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
      'has_seen_intro': _cachedSeenIntro ?? false,
      'archetype': _cachedArchetype,
      'has_completed_questionnaire': _cachedOnboardingCompleted ?? false,
      // сами ответы анкеты в колонки переносим в _syncGuestOnLogin()
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
    _cachedOnboardingCompleted =
        prefs.getBool(_prefOnboardingCompleted) ?? false;

    final raw = prefs.getString(_prefOnboardingDraft); // NEW
    if (raw != null && raw.isNotEmpty) {
      try {
        _cachedOnboardingDraft = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        _cachedOnboardingDraft = null;
      }
    }
  }

  /// Если гость что-то ввёл до логина — переносим в профиль.
  Future<void> _syncGuestOnLogin() async {
    final id = _currentUserData?['id'];
    if (id == null) return;

    final updates = <String, dynamic>{};

    if ((_currentUserData?['has_seen_intro'] != true) &&
        (_cachedSeenIntro == true)) {
      updates['has_seen_intro'] = true;
    }

    final profileArchetype = (_currentUserData?['archetype'] as String?) ?? '';
    if (profileArchetype.isEmpty &&
        (_cachedArchetype != null && _cachedArchetype!.isNotEmpty)) {
      updates['archetype'] = _cachedArchetype;
    }

    // ---- переносим поля анкеты из черновика ----
    bool isEmpty(dynamic v) =>
        v == null ||
        (v is String && v.isEmpty) ||
        (v is List && v.isEmpty) ||
        (v is Map && v.isEmpty);

    void putIfEmpty(String col, dynamic value) {
      if (value == null) return;
      if (isEmpty(_currentUserData?[col])) updates[col] = value;
    }

    final d = _cachedOnboardingDraft;
    if (d != null) {
      putIfEmpty('life_blocks', (d['life_blocks'] as List?)?.cast<String>());
      putIfEmpty('priorities', (d['priorities'] as List?)?.cast<String>());
      putIfEmpty('sleep', d['sleep']);
      putIfEmpty('activity', d['activity']);
      putIfEmpty('energy', (d['energy'] as num?)?.toInt());
      putIfEmpty('stress', d['stress']);
      putIfEmpty(
        'finance_satisfaction',
        (d['finance_satisfaction'] as num?)?.toInt(),
      );
      putIfEmpty('dreams_by_block', d['dreams_by_block'] as Map?);
      putIfEmpty('goals_by_block', d['goals_by_block'] as Map?);

      if ((_currentUserData?['has_completed_questionnaire'] != true) &&
          (_cachedOnboardingCompleted == true)) {
        updates['has_completed_questionnaire'] = true;
      }
    }

    if (updates.isNotEmpty) {
      final updated = await _client
          .from('users')
          .update(updates)
          .eq('id', id)
          .select()
          .maybeSingle();
      if (updated != null) {
        _currentUserData = {...?_currentUserData, ...updated};
      }
      // черновик больше не нужен
      await clearGuestOnboardingDraft();
    }
  }
}
