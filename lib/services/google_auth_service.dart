import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService({required this.webClientId, FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final String webClientId;
  final FlutterSecureStorage _storage;

  // scope только на события (минимально нужное)
  static const _scopes = <String>[
    'https://www.googleapis.com/auth/calendar.events',
  ];

  GoogleSignIn _signIn() {
    // ВАЖНО: на Web нужно передать clientId
    return GoogleSignIn(clientId: kIsWeb ? webClientId : null, scopes: _scopes);
  }

  Future<String?> getAccessTokenSilent() async {
    final cached = await _storage.read(key: 'gcal_access_token');
    if (cached != null && cached.trim().isNotEmpty) return cached.trim();
    return null;
  }

  Future<String> signInAndGetAccessToken() async {
    final gs = _signIn();

    final user = await gs.signIn();
    if (user == null) {
      throw Exception('Google sign-in cancelled');
    }

    final auth = await user.authentication;
    final token = auth.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('No accessToken returned by Google Sign-In');
    }

    await _storage.write(key: 'gcal_access_token', value: token);
    return token;
  }

  Future<void> signOut() async {
    final gs = _signIn();
    await gs.signOut();
    await _storage.delete(key: 'gcal_access_token');
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'gcal_access_token');
  }
}
