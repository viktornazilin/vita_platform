// lib/services/user_goals_repo_mixin.dart
//
// Repo для таблицы public.user_goals
// Поддерживает: список целей, upsert, delete, получение по life_block и по диапазону дат.
//
// ОЖИДАЕМАЯ СХЕМА (минимум):
// - id (uuid) PK
// - user_id (uuid)
// - life_block (text)         // например "career"
// - horizon (text)            // "tactical" | "mid" | "long"
// - title (text)
// - description (text) NULL
// - target_date (date) NULL
// - created_at (timestamptz) default now()
//
// Если названия колонок отличаются — скажи какие, я подгоню 1-в-1.

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
      // DATE может прийти как 'YYYY-MM-DD' или timestamptz
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
      // created_at не трогаем — пусть проставляет БД
    };
  }
}

/// DTO для создания/апдейта
class UserGoalUpsert {
  final String? id; // null -> insert (БД сгенерит или ты передашь uuid)
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
  Future<List<UserGoal>> listGoals({String? lifeBlock, GoalHorizon? horizon});

  Future<Map<String, List<UserGoal>>> listGoalsGroupedByBlock({
    GoalHorizon? horizon,
  });

  Future<void> upsertGoals(List<UserGoalUpsert> goals);

  Future<void> deleteGoal(String goalId);

  /// Удобно для "периодных" отчётов (если нужно)
  Future<List<UserGoal>> listGoalsWithTargetDateInRange(
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
  Future<List<UserGoal>> listGoals({
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
  Future<Map<String, List<UserGoal>>> listGoalsGroupedByBlock({
    GoalHorizon? horizon,
  }) async {
    final list = await listGoals(horizon: horizon);
    final out = <String, List<UserGoal>>{};
    for (final g in list) {
      out.putIfAbsent(g.lifeBlock, () => []).add(g);
    }
    return out;
  }

  @override
  Future<void> upsertGoals(List<UserGoalUpsert> goals) async {
    if (goals.isEmpty) return;

    final rows = goals.map((g) {
      final titleT = g.title.trim();
      if (titleT.isEmpty) {
        // Не кидаем исключение, просто сохраним пустое как невалидное не будем:
        // Но лучше на UI не допускать.
      }

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

    // если id есть — upsert по id, если id нет — Supabase вставит (если у тебя default uuid)
    // Вариант 1: onConflict: 'id' (самый простой)
    await client.from('user_goals').upsert(rows, onConflict: 'id');
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    final id = goalId.trim();
    if (id.isEmpty) return;

    await client.from('user_goals').delete().eq('user_id', uid).eq('id', id);
  }

  @override
  Future<List<UserGoal>> listGoalsWithTargetDateInRange(
    DateTime start,
    DateTime end,
  ) async {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);

    // В Postgres DATE сравнения включительные/исключительные — тут делаем включительно:
    // target_date >= start AND target_date <= end
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
