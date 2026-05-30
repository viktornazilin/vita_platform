// lib/services/user_service.dart
import 'dart:convert';
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
  static const _prefOnboardingDraft = 'vita_onboarding_draft_json';

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

  List<String> get selectedLifeBlocks {
    final v = _currentUserData?['life_blocks'];
    if (v is List) {
      return v
          .whereType<String>()
          .where((e) => e.trim().isNotEmpty)
          .map((e) => e.trim())
          .toSet()
          .toList();
    }

    final d = _cachedOnboardingDraft;
    final draftBlocks = d?['life_blocks'];
    if (draftBlocks is List) {
      return draftBlocks
          .whereType<String>()
          .where((e) => e.trim().isNotEmpty)
          .map((e) => e.trim())
          .toSet()
          .toList();
    }

    return const <String>[];
  }

  bool get needsLifeBlocksSetup => selectedLifeBlocks.isEmpty;

  // локальный кэш для гостей
  bool? _cachedSeenIntro;
  String? _cachedArchetype;
  bool? _cachedOnboardingCompleted;
  Map<String, dynamic>? _cachedOnboardingDraft;

  // ==================== жизненный цикл ====================

  Future<void> init() async {
    await _loadLocalGuestPrefs();

    final user = _client.auth.currentUser;
    if (user == null) {
      _currentUserData = null;
      return;
    }

    // ✅ НИКОГДА не делаем insert/upsert в public.users с клиента (RLS)
    _currentUserData =
        await _waitUserRow(user.id) ?? {'id': user.id, 'email': user.email};

    await _syncGuestOnLogin();

    _currentUserData =
        await _waitUserRow(user.id) ?? _currentUserData; // refresh
  }

  /// 🔄 Вызови после signedIn, чтобы подтянуть профиль.
  Future<void> refreshCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      _currentUserData = null;
      return;
    }

    _currentUserData =
        await _waitUserRow(user.id) ?? {'id': user.id, 'email': user.email};

    await _syncGuestOnLogin();

    _currentUserData =
        await _waitUserRow(user.id) ?? _currentUserData; // refresh
  }

  // ==================== аутентификация ====================

  /// ✅ Email/password регистрация (+ GDPR флаги в metadata)
  Future<void> register(
    String name,
    String email,
    String password, {
    bool termsAccepted = false,
    bool analyticsAccepted = false,
    bool marketingAccepted = false,
  }) async {
    final authRes = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': name,
        // ✅ GDPR/consent metadata (для аудита/логики)
        'termsAccepted': termsAccepted,
        'analyticsAccepted': analyticsAccepted,
        'marketingAccepted': marketingAccepted,
        'termsAcceptedAt': termsAccepted
            ? DateTime.now().toIso8601String()
            : null,
      },
    );

    final u = authRes.user;
    if (u == null) {
      throw Exception('Ошибка при регистрации');
    }

    // ✅ Ждём, пока БД/триггер создаст строку public.users (если триггера нет — вернёт null)
    _currentUserData = await _waitUserRow(u.id) ?? {'id': u.id, 'email': email};

    // ✅ Пытаемся записать имя через UPDATE (RLS обычно разрешает update своей строки)
    // Если политика UPDATE не настроена — просто проигнорируем (UI не сломаем).
    try {
      await _client.from('users').update({'name': name}).eq('id', u.id);
    } catch (_) {}

    await _syncGuestOnLogin();

    _currentUserData = await _waitUserRow(u.id) ?? _currentUserData;
  }

  Future<bool> login(String email, String password) async {
    final authRes = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = authRes.user;
    if (user == null) return false;

    _currentUserData =
        await _waitUserRow(user.id) ?? {'id': user.id, 'email': user.email};

    await _syncGuestOnLogin();

    _currentUserData =
        await _waitUserRow(user.id) ?? _currentUserData; // refresh

    return true;
  }

  /// ✅ Вход/регистрация через Google OAuth (универсальный поток).
  /// ВАЖНО: consent-флаги мы запишем в user_metadata после того, как пользователь вернётся (signedIn).
  Future<void> signInWithGoogle({
    bool termsAccepted = false,
    bool analyticsAccepted = false,
    bool marketingAccepted = false,
  }) async {
    // 1) сохраняем consents локально, чтобы применить после callback (когда появится user)
    await _cachePendingConsents(
      termsAccepted: termsAccepted,
      analyticsAccepted: analyticsAccepted,
      marketingAccepted: marketingAccepted,
    );

    final redirect = kIsWeb ? null : _mobileRedirect;
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirect,
      queryParams: const {'access_type': 'offline', 'prompt': 'consent'},
    );
    // После редиректа слушай onAuthStateChange в UI и дерни refreshCurrentUser().
  }

  /// ✅ Вход/регистрация через Apple ID (iOS requirement, если есть другие social logins)
  /// consent-флаги также применим после signedIn.
  Future<void> signInWithApple({
    bool termsAccepted = false,
    bool analyticsAccepted = false,
    bool marketingAccepted = false,
  }) async {
    await _cachePendingConsents(
      termsAccepted: termsAccepted,
      analyticsAccepted: analyticsAccepted,
      marketingAccepted: marketingAccepted,
    );

    final redirect = kIsWeb ? null : _mobileRedirect;
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: redirect,
    );
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

  Future<void> completeLifeBlocksSetup(List<String> blocks) async {
    final cleaned = blocks
        .where((e) => e.trim().isNotEmpty)
        .map((e) => e.trim())
        .toSet()
        .toList();

    if (cleaned.isEmpty) return;

    _cachedOnboardingCompleted = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefOnboardingCompleted, true);
    await prefs.setString(
      _prefOnboardingDraft,
      jsonEncode({
        'life_blocks': cleaned,
        'priorities': cleaned,
      }),
    );

    final id = _currentUserData?['id'];
    if (id != null) {
      final updates = <String, dynamic>{
        'life_blocks': cleaned,
        'priorities': cleaned,
        'has_completed_questionnaire': true,
      };

      await _client.from('users').update(updates).eq('id', id);
      _currentUserData = {...?_currentUserData, ...updates};
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

  // -------- драфт анкеты гостя --------

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

  // ==================== GDPR / Consents helpers ====================

  static const _prefPendingConsents = 'vita_pending_consents_json';

  Future<void> _cachePendingConsents({
    required bool termsAccepted,
    required bool analyticsAccepted,
    required bool marketingAccepted,
  }) async {
    // сохраняем только если вообще есть что сохранять
    final map = <String, dynamic>{
      'termsAccepted': termsAccepted,
      'analyticsAccepted': analyticsAccepted,
      'marketingAccepted': marketingAccepted,
      'termsAcceptedAt': termsAccepted
          ? DateTime.now().toIso8601String()
          : null,
    };
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefPendingConsents, jsonEncode(map));
  }

  Future<Map<String, dynamic>?> _takePendingConsents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefPendingConsents);
    if (raw == null || raw.isEmpty) return null;
    await prefs.remove(_prefPendingConsents);
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return m;
    } catch (_) {
      return null;
    }
  }

  Future<void> _applyPendingConsentsIfAny() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final consents = await _takePendingConsents();
    if (consents == null) return;

    // не затираем существующие, если они уже есть
    final meta = (user.userMetadata ?? {});
    final next = <String, dynamic>{...meta};

    void setIfMissing(String key, dynamic value) {
      if (value == null) return;
      if (!next.containsKey(key) || next[key] == null) next[key] = value;
    }

    setIfMissing('termsAccepted', consents['termsAccepted']);
    setIfMissing('analyticsAccepted', consents['analyticsAccepted']);
    setIfMissing('marketingAccepted', consents['marketingAccepted']);
    setIfMissing('termsAcceptedAt', consents['termsAcceptedAt']);

    // update auth user metadata
    try {
      await _client.auth.updateUser(UserAttributes(data: next));
    } catch (_) {
      // не падаем — это не должно ломать onboarding
    }
  }

  // ==================== private helpers ====================

  Future<void> _loadLocalGuestPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedSeenIntro = prefs.getBool(_prefSeenIntro) ?? false;
    _cachedArchetype = prefs.getString(_prefArchetype);
    _cachedOnboardingCompleted =
        prefs.getBool(_prefOnboardingCompleted) ?? false;

    final raw = prefs.getString(_prefOnboardingDraft);
    if (raw != null && raw.isNotEmpty) {
      try {
        _cachedOnboardingDraft = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        _cachedOnboardingDraft = null;
      }
    }
  }

  /// ✅ Ждём, пока сервер создаст строку public.users (trigger on auth.users).
  /// ВАЖНО: если триггера нет — вернёт null.
  Future<Map<String, dynamic>?> _waitUserRow(String uid) async {
    Map<String, dynamic>? row;
    for (int i = 0; i < 8; i++) {
      row = await _client.from('users').select().eq('id', uid).maybeSingle();
      if (row != null) return (row as Map).cast<String, dynamic>();
      await Future.delayed(const Duration(milliseconds: 250));
    }
    return null;
  }

  String? _extractNameFromMetadata(User user) {
    final meta = user.userMetadata ?? {};
    return (meta['full_name'] ?? meta['name'] ?? meta['given_name']) as String?;
  }

  /// Если гость что-то ввёл до логина — переносим в профиль.
  Future<void> _syncGuestOnLogin() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;

    // ✅ применяем pending consents (после OAuth callback)
    await _applyPendingConsentsIfAny();

    // если строки ещё нет — нечего обновлять
    final row = await _waitUserRow(uid);
    if (row == null) return;

    _currentUserData = (row as Map).cast<String, dynamic>();

    final updates = <String, dynamic>{};

    if ((_currentUserData?['has_seen_intro'] != true) &&
        (_cachedSeenIntro == true)) {
      updates['has_seen_intro'] = true;
    }

    // если name пустое — возьмём из метадаты auth или из кэша (аргументы register)
    final profileName = (_currentUserData?['name'] as String?) ?? '';
    if (profileName.isEmpty) {
      final metaName = _extractNameFromMetadata(_client.auth.currentUser!);
      if (metaName != null && metaName.isNotEmpty) {
        updates['name'] = metaName;
      }
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
          .eq('id', uid)
          .select()
          .maybeSingle();

      if (updated != null) {
        _currentUserData = {...?_currentUserData, ...(updated as Map)};
      }

      // черновик больше не нужен
      await clearGuestOnboardingDraft();
    }
  }
}
