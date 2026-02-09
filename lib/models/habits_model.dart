// lib/models/habits_model.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'habit.dart';

class HabitsModel extends ChangeNotifier {
  final _sb = Supabase.instance.client;

  bool loading = false;
  String? error;
  List<Habit> items = [];

  String? get _uid => _sb.auth.currentUser?.id;

  Future<void> load() async {
    error = null;

    final uid = _uid;
    if (uid == null) {
      items = [];
      error = 'Not authenticated';
      notifyListeners();
      return;
    }

    loading = true;
    notifyListeners();

    try {
      final res = await _sb
          .from('habits')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: true);

      final list = (res as List)
          .cast<Map<String, dynamic>>()
          .map((m) => Habit.fromMap(m))
          .toList();

      items = list;
    } catch (e) {
      error = 'Не удалось загрузить привычки: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<String?> create({
    required String title,
    required bool isNegative,
  }) async {
    final uid = _uid;
    if (uid == null) return 'Not authenticated';

    error = null;
    notifyListeners();

    try {
      final inserted = await _sb
          .from('habits')
          .insert({'user_id': uid, 'title': title, 'is_negative': isNegative})
          .select()
          .single();

      final h = Habit.fromMap((inserted as Map).cast<String, dynamic>());
      items = [...items, h];
      notifyListeners();
      return null;
    } catch (e) {
      return 'Не удалось создать привычку: $e';
    }
  }

  Future<String?> update(
    String id, {
    required String title,
    required bool isNegative,
  }) async {
    final uid = _uid;
    if (uid == null) return 'Not authenticated';

    error = null;
    notifyListeners();

    try {
      final updated = await _sb
          .from('habits')
          .update({'title': title, 'is_negative': isNegative})
          .eq('id', id)
          .eq('user_id', uid)
          .select()
          .single();

      final h = Habit.fromMap((updated as Map).cast<String, dynamic>());
      final idx = items.indexWhere((x) => x.id == id);
      if (idx >= 0) {
        final next = [...items];
        next[idx] = h;
        items = next;
      } else {
        // если вдруг локально не было
        items = [...items, h];
      }

      notifyListeners();
      return null;
    } catch (e) {
      return 'Не удалось обновить привычку: $e';
    }
  }

  Future<String?> delete(String id) async {
    final uid = _uid;
    if (uid == null) return 'Not authenticated';

    error = null;
    notifyListeners();

    try {
      await _sb.from('habits').delete().eq('id', id).eq('user_id', uid);
      items = items.where((x) => x.id != id).toList();
      notifyListeners();
      return null;
    } catch (e) {
      return 'Не удалось удалить привычку: $e';
    }
  }
}
