// lib/services/user_goals_repo_mixin.dart
//
// Repo для таблицы public.user_goals
// Поддерживает: список целей, upsert, delete, получение по life_block и по диапазону дат.

import 'core/base_repo.dart';

enum GoalHorizon { tactical, mid, long }

extension GoalHorizonX on GoalHorizon {
  String get db => switch (this) {
    GoalHorizon.tactical => 'tactical',
    GoalHorizon.mid => 'mid',
    GoalHorizon.long => 'long',
  };

  static GoalHorizon fromDb(String? v) {
    switch ((v ?? '').toLowerCase()) {
      case 'tactical':
        return GoalHorizon.tactical;
      case 'mid':
      case 'midterm':
      case 'mid_term':
        return GoalHorizon.mid;
      case 'long':
      case 'longterm':
      case 'long_term':
        return GoalHorizon.long;
      default:
        return GoalHorizon.mid;
    }
  }
}

/// Модель (простая DTO) для user_goals
class UserGoal {
  final String id;
  final String userId;
  final String lifeBlock; // text
  final GoalHorizon horizon;
  final String title;
  final String description;
  final DateTime? targetDate; // date-only
  final DateTime? createdAt;

  UserGoal({
    required this.id,
    required this.userId,
    required this.lifeBlock,
    required this.horizon,
    required this.title,
    this.description = '',
    this.targetDate,
    this.createdAt,
  });

  factory UserGoal.fromMap(Map<String, dynamic> m) {
    DateTime? _parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return DateTime(v.year, v.month, v.day);
      final s = v.toString();
      if (s.isEmpty) return null;
      final dt = DateTime.tryParse(s);
      if (dt == null) return null;
      return DateTime(dt.year, dt.month, dt.day);
    }

    DateTime? _parseTs(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      final s = v.toString();
      if (s.isEmpty) return null;
      return DateTime.tryParse(s);
    }

    return UserGoal(
      id: (m['id'] ?? '').toString(),
      userId: (m['user_id'] ?? '').toString(),
      lifeBlock: (m['life_block'] ?? '').toString(),
      horizon: GoalHorizonX.fromDb(m['horizon']?.toString()),
      title: (m['title'] ?? '').toString(),
      description: (m['description'] ?? '').toString(),
      targetDate: _parseDate(m['target_date']),
      createdAt: _parseTs(m['created_at']),
    );
  }

  Map<String, dynamic> toUpsertRow({required String userId, String? id}) {
    String? dateOnly(DateTime? d) {
      if (d == null) return null;
      final x = DateTime(d.year, d.month, d.day);
      return '${x.year.toString().padLeft(4, '0')}-'
          '${x.month.toString().padLeft(2, '0')}-'
          '${x.day.toString().padLeft(2, '0')}';
    }

    final titleT = title.trim();
    final descT = description.trim();

    return <String, dynamic>{
      if (id != null && id.isNotEmpty) 'id': id,
      'user_id': userId,
      'life_block': lifeBlock,
      'horizon': horizon.db,
      'title': titleT,
      'description': descT.isEmpty ? null : descT,
      'target_date': dateOnly(targetDate),
    };
  }
}

/// DTO для создания/апдейта
class UserGoalUpsert {
  final String? id; // null -> insert
  final String lifeBlock;
  final GoalHorizon horizon;
  final String title;
  final String description;
  final DateTime? targetDate;

  UserGoalUpsert({
    this.id,
    required this.lifeBlock,
    required this.horizon,
    required this.title,
    this.description = '',
    this.targetDate,
  });
}

abstract class UserGoalsRepo {
  // ✅ переименовано, чтобы не конфликтовать с GoalsRepoMixin.fetchGoals
  Future<List<UserGoal>> listUserGoals({
    String? lifeBlock,
    GoalHorizon? horizon,
  });

  Future<Map<String, List<UserGoal>>> listUserGoalsGroupedByBlock({
    GoalHorizon? horizon,
  });

  // ✅ переименовано, чтобы не конфликтовать с GoalsRepoMixin.createGoal/updateGoal/deleteGoal
  Future<void> upsertUserGoals(List<UserGoalUpsert> goals);
  Future<void> deleteUserGoal(String goalId);

  Future<List<UserGoal>> listUserGoalsWithTargetDateInRange(
    DateTime start,
    DateTime end,
  );
}

mixin UserGoalsRepoMixin on BaseRepo implements UserGoalsRepo {
  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  Future<List<UserGoal>> listUserGoals({
    String? lifeBlock,
    GoalHorizon? horizon,
  }) async {
    var q = client.from('user_goals').select().eq('user_id', uid);

    if (lifeBlock != null && lifeBlock.trim().isNotEmpty) {
      q = q.eq('life_block', lifeBlock.trim());
    }
    if (horizon != null) {
      q = q.eq('horizon', horizon.db);
    }

    final res = await q
        .order('life_block', ascending: true)
        .order('horizon', ascending: true)
        .order('created_at', ascending: false);

    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(UserGoal.fromMap)
        .toList();
  }

  @override
  Future<Map<String, List<UserGoal>>> listUserGoalsGroupedByBlock({
    GoalHorizon? horizon,
  }) async {
    final list = await listUserGoals(horizon: horizon);
    final out = <String, List<UserGoal>>{};
    for (final g in list) {
      out.putIfAbsent(g.lifeBlock, () => []).add(g);
    }
    return out;
  }

  @override
  Future<void> upsertUserGoals(List<UserGoalUpsert> goals) async {
    if (goals.isEmpty) return;

    final rows = goals.map((g) {
      final titleT = g.title.trim();

      final row = UserGoal(
        id: g.id ?? '',
        userId: uid,
        lifeBlock: g.lifeBlock.trim(),
        horizon: g.horizon,
        title: titleT,
        description: g.description.trim(),
        targetDate: g.targetDate == null
            ? null
            : DateTime(
                g.targetDate!.year,
                g.targetDate!.month,
                g.targetDate!.day,
              ),
      ).toUpsertRow(userId: uid, id: g.id);

      return row;
    }).toList();

    await client.from('user_goals').upsert(rows, onConflict: 'id');
  }

  @override
  Future<void> deleteUserGoal(String goalId) async {
    final id = goalId.trim();
    if (id.isEmpty) return;

    // делаем delete "наблюдаемым": вернём id удалённых строк
    final res = await client
        .from('user_goals')
        .delete()
        .eq('user_id', uid)
        .eq('id', id)
        .select('id');

    final deleted = (res as List).cast<Map<String, dynamic>>();
    if (deleted.isEmpty) {
      throw Exception('UserGoal delete matched 0 rows. uid=$uid id=$id');
    }
  }

  @override
  Future<List<UserGoal>> listUserGoalsWithTargetDateInRange(
    DateTime start,
    DateTime end,
  ) async {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);

    final res = await client
        .from('user_goals')
        .select()
        .eq('user_id', uid)
        .gte('target_date', _dateOnly(s))
        .lte('target_date', _dateOnly(e))
        .order('target_date', ascending: true)
        .order('created_at', ascending: false);

    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(UserGoal.fromMap)
        .toList();
  }
}
