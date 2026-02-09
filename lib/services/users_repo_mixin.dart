import 'core/base_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // для PostgrestException

mixin UsersRepoMixin on BaseRepo {
  Future<List<String>> getUserLifeBlocks() async {
    final res = await client
        .from('users')
        .select('life_blocks')
        .eq('id', uid)
        .maybeSingle();

    final list = res?['life_blocks'] as List?;
    if (list == null) return [];
    return List<String>.from(list);
  }

  /// Сохраняем приоритеты. Если в схеме есть `weights/target_hours` — запишем и их.
  /// Если колонок нет (42703) — тихо фолбэкаемся на обновление только `priorities`.
  Future<void> saveUserSettings({
    required Map<String, double> weights,
    required double targetHours,
  }) async {
    try {
      await client
          .from('users')
          .update({
            'priorities': weights.keys.toList(),
            'weights': weights.values.toList(),
            'target_hours': targetHours,
          })
          .eq('id', uid);
    } on PostgrestException catch (e) {
      // 42703 = column does not exist
      if (e.code == '42703' || e.message.toLowerCase().contains('column')) {
        await client
            .from('users')
            .update({'priorities': weights.keys.toList()})
            .eq('id', uid);
      } else {
        rethrow;
      }
    }
  }

  /// Возвращает вес блока, если есть колонки `priorities/weights`.
  /// Если их нет/пусто — 1.0 по умолчанию.
  Future<double> getLifeBlockWeight(String block) async {
    try {
      final res = await client
          .from('users')
          .select('priorities, weights')
          .eq('id', uid)
          .maybeSingle();

      if (res == null) return 1.0;

      final prioritiesList = (res['priorities'] as List?) ?? const [];
      final idx = prioritiesList.indexOf(block);
      if (idx == -1) return 1.0;

      final weightsList = (res['weights'] as List?) ?? const [];
      final w = idx < weightsList.length ? weightsList[idx] : null;
      return (w as num?)?.toDouble() ?? 1.0;
    } on PostgrestException catch (e) {
      if (e.code == '42703' || e.message.toLowerCase().contains('column')) {
        return 1.0;
      }
      rethrow;
    }
  }

  /// Возвращает строку users с полями опросника и стартового флоу.
  Future<Map<String, dynamic>> getQuestionnaireResults() async {
    final row = await client
        .from('users')
        .select('''
          id, email, name,
          has_completed_questionnaire,
          sleep, activity, energy, stress, finance_satisfaction,
          priorities, life_blocks, dreams_by_block, goals_by_block,
          has_seen_intro, archetype
        ''')
        .eq('id', uid)
        .maybeSingle();

    return row ?? {};
  }
}
