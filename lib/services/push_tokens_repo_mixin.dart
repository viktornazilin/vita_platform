import 'core/base_repo.dart';

mixin PushTokensRepoMixin on BaseRepo {
  /// Сохраняет/обновляет FCM device-токен текущего пользователя. upsert по
  /// token (не по user_id) — если этот же физический токен раньше
  /// принадлежал другому аккаунту на этом устройстве (logout/login другим
  /// пользователем), он корректно "переезжает" на текущего вместо создания
  /// дублирующей строки.
  Future<void> savePushToken({
    required String token,
    String platform = 'ios',
  }) async {
    await client.from('device_tokens').upsert(
      {
        'user_id': uid,
        'token': token,
        'platform': platform,
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'token',
    );
  }

  /// Удаляет конкретный токен — вызывать при выходе из аккаунта, чтобы
  /// после logout push на это устройство больше не приходил (особенно
  /// важно на общих/чужих устройствах).
  Future<void> deletePushToken(String token) async {
    await client.from('device_tokens').delete().eq('token', token);
  }
}
