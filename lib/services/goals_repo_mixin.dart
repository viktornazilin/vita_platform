import 'core/base_repo.dart';
import '../models/goal.dart';
import '../models/xp.dart';
import '../core/security/secure_crypto_service.dart';

mixin GoalsRepoMixin on BaseRepo {
  final SecureCryptoService _crypto = SecureCryptoService();

  // =========================
  // Goals CRUD
  // =========================

  Future<List<Goal>> fetchGoals({
    String? lifeBlock,
    String? userGoalId,
    String? spaceId,
    bool personalOnly = false,
  }) async {
    var q = client.from('goals').select();

    if (personalOnly) {
      q = q.eq('user_id', uid).isFilter('space_id', null);
    } else if (_hasText(spaceId)) {
      q = q.eq('space_id', spaceId!);
    }

    if (lifeBlock != null) {
      q = q.eq('life_block', lifeBlock);
    }
    if (userGoalId != null) {
      q = q.eq('user_goal_id', userGoalId);
    }

    final res = await q.order('created_at', ascending: false);
    final rows = (res as List).cast<Map<String, dynamic>>();
    final visibleRows = await _filterRowsByActiveSpaces(rows);

    final decryptedRows = await Future.wait(
      visibleRows.map(_decryptGoalRow),
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
    String? spaceId,
    String? assignedTo,
    String? visibility,
  }) async {
    final normalizedSpaceId = _nullIfBlank(spaceId);
    final isSpaceGoal = normalizedSpaceId != null;

    final insert = <String, dynamic>{
      'user_id': uid,
      ...await _textStorageForGoal(
        title: title,
        description: description,
        emotion: emotion,
        isSpaceGoal: isSpaceGoal,
      ),
      'deadline': deadline.toIso8601String(),
      'is_completed': false,
      'life_block': lifeBlock,
      'importance': importance,
      'spent_hours': spentHours,
      'start_time': startTime.toIso8601String(),
      'user_goal_id': userGoalId,
      'space_id': normalizedSpaceId,
      'assigned_to': isSpaceGoal ? _nullIfBlank(assignedTo) : null,
      'visibility': visibility ?? (isSpaceGoal ? 'space' : 'private'),
      'completed_by': null,
      'completed_at': null,
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
          final normalizedSpaceId = _nullIfBlank(item['space_id']?.toString());
          final isSpaceGoal = normalizedSpaceId != null;

          return <String, dynamic>{
            'user_id': uid,
            ...await _textStorageForGoal(
              title: title,
              description: description,
              emotion: emotion,
              isSpaceGoal: isSpaceGoal,
            ),
            'deadline': _asIsoString(item['deadline']),
            'is_completed': item['is_completed'] ?? false,
            'life_block': item['life_block'] ?? 'general',
            'importance': item['importance'] ?? 1,
            'spent_hours': _asDouble(item['spent_hours'] ?? 1.0),
            'start_time': _asIsoString(item['start_time']),
            'user_goal_id': item['user_goal_id'],
            'space_id': normalizedSpaceId,
            'assigned_to': isSpaceGoal ? _nullIfBlank(item['assigned_to']?.toString()) : null,
            'visibility': item['visibility'] ?? (isSpaceGoal ? 'space' : 'private'),
            if (item.containsKey('completed_by')) 'completed_by': item['completed_by'],
            if (item.containsKey('completed_at')) 'completed_at': item['completed_at'],
            if (item.containsKey('is_recurring'))
              'is_recurring': item['is_recurring'] == true,
            if (item.containsKey('recurring_group_id'))
              'recurring_group_id': item['recurring_group_id'],
            if (item.containsKey('recurrence_type'))
              'recurrence_type': item['recurrence_type'],
            if (item.containsKey('recurrence_every_n_days'))
              'recurrence_every_n_days': item['recurrence_every_n_days'],
            if (item.containsKey('recurrence_weekdays'))
              'recurrence_weekdays': item['recurrence_weekdays'],
            if (item.containsKey('recurrence_until'))
              'recurrence_until': item['recurrence_until'],
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
    final dynamic dynamicGoal = goal;
    final String? spaceId = _safeString(() => dynamicGoal.spaceId);
    final String? assignedTo = _safeString(() => dynamicGoal.assignedTo);
    final normalizedSpaceId = _nullIfBlank(spaceId);
    final isSpaceGoal = normalizedSpaceId != null;

    await client
        .from('goals')
        .update({
          ...await _textStorageForGoal(
            title: goal.title,
            description: goal.description,
            emotion: goal.emotion,
            isSpaceGoal: isSpaceGoal,
          ),
          'deadline': goal.deadline.toIso8601String(),
          'is_completed': goal.isCompleted,
          'life_block': goal.lifeBlock,
          'importance': goal.importance,
          'spent_hours': goal.spentHours,
          'start_time': goal.startTime.toIso8601String(),
          'user_goal_id': _extractUserGoalId(goal),
          'space_id': normalizedSpaceId,
          'assigned_to': isSpaceGoal ? _nullIfBlank(assignedTo) : null,
          'visibility': isSpaceGoal ? 'space' : 'private',
        })
        .eq('id', goal.id);
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
    Object? spaceId = _unset,
    Object? assignedTo = _unset,
    String? visibility,
  }) async {
    final update = <String, dynamic>{};

    final current = await client
        .from('goals')
        .select('id, title, description, emotion, encrypted_payload, space_id, assigned_to, visibility')
        .eq('id', goalId)
        .maybeSingle();

    if (current == null) return;

    final currentRow = await _decryptGoalRow(
      (current as Map).cast<String, dynamic>(),
    );

    final currentSpaceId = _nullIfBlank(currentRow['space_id']?.toString());
    final nextSpaceId = identical(spaceId, _unset)
        ? currentSpaceId
        : _nullIfBlank(spaceId?.toString());
    final isSpaceGoal = nextSpaceId != null;

    final shouldUpdateText = title != null ||
        description != null ||
        emotion != null ||
        !identical(spaceId, _unset);

    if (shouldUpdateText) {
      final mergedTitle = title ?? (currentRow['title'] ?? '').toString();
      final mergedDescription =
          description ?? (currentRow['description'] ?? '').toString();
      final mergedEmotion = emotion ?? (currentRow['emotion'] ?? '').toString();

      update.addAll(await _textStorageForGoal(
        title: mergedTitle,
        description: mergedDescription,
        emotion: mergedEmotion,
        isSpaceGoal: isSpaceGoal,
      ));
    }

    if (deadline != null) update['deadline'] = deadline.toIso8601String();
    if (isCompleted != null) {
      update['is_completed'] = isCompleted;
      if (isCompleted) {
        update['completed_by'] = uid;
        update['completed_at'] = DateTime.now().toUtc().toIso8601String();
      } else {
        update['completed_by'] = null;
        update['completed_at'] = null;
      }
    }
    if (lifeBlock != null) update['life_block'] = lifeBlock;
    if (importance != null) update['importance'] = importance;
    if (spentHours != null) update['spent_hours'] = spentHours;
    if (startTime != null) update['start_time'] = startTime.toIso8601String();

    if (!identical(userGoalId, _unset)) {
      update['user_goal_id'] = userGoalId;
    }

    if (!identical(spaceId, _unset)) {
      update['space_id'] = nextSpaceId;
      update['visibility'] = visibility ?? (isSpaceGoal ? 'space' : 'private');
      if (!isSpaceGoal) {
        update['assigned_to'] = null;
      }
    }

    if (!identical(assignedTo, _unset)) {
      update['assigned_to'] = isSpaceGoal ? _nullIfBlank(assignedTo?.toString()) : null;
    }

    if (visibility != null) update['visibility'] = visibility;

    if (update.isEmpty) return;

    await client.from('goals').update(update).eq('id', goalId);
  }

  Future<void> deleteGoal(String id) async {
    final dynamic idValue = int.tryParse(id) ?? id;

    final res = await client
        .from('goals')
        .delete()
        .eq('id', idValue)
        .select('id');

    final deleted = (res as List).cast<Map<String, dynamic>>();
    if (deleted.isEmpty) {
      final still = await client
          .from('goals')
          .select('id,user_id,space_id')
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
    String? spaceId,
    bool personalOnly = false,
  }) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    var q = client
        .from('goals')
        .select()
        .gte('deadline', start.toIso8601String())
        .lt('deadline', end.toIso8601String());

    if (personalOnly) {
      q = q.eq('user_id', uid).isFilter('space_id', null);
    } else if (_hasText(spaceId)) {
      q = q.eq('space_id', spaceId!);
    }

    if (lifeBlock != null) {
      q = q.eq('life_block', lifeBlock);
    }
    if (userGoalId != null) {
      q = q.eq('user_goal_id', userGoalId);
    }

    final res = await q.order('start_time', ascending: true);
    final rows = (res as List).cast<Map<String, dynamic>>();
    final visibleRows = await _filterRowsByActiveSpaces(rows);

    final decryptedRows = await Future.wait(
      visibleRows.map(_decryptGoalRow),
    );

    return decryptedRows.map(Goal.fromMap).toList();
  }

  Future<List<Goal>> getGoalsLinkedToUserGoal(String userGoalId) async {
    final res = await client
        .from('goals')
        .select()
        .eq('user_goal_id', userGoalId)
        .order('start_time', ascending: true);

    final rows = (res as List).cast<Map<String, dynamic>>();
    final visibleRows = await _filterRowsByActiveSpaces(rows);

    final decryptedRows = await Future.wait(
      visibleRows.map(_decryptGoalRow),
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
        .maybeSingle();
    if (row == null) return;

    final newVal = value ?? !(row['is_completed'] as bool? ?? false);

    await client
        .from('goals')
        .update({
          'is_completed': newVal,
          'completed_by': newVal ? uid : null,
          'completed_at': newVal ? DateTime.now().toUtc().toIso8601String() : null,
        })
        .eq('id', id);

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
  // Recurring tasks
  // =========================

  Future<List<Map<String, dynamic>>> listRecurringTaskPlans() async {
    final res = await client
        .from('goals')
        .select(
          'id, title, description, emotion, encrypted_payload, deadline, life_block, importance, spent_hours, start_time, user_goal_id, space_id, assigned_to, visibility, is_recurring, recurring_group_id, recurrence_type, recurrence_every_n_days, recurrence_weekdays, recurrence_until',
        )
        .eq('is_recurring', true)
        .order('deadline', ascending: true);

    final rows = (res as List).cast<Map<String, dynamic>>();
    final visibleRows = await _filterRowsByActiveSpaces(rows);
    final decryptedRows = await Future.wait(visibleRows.map(_decryptGoalRow));

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final row in decryptedRows) {
      final groupId = (row['recurring_group_id'] ?? '').toString().trim();
      if (groupId.isEmpty) continue;
      grouped.putIfAbsent(groupId, () => <Map<String, dynamic>>[]).add(row);
    }

    final result = <Map<String, dynamic>>[];
    for (final entry in grouped.entries) {
      final items = entry.value
        ..sort((a, b) => _dateFromAny(a['deadline']).compareTo(_dateFromAny(b['deadline'])));
      final first = items.first;
      final last = items.last;

      result.add(<String, dynamic>{
        'recurring_group_id': entry.key,
        'title': (first['title'] ?? '').toString(),
        'description': (first['description'] ?? '').toString(),
        'life_block': (first['life_block'] ?? 'general').toString(),
        'importance': int.tryParse((first['importance'] ?? 2).toString()) ?? 2,
        'emotion': (first['emotion'] ?? '').toString(),
        'spent_hours': _asDouble(first['spent_hours'] ?? 1.0),
        'start_time': first['start_time'],
        'user_goal_id': first['user_goal_id'],
        'space_id': first['space_id'],
        'assigned_to': first['assigned_to'],
        'visibility': first['visibility'],
        'recurrence_type': (first['recurrence_type'] ?? 'every_n_days').toString(),
        'recurrence_every_n_days': int.tryParse((first['recurrence_every_n_days'] ?? 2).toString()) ?? 2,
        'recurrence_weekdays': first['recurrence_weekdays'],
        'recurrence_until': first['recurrence_until'] ?? last['deadline'],
        'instances': items.length,
      });
    }

    result.sort(
      (a, b) => (a['title'] ?? '')
          .toString()
          .toLowerCase()
          .compareTo((b['title'] ?? '').toString().toLowerCase()),
    );

    return result;
  }

  Future<List<Goal>> createRecurringTaskPlan(
    List<Map<String, dynamic>> items,
  ) {
    return createGoalsBulk(
      items
          .map(
            (item) => <String, dynamic>{
              ...item,
              'is_recurring': true,
            },
          )
          .toList(),
    );
  }

  Future<List<Goal>> replaceRecurringTaskPlan({
    required String recurringGroupId,
    required List<Map<String, dynamic>> items,
  }) async {
    await deleteRecurringTaskPlan(recurringGroupId);
    return createRecurringTaskPlan(items);
  }

  Future<void> deleteRecurringTaskPlan(String recurringGroupId) async {
    if (recurringGroupId.trim().isEmpty) return;

    await client
        .from('goals')
        .delete()
        .eq('recurring_group_id', recurringGroupId);
  }

  DateTime _dateFromAny(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.fromMillisecondsSinceEpoch(0);
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
          'id, title, description, emotion, encrypted_payload, created_at, deadline, life_block, user_goal_id, space_id',
        );

    if (lifeBlock != null) {
      req = req.eq('life_block', lifeBlock);
    }
    if (userGoalId != null) {
      req = req.eq('user_goal_id', userGoalId);
    }

    // Server-side ILIKE is not possible for encrypted private titles.
    // We fetch recent rows and filter locally after decryption.
    final rows = await req.order('created_at', ascending: false).limit(300);
    final rawRows = (rows as List).cast<Map<String, dynamic>>();
    final visibleRows = await _filterRowsByActiveSpaces(rawRows);

    final decryptedRows = await Future.wait(
      visibleRows.map(_decryptGoalRow),
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
          'id, title, description, emotion, encrypted_payload, deadline, life_block, user_goal_id, space_id',
        )
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
    final visibleRows = await _filterRowsByActiveSpaces(rows);

    return Future.wait(
      visibleRows.map(_decryptGoalRow),
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
          'id, title, description, emotion, encrypted_payload, deadline, life_block, user_goal_id, space_id',
        )
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
    final visibleRows = await _filterRowsByActiveSpaces(rows);

    final decryptedRows = await Future.wait(
      visibleRows.map(_decryptGoalRow),
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
    String? spaceId,
    bool personalOnly = false,
  }) async {
    var q = client
        .from('goals')
        .select()
        .gte('start_time', start.toIso8601String())
        .lt('start_time', end.toIso8601String());

    if (personalOnly) {
      q = q.eq('user_id', uid).isFilter('space_id', null);
    } else if (_hasText(spaceId)) {
      q = q.eq('space_id', spaceId!);
    }

    if (lifeBlock != null) {
      q = q.eq('life_block', lifeBlock);
    }
    if (userGoalId != null) {
      q = q.eq('user_goal_id', userGoalId);
    }

    final res = await q.order('start_time', ascending: true);
    final rows = (res as List).cast<Map<String, dynamic>>();
    final visibleRows = await _filterRowsByActiveSpaces(rows);

    final decryptedRows = await Future.wait(
      visibleRows.map(_decryptGoalRow),
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
        .select('spent_hours, life_block, user_goal_id, space_id')
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
    final visibleRows = await _filterRowsByActiveSpaces(rows);

    return visibleRows.fold<double>(
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

  Future<Map<String, dynamic>> _textStorageForGoal({
    required String title,
    required String description,
    required String emotion,
    required bool isSpaceGoal,
  }) async {
    if (isSpaceGoal) {
      return <String, dynamic>{
        // Shared tasks are intentionally stored in readable columns for all
        // active members of the space. Personal tasks remain encrypted below.
        'title': title.trim(),
        'description': description.trim(),
        'emotion': emotion.trim(),
        'encrypted_payload': null,
      };
    }

    final encryptedPayload = await _encryptGoalPayload(
      title: title,
      description: description,
      emotion: emotion,
    );

    return <String, dynamic>{
      // Technical fallback. Real personal text is stored in encrypted_payload.
      'title': '',
      'description': '',
      'emotion': '',
      'encrypted_payload': encryptedPayload,
    };
  }

  Future<Map<String, dynamic>> _decryptGoalRow(Map<String, dynamic> row) async {
    final copy = Map<String, dynamic>.from(row);
    final encryptedPayload = copy['encrypted_payload'];

    if (encryptedPayload == null) {
      // Legacy/plain rows and shared space tasks.
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

      final decryptedTitle = (payload['title'] ?? copy['title'] ?? '').toString();
      final decryptedDescription =
          (payload['description'] ?? copy['description'] ?? '').toString();
      final decryptedEmotion =
          (payload['emotion'] ?? copy['emotion'] ?? '').toString();

      copy['title'] = decryptedTitle;
      copy['description'] = decryptedDescription;
      copy['emotion'] = decryptedEmotion;

      // Auto-fix old encrypted shared tasks when the creator/device that can
      // decrypt them opens the app. Other members cannot decrypt old rows, but
      // once the owner loads them once, everybody will see the plain text.
      await _publishDecryptableSpaceGoalIfNeeded(
        originalRow: row,
        title: decryptedTitle,
        description: decryptedDescription,
        emotion: decryptedEmotion,
      );

      return copy;
    } catch (_) {
      // If decryption fails, do not crash the whole screen.
      // For shared tasks created after this fix, encrypted_payload is null and
      // plain columns are used, so other members will see the text.
      copy['title'] = (copy['title'] ?? '').toString();
      copy['description'] = (copy['description'] ?? '').toString();
      copy['emotion'] = (copy['emotion'] ?? '').toString();
      return copy;
    }
  }

  Future<void> _publishDecryptableSpaceGoalIfNeeded({
    required Map<String, dynamic> originalRow,
    required String title,
    required String description,
    required String emotion,
  }) async {
    final id = originalRow['id'];
    final spaceId = _nullIfBlank(originalRow['space_id']?.toString());
    final encryptedPayload = originalRow['encrypted_payload'];
    if (id == null || spaceId == null || encryptedPayload == null) return;

    final plainTitle = (originalRow['title'] ?? '').toString().trim();
    final plainDescription = (originalRow['description'] ?? '').toString().trim();
    final alreadyPlain = plainTitle.isNotEmpty || plainDescription.isNotEmpty;
    if (alreadyPlain) return;
    if (title.trim().isEmpty && description.trim().isEmpty && emotion.trim().isEmpty) return;

    try {
      await client.from('goals').update({
        'title': title.trim(),
        'description': description.trim(),
        'emotion': emotion.trim(),
        'encrypted_payload': null,
        'visibility': 'space',
      }).eq('id', id);
    } catch (_) {
      // Ignore: the current user may not have permission to update this row.
    }
  }

  // =========================
  // Active-space filtering
  // =========================

  Future<Set<String>> _activeSpaceIds() async {
    final today = DateTime.now().toUtc().toIso8601String().split('T').first;

    try {
      final rows = await client
          .from('spaces')
          .select('id')
          .or('valid_until.is.null,valid_until.gte.$today');

      return (rows as List)
          .map((row) => (row as Map)['id']?.toString())
          .whereType<String>()
          .toSet();
    } catch (_) {
      // If valid_until migration was not applied yet, do not break the app.
      final rows = await client.from('spaces').select('id');
      return (rows as List)
          .map((row) => (row as Map)['id']?.toString())
          .whereType<String>()
          .toSet();
    }
  }

  Future<List<Map<String, dynamic>>> _filterRowsByActiveSpaces(
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) return rows;

    final hasSpaceRows = rows.any((row) => _nullIfBlank(row['space_id']?.toString()) != null);
    if (!hasSpaceRows) return rows;

    final activeIds = await _activeSpaceIds();
    return rows.where((row) {
      final rowSpaceId = _nullIfBlank(row['space_id']?.toString());
      if (rowSpaceId == null) return true;
      return activeIds.contains(rowSpaceId);
    }).toList();
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

  String? _safeString(String? Function() read) {
    try {
      return read();
    } catch (_) {
      return null;
    }
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

  String? _nullIfBlank(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
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
