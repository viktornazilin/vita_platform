import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureCryptoService {
  SecureCryptoService({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyStorageKey = 'aimora_local_encryption_key_v1';

  // These names are safe fallback attempts for older builds / previous app names.
  // If an older key still exists in Keychain / Secure Storage, old encrypted goals
  // will become readable again and the key will be migrated to _keyStorageKey.
  static const List<String> _legacyKeyStorageKeys = <String>[
    'nest_local_encryption_key_v1',
    'nest_app_local_encryption_key_v1',
    'vita_local_encryption_key_v1',
    'vita_platform_local_encryption_key_v1',
    'ladna_local_encryption_key_v1',
    'local_encryption_key_v1',
  ];

  final FlutterSecureStorage _storage;
  final AesGcm _algorithm = AesGcm.with256bits();

  Future<Map<String, dynamic>> encryptJson(Map<String, dynamic> plainJson) async {
    final secretKey = await _getOrCreateSecretKey();

    final nonce = _generateRandomBytes(12);
    final plainText = utf8.encode(jsonEncode(plainJson));

    final secretBox = await _algorithm.encrypt(
      plainText,
      secretKey: secretKey,
      nonce: nonce,
    );

    return {
      'v': 1,
      'alg': 'AES-256-GCM',
      'nonce': base64Encode(secretBox.nonce),
      'ciphertext': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    };
  }

  Future<Map<String, dynamic>> decryptJson(Map<String, dynamic> encryptedJson) async {
    final nonceRaw = encryptedJson['nonce'];
    final ciphertextRaw = encryptedJson['ciphertext'];
    final macRaw = encryptedJson['mac'];

    if (nonceRaw is! String || ciphertextRaw is! String || macRaw is! String) {
      throw const FormatException('Encrypted payload has invalid AES-GCM fields.');
    }

    final nonce = base64Decode(nonceRaw);
    final ciphertext = base64Decode(ciphertextRaw);
    final macBytes = base64Decode(macRaw);

    final secretBox = SecretBox(
      ciphertext,
      nonce: nonce,
      mac: Mac(macBytes),
    );

    final candidates = await _readExistingSecretKeyCandidates();

    if (candidates.isEmpty) {
      throw StateError(
        'No local encryption key found in FlutterSecureStorage. '
        'The payload cannot be decrypted on this installation.',
      );
    }

    Object? lastError;
    StackTrace? lastStack;

    for (final candidate in candidates) {
      try {
        final clearBytes = await _algorithm.decrypt(
          secretBox,
          secretKey: SecretKey(candidate.bytes),
        );

        if (candidate.storageKey != _keyStorageKey) {
          // Migrate the recovered legacy key to the current storage key so the
          // next app runs can decrypt old data without trying all legacy names.
          await _storage.write(
            key: _keyStorageKey,
            value: base64Encode(candidate.bytes),
          );
          debugPrint(
            '✅ Migrated encryption key from ${candidate.storageKey} to $_keyStorageKey',
          );
        }

        final decoded = utf8.decode(clearBytes);
        final json = jsonDecode(decoded);

        if (json is! Map<String, dynamic>) {
          throw const FormatException('Decrypted payload is not a JSON object.');
        }

        return json;
      } catch (e, st) {
        lastError = e;
        lastStack = st;
      }
    }

    Error.throwWithStackTrace(
      StateError(
        'Unable to decrypt payload with any available local encryption key. '
        'Most likely the old key was lost or the data was encrypted by another installation. '
        'Last error: $lastError',
      ),
      lastStack ?? StackTrace.current,
    );
  }

  Future<SecretKey> _getOrCreateSecretKey() async {
    final existingKey = await _storage.read(key: _keyStorageKey);

    if (existingKey != null && existingKey.isNotEmpty) {
      return SecretKey(base64Decode(existingKey));
    }

    // Before creating a brand new key, try to reuse a legacy key if it exists.
    // This prevents accidental data loss after renaming the app / storage key.
    for (final legacyKey in _legacyKeyStorageKeys) {
      final value = await _storage.read(key: legacyKey);
      if (value == null || value.isEmpty) continue;

      await _storage.write(key: _keyStorageKey, value: value);
      debugPrint('✅ Reused legacy encryption key $legacyKey as $_keyStorageKey');
      return SecretKey(base64Decode(value));
    }

    final keyBytes = _generateRandomBytes(32);

    await _storage.write(
      key: _keyStorageKey,
      value: base64Encode(keyBytes),
    );

    return SecretKey(keyBytes);
  }

  Future<List<_StoredSecretKeyCandidate>> _readExistingSecretKeyCandidates() async {
    final keys = <String>[
      _keyStorageKey,
      ..._legacyKeyStorageKeys,
    ];

    final seenValues = <String>{};
    final candidates = <_StoredSecretKeyCandidate>[];

    for (final key in keys) {
      final value = await _storage.read(key: key);
      if (value == null || value.isEmpty) continue;
      if (!seenValues.add(value)) continue;

      try {
        final bytes = base64Decode(value);
        if (bytes.length != 32) {
          debugPrint('⚠️ Ignoring invalid encryption key $key: ${bytes.length} bytes');
          continue;
        }
        candidates.add(_StoredSecretKeyCandidate(storageKey: key, bytes: bytes));
      } catch (e) {
        debugPrint('⚠️ Ignoring invalid base64 encryption key $key: $e');
      }
    }

    return candidates;
  }

  List<int> _generateRandomBytes(int length) {
    final random = Random.secure();

    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }
}

class _StoredSecretKeyCandidate {
  final String storageKey;
  final List<int> bytes;

  const _StoredSecretKeyCandidate({
    required this.storageKey,
    required this.bytes,
  });
}