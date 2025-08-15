import 'core/base_repo.dart';
import '../models/xp.dart';

mixin XpRepoMixin on BaseRepo {
  Future<XP> getXP() async {
    final res = await client.from('user_xp').select().eq('user_id', uid).maybeSingle();
    if (res == null) {
      final created = await client.from('user_xp').insert({'user_id': uid}).select().single();
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
}
