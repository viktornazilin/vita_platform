import 'core/base_repo.dart';
import '../models/goal.dart';
import '../models/xp.dart';
import '../core/security/secure_crypto_service.dart';

mixin GoalsRepoMixin on BaseRepo {
  final SecureCryptoService _crypto = SecureCryptoService();

  // =========================
  // Goals CRUD
  // =========================

  Future<List<Goal>> fetchGoals({String? lifeBlock, String? userGoalId}) async {
    var q = client.from('goals').select().eq('user_id', uid);

    if (lifeBlock != null) {
      q = q.eq('life_block', lifeBlock);
    }
    if (userGoalId != null) {
      q = q.eq('user_goal_id', userGoalId);
    }

    final res = await q.order('created_at', ascending: false);
    final rows = (res as List).cast<Map<String, dynamic>>();

    final decryptedRows = await Future.wait(
      rows.map(_decryptGoalRow),
    );

    return decryptedRows.map(Goal.fromMap).toList();
  }

  Future<Goal> createGoal({
    required String title,
    String description = '',
    required DateTime deadline,
    required String lifeBlock,
    int importance = 1,
    String emotion = '',
    double spentHours = 1.0,
    required DateTime startTime,
    String? userGoalId,
  }) async {
    final encryptedPayload = await _encryptGoalPayload(
      title: title,
      description: description,
      emotion: emotion,
    );

    final insert = <String, dynamic>{
      'user_id': uid,

      // Legacy/plain columns intentionally cleared.
      // title is NOT NULL in DB, therefore we store an empty string.
      'title': '',
      'description': '',
      'emotion': '',

      'encrypted_payload': encryptedPayload,

      'deadline': deadline.toIso8601String(),
      'is_completed': false,
      'life_block': lifeBlock,
      'importance': importance,
      'spent_hours': spentHours,
      'start_time': startTime.toIso8601String(),
      'user_goal_id': userGoalId,
    };

    final res = await client.from('goals').insert(insert).select().single();
    final decrypted = await _decryptGoalRow(
      (res as Map).cast<String, dynamic>(),
    );

    return Goal.fromMap(decrypted);
  }

  Future<List<Goal>> createGoalsBulk(
    List<Map<String, dynamic>> items,
  ) async {
    if (items.isEmpty) return [];

    final payload = await Future.wait(
      items.map(
        (item) async {
          final title = (item['title'] ?? '').toString();
          final description = (item['description'] ?? '').toString();
          final emotion = (item['emotion'] ?? '').toString();

          final encryptedPayload = await _encryptGoalPayload(
            title: title,
            description: description,
            emotion: emotion,
          );

          return <String, dynamic>{
            'user_id': uid,

            // Legacy/plain columns intentionally cleared.
            'title': '',
            'description': '',
            'emotion': '',

            'encrypted_payload': encryptedPayload,

            'deadline': _asIsoString(item['deadline']),
            'is_completed': item['is_completed'] ?? false,
            'life_block': item['life_block'] ?? 'general',
            'importance': item['importance'] ?? 1,
            'spent_hours': _asDouble(item['spent_hours'] ?? 1.0),
            'start_time': _asIsoString(item['start_time']),
            'user_goal_id': item['user_goal_id'],
          };
        },
      ),
    );

    final res = await client.from('goals').insert(payload).select();
    final rows = (res as List).cast<Map<String, dynamic>>();

    final decryptedRows = await Future.wait(
      rows.map(_decryptGoalRow),
    );

    return decryptedRows.map(Goal.fromMap).toList();
  }

  Future<void> updateGoal(Goal goal) async {
    final encryptedPayload = await _encryptGoalPayload(
      title: goal.title,
      description: goal.description,
      emotion: goal.emotion,
    );

    await client
        .from('goals')
        .update({
          // Legacy/plain columns intentionally cleared.
          'title': '',
          'description': '',
          'emotion': '',

          'encrypted_payload': encryptedPayload,

          'deadline': goal.deadline.toIso8601String(),
          'is_completed': goal.isCompleted,
          'life_block': goal.lifeBlock,
          'importance': goal.importance,
          'spent_hours': goal.spentHours,
          'start_time': goal.startTime.toIso8601String(),
          'user_goal_id': _extractUserGoalId(goal),
        })
        .eq('id', goal.id)
        .eq('user_id', uid);
  }

  Future<void> updateGoalFields({
    required String goalId,
    String? title,
    String? description,
    DateTime? deadline,
    bool? isCompleted,
    String? lifeBlock,
    int? importance,
    String? emotion,
    double? spentHours,
    DateTime? startTime,
    Object? userGoalId = _unset,
  }) async {
    final update = <String, dynamic>{};

    final shouldUpdateEncryptedPayload =
        title != null || description != null || emotion != null;

    if (shouldUpdateEncryptedPayload) {
      final current = await client
          .from('goals')
          .select('title, description, emotion, encrypted_payload')
          .eq('id', goalId)
          .eq('user_id', uid)
          .maybeSingle();

      if (current != null) {
        final currentRow = await _decryptGoalRow(
          (current as Map).cast<String, dynamic>(),
        );

        final mergedTitle = title ?? (currentRow['title'] ?? '').toString();
        final mergedDescription =
            description ?? (currentRow['description'] ?? '').toString();
        final mergedEmotion =
            emotion ?? (currentRow['emotion'] ?? '').toString();

        final encryptedPayload = await _encryptGoalPayload(
          title: mergedTitle,
          description: mergedDescription,
          emotion: mergedEmotion,
        );

        update['encrypted_payload'] = encryptedPayload;

        // Legacy/plain columns intentionally cleared.
        update['title'] = '';
        update['description'] = '';
        update['emotion'] = '';
      }
    }

    if (deadline != null) update['deadline'] = deadline.toIso8601String();
    if (isCompleted != null) update['is_completed'] = isCompleted;
    if (lifeBlock != null) update['life_block'] = lifeBlock;
    if (importance != null) update['importance'] = importance;
    if (spentHours != null) update['spent_hours'] = spentHours;
    if (startTime != null) update['start_time'] = startTime.toIso8601String();

    if (!identical(userGoalId, _unset)) {
      update['user_goal_id'] = userGoalId;
    }

    if (update.isEmpty) return;

    await client.from('goals').update(update).eq('id', goalId).eq('user_id', uid);
  }

  Future<void> deleteGoal(String id) async {
    final dynamic idValue = int.tryParse(id) ?? id;

    final res = await client
        .from('goals')
        .delete()
        .eq('id', idValue)
        .eq('user_id', uid)
        .select('id');

    final deleted = (res as List).cast<Map<String, dynamic>>();
    if (deleted.isEmpty) {
      final still = await client
          .from('goals')
          .select('id,user_id')
          .eq('id', idValue)
          .maybeSingle();

      throw Exception(
        'Delete matched 0 rows. uid=$uid id=$idValue stillExists=${still != null} row=$still',
      );
    }
  }

  Future<List<Goal>> getGoalsByDate(
    DateTime date, {
    String? lifeBlock,
    String? userGoalId,
  }) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    var q = client
        .from('goals')
        .select()
        .eq('user_id', uid)
        .gte('deadline', start.toIso8601String())
        .lt('deadline', end.toIso8601String());

    if (lifeBlock != null) {
      q = q.eq('life_block', lifeBlock);
    }
    if (userGoalId != null) {
      q = q.eq('user_goal_id', userGoalId);
    }

    final res = await q.order('start_time', ascending: true);
    final rows = (res as List).cast<Map<String, dynamic>>();

    final decryptedRows = await Future.wait(
      rows.map(_decryptGoalRow),
    );

    return decryptedRows.map(Goal.fromMap).toList();
  }

  Future<List<Goal>> getGoalsLinkedToUserGoal(String userGoalId) async {
    final res = await client
        .from('goals')
        .select()
        .eq('user_id', uid)
        .eq('user_goal_id', userGoalId)
        .order('start_time', ascending: true);

    final rows = (res as List).cast<Map<String, dynamic>>();

    final decryptedRows = await Future.wait(
      rows.map(_decryptGoalRow),
    );

    return decryptedRows.map(Goal.fromMap).toList();
  }

  Future<void> unlinkGoalsFromUserGoal(String userGoalId) async {
    await client
        .from('goals')
        .update({'user_goal_id': null})
        .eq('user_id', uid)
        .eq('user_goal_id', userGoalId);
  }

  Future<void> toggleGoalCompleted(String id, {bool? value}) async {
    final row = await client
        .from('goals')
        .select('is_completed')
        .eq('id', id)
        .eq('user_id', uid)
        .maybeSingle();
    if (row == null) return;

    final newVal = value ?? !(row['is_completed'] as bool? ?? false);

    await client
        .from('goals')
        .update({'is_completed': newVal})
        .eq('id', id)
        .eq('user_id', uid);

    if (newVal) {
      await addXP(10);
      final total = await getTotalHoursSpentOnDate(DateTime.now());
      final target = await getTargetHours();
      if (total >= target) {
        await addXP(20);
      }
    }
  }

  // =========================
  // Autocomplete / Suggestions
  // =========================

  Future<List<String>> searchGoalTitles({
    required String query,
    int limit = 8,
    String? lifeBlock,
    String? userGoalId,
  }) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    var req = client
        .from('goals')
        .select(
          'title, description, emotion, encrypted_payload, created_at, deadline, life_block, user_goal_id',
        )
        .eq('user_id', uid);

    if (lifeBlock != null) {
      req = req.eq('life_block', lifeBlock);
    }
    if (userGoalId != null) {
      req = req.eq('user_goal_id', userGoalId);
    }

    // Server-side ILIKE is no longer possible for encrypted titles.
    // We fetch recent rows and filter locally after decryption.
    final rows = await req.order('created_at', ascending: false).limit(300);
    final rawRows = (rows as List).cast<Map<String, dynamic>>();

    final decryptedRows = await Future.wait(
      rawRows.map(_decryptGoalRow),
    );

    final seen = <String>{};
    final out = <String>[];

    for (final r in decryptedRows) {
      final title = (r['title'] as String?)?.trim() ?? '';
      if (title.isEmpty) continue;

      final norm = title.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
      if (norm.isEmpty || seen.contains(norm)) continue;
      if (!norm.contains(q)) continue;

      seen.add(norm);
      out.add(title);

      if (out.length >= limit) break;
    }

    return out;
  }

  Future<List<Map<String, dynamic>>> listGoalTitleHistory({
    required DateTime start,
    required DateTime end,
    String? lifeBlock,
    String? userGoalId,
  }) async {
    var q = client
        .from('goals')
        .select(
          'title, description, emotion, encrypted_payload, deadline, life_block, user_goal_id',
        )
        .eq('user_id', uid)
        .gte('deadline', start.toIso8601String())
        .lt('deadline', end.toIso8601String());

    if (lifeBlock != null) {
      q = q.eq('life_block', lifeBlock);
    }
    if (userGoalId != null) {
      q = q.eq('user_goal_id', userGoalId);
    }

    final res = await q;
    final rows = (res as List).cast<Map<String, dynamic>>();

    return Future.wait(
      rows.map(_decryptGoalRow),
    );
  }

  Future<List<String>> suggestRecurringGoalTitles({
    int lookbackDays = 30,
    String? lifeBlock,
    String? userGoalId,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: lookbackDays));
    final end = today.add(const Duration(days: 1));

    var q = client
        .from('goals')
        .select(
          'title, description, emotion, encrypted_payload, deadline, life_block, user_goal_id',
        )
        .eq('user_id', uid)
        .gte('deadline', start.toIso8601String())
        .lt('deadline', end.toIso8601String());

    if (lifeBlock != null) {
      q = q.eq('life_block', lifeBlock);
    }
    if (userGoalId != null) {
      q = q.eq('user_goal_id', userGoalId);
    }

    final res = await q;
    final rows = (res as List).cast<Map<String, dynamic>>();

    final decryptedRows = await Future.wait(
      rows.map(_decryptGoalRow),
    );

    final Map<String, Set<String>> daysByTitle = {};
    final Map<String, int> totalByTitle = {};

    for (final m in decryptedRows) {
      final title = (m['title'] ?? '').toString().trim();
      if (title.isEmpty) continue;

      DateTime? d;
      final dv = m['deadline'];
      if (dv is String) d = DateTime.tryParse(dv);
      if (dv is DateTime) d = dv;
      if (d == null) continue;

      final dayKey =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      (daysByTitle[title] ??= <String>{}).add(dayKey);
      totalByTitle[title] = (totalByTitle[title] ?? 0) + 1;
    }

    final candidates = daysByTitle.entries
        .where((e) => e.value.length >= 2)
        .map(
          (e) => _TitleStat(
            title: e.key,
            daysCount: e.value.length,
            totalCount: totalByTitle[e.key] ?? e.value.length,
          ),
        )
        .toList();

    candidates.sort((a, b) {
      final byDays = b.daysCount.compareTo(a.daysCount);
      if (byDays != 0) return byDays;
      final byTotal = b.totalCount.compareTo(a.totalCount);
      if (byTotal != 0) return byTotal;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    return candidates.take(5).map((e) => e.title).toList();
  }

  // =========================
  // XP
  // =========================

  Future<XP> getXP() async {
    final res = await client
        .from('user_xp')
        .select()
        .eq('user_id', uid)
        .maybeSingle();

    if (res == null) {
      final created = await client
          .from('user_xp')
          .insert({'user_id': uid})
          .select()
          .single();
      return XP.fromMap(created);
    }
    return XP.fromMap(res);
  }

  Future<XP> addXP(int points) async {
    final current = await getXP();
    final updated = current.addXP(points);
    await client.from('user_xp').upsert(updated.toMap()).select().single();
    return updated;
  }

  // =========================
  // Reports helpers
  // =========================

  Future<double> getTargetHours() async {
    final res = await client
        .from('users')
        .select('target_hours')
        .eq('id', uid)
        .maybeSingle();
    if (res == null || res['target_hours'] == null) return 14;
    return (res['target_hours'] as num).toDouble();
  }

  Future<List<Goal>> fetchGoalsInRange({
    required DateTime start,
    required DateTime end,
    String? lifeBlock,
    String? userGoalId,
  }) async {
    var q = client
        .from('goals')
        .select()
        .eq('user_id', uid)
        .gte('start_time', start.toIso8601String())
        .lt('start_time', end.toIso8601String());

    if (lifeBlock != null) {
      q = q.eq('life_block', lifeBlock);
    }
    if (userGoalId != null) {
      q = q.eq('user_goal_id', userGoalId);
    }

    final res = await q.order('start_time', ascending: true);
    final rows = (res as List).cast<Map<String, dynamic>>();

    final decryptedRows = await Future.wait(
      rows.map(_decryptGoalRow),
    );

    return decryptedRows.map(Goal.fromMap).toList();
  }

  Future<double> getTotalHoursSpentOnDate(
    DateTime date, {
    String? lifeBlock,
    String? userGoalId,
  }) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    var q = client
        .from('goals')
        .select('spent_hours, life_block, user_goal_id')
        .eq('user_id', uid)
        .gte('deadline', start.toIso8601String())
        .lt('deadline', end.toIso8601String());

    if (lifeBlock != null) {
      q = q.eq('life_block', lifeBlock);
    }
    if (userGoalId != null) {
      q = q.eq('user_goal_id', userGoalId);
    }

    final res = await q;

    return (res as List).fold<double>(
      0,
      (sum, item) => sum + ((item['spent_hours'] ?? 0) as num).toDouble(),
    );
  }

  // =========================
  // Encryption helpers
  // =========================

  Future<Map<String, dynamic>> _encryptGoalPayload({
    required String title,
    required String description,
    required String emotion,
  }) async {
    final payload = <String, dynamic>{
      'title': title.trim(),
      'description': description.trim(),
      'emotion': emotion.trim(),
    };

    return _crypto.encryptJson(payload);
  }

  Future<Map<String, dynamic>> _decryptGoalRow(Map<String, dynamic> row) async {
    final copy = Map<String, dynamic>.from(row);
    final encryptedPayload = copy['encrypted_payload'];

    if (encryptedPayload == null) {
      // Legacy fallback: old rows before encryption.
      copy['title'] = (copy['title'] ?? '').toString();
      copy['description'] = (copy['description'] ?? '').toString();
      copy['emotion'] = (copy['emotion'] ?? '').toString();
      return copy;
    }

    try {
      if (encryptedPayload is! Map) {
        copy['title'] = (copy['title'] ?? '').toString();
        copy['description'] = (copy['description'] ?? '').toString();
        copy['emotion'] = (copy['emotion'] ?? '').toString();
        return copy;
      }

      final payload = await _crypto.decryptJson(
        encryptedPayload.cast<String, dynamic>(),
      );

      copy['title'] = (payload['title'] ?? copy['title'] ?? '').toString();
      copy['description'] =
          (payload['description'] ?? copy['description'] ?? '').toString();
      copy['emotion'] =
          (payload['emotion'] ?? copy['emotion'] ?? '').toString();

      return copy;
    } catch (_) {
      // If decryption fails, do not crash the whole screen.
      // Keep legacy/plain values if they exist.
      copy['title'] = (copy['title'] ?? '').toString();
      copy['description'] = (copy['description'] ?? '').toString();
      copy['emotion'] = (copy['emotion'] ?? '').toString();
      return copy;
    }
  }

  // =========================
  // Helpers
  // =========================

  static const Object _unset = Object();

  String _asIsoString(dynamic value) {
    if (value is DateTime) return value.toIso8601String();
    if (value is String) return value;
    throw ArgumentError('Expected DateTime or ISO string, got: $value');
  }

  double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '.')) ?? 0;
    return 0;
  }

  dynamic _extractUserGoalId(Goal goal) {
    try {
      return (goal as dynamic).userGoalId;
    } catch (_) {
      return null;
    }
  }
}

class _TitleStat {
  final String title;
  final int daysCount;
  final int totalCount;

  const _TitleStat({
    required this.title,
    required this.daysCount,
    required this.totalCount,
  });
}