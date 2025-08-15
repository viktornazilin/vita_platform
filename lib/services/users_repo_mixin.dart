import 'core/base_repo.dart';

mixin UsersRepoMixin on BaseRepo {
  Future<List<String>> getUserLifeBlocks() async {
    final res = await client.from('users').select('life_blocks').eq('id', uid).maybeSingle();
    if (res == null || res['life_blocks'] == null) return [];
    return List<String>.from(res['life_blocks'] as List);
  }

  Future<void> saveUserSettings({
    required Map<String, double> weights,
    required double targetHours,
  }) async {
    await client.from('users').update({
      'priorities': weights.keys.toList(),
      'weights': weights.values.toList(),
      'target_hours': targetHours,
    }).eq('id', uid);
  }

  Future<double> getLifeBlockWeight(String block) async {
    final res = await client.from('users').select('priorities, weights').eq('id', uid).maybeSingle();
    if (res == null || res['priorities'] == null) return 1.0;
    final idx = (res['priorities'] as List).indexOf(block);
    if (idx == -1) return 1.0;
    return (res['weights'][idx] as num).toDouble();
  }

  Future<Map<String, dynamic>?> getQuestionnaireResults() async {
    final res = await client
        .from('users')
        .select('has_completed_questionnaire, age, health, goals, dreams, strengths, weaknesses, priorities, life_blocks')
        .eq('id', uid)
        .maybeSingle();
    if (res == null) return null;
    return Map<String, dynamic>.from(res as Map);
  }
}
