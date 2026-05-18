import 'core/base_repo.dart';
import '../models/mood.dart';
import '../core/security/secure_crypto_service.dart';

mixin MoodsRepoMixin on BaseRepo {
  static const String _encryptedMoodEmojiPlaceholder = '🔒';

  final SecureCryptoService _moodCrypto = SecureCryptoService();

  String _isoDateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day).toIso8601String();

  Future<Map<String, dynamic>> _decryptMoodRow(
    Map<String, dynamic> row,
  ) async {
    final encryptedPayload = row['encrypted_payload'];

    if (encryptedPayload == null) {
      return row;
    }

    try {
      final decryptedPayload = await _moodCrypto.decryptJson(
        Map<String, dynamic>.from(encryptedPayload as Map),
      );

      return {
        ...row,
        ...decryptedPayload,
      };
    } catch (_) {
      return row;
    }
  }

  Future<Mood?> getMoodByDate(DateTime date) async {
    final isoDate = _isoDateOnly(date);

    final res = await client
        .from('moods')
        .select()
        .eq('user_id', uid)
        .eq('date', isoDate)
        .maybeSingle();

    if (res == null) return null;

    final row = await _decryptMoodRow(Map<String, dynamic>.from(res));
    return Mood.fromMap(row);
  }

  Future<Mood> upsertMood({
    required DateTime date,
    required String emoji,
    String note = '',
  }) async {
    final encryptedPayload = await _moodCrypto.encryptJson({
      'emoji': emoji,
      'note': note,
    });

    final data = {
      'user_id': uid,
      'date': _isoDateOnly(date),

      // Не храним реальное настроение в открытом виде.
      // Поле emoji в БД not null, поэтому оставляем техническую заглушку.
      'emoji': _encryptedMoodEmojiPlaceholder,

      // Не храним заметку в открытом виде.
      'note': null,

      // Реальные emoji и note лежат здесь.
      'encrypted_payload': encryptedPayload,
    };

    final res = await client
        .from('moods')
        .upsert(data, onConflict: 'user_id,date')
        .select()
        .single();

    final row = await _decryptMoodRow(Map<String, dynamic>.from(res));
    return Mood.fromMap(row);
  }

  Future<void> deleteMoodByDate(DateTime date) async {
    final isoDate = _isoDateOnly(date);

    await client
        .from('moods')
        .delete()
        .eq('user_id', uid)
        .eq('date', isoDate);
  }

  Future<List<Mood>> fetchMoods({int limit = 30}) async {
    final res = await client
        .from('moods')
        .select()
        .eq('user_id', uid)
        .order('date', ascending: false)
        .limit(limit);

    final rows = res as List;

    final decryptedRows = await Future.wait(
      rows.map(
        (m) => _decryptMoodRow(Map<String, dynamic>.from(m as Map)),
      ),
    );

    return decryptedRows.map(Mood.fromMap).toList();
  }

  /// Для выборки по календарю: [from; to], включительно
  Future<List<Mood>> fetchMoodsRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final res = await client
        .from('moods')
        .select()
        .eq('user_id', uid)
        .gte('date', _isoDateOnly(from))
        .lte('date', _isoDateOnly(to))
        .order('date', ascending: false);

    final rows = res as List;

    final decryptedRows = await Future.wait(
      rows.map(
        (m) => _decryptMoodRow(Map<String, dynamic>.from(m as Map)),
      ),
    );

    return decryptedRows.map(Mood.fromMap).toList();
  }
}