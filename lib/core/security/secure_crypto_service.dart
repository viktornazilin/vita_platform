import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureCryptoService {
  SecureCryptoService({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyStorageKey = 'aimora_local_encryption_key_v1';

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
    final secretKey = await _getOrCreateSecretKey();

    final nonce = base64Decode(encryptedJson['nonce'] as String);
    final ciphertext = base64Decode(encryptedJson['ciphertext'] as String);
    final macBytes = base64Decode(encryptedJson['mac'] as String);

    final secretBox = SecretBox(
      ciphertext,
      nonce: nonce,
      mac: Mac(macBytes),
    );

    final clearBytes = await _algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    final decoded = utf8.decode(clearBytes);
    final json = jsonDecode(decoded);

    if (json is! Map<String, dynamic>) {
      throw const FormatException('Decrypted payload is not a JSON object.');
    }

    return json;
  }

  Future<SecretKey> _getOrCreateSecretKey() async {
    final existingKey = await _storage.read(key: _keyStorageKey);

    if (existingKey != null && existingKey.isNotEmpty) {
      return SecretKey(base64Decode(existingKey));
    }

    final keyBytes = _generateRandomBytes(32);

    await _storage.write(
      key: _keyStorageKey,
      value: base64Encode(keyBytes),
    );

    return SecretKey(keyBytes);
  }

  List<int> _generateRandomBytes(int length) {
    final random = Random.secure();

    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }
}