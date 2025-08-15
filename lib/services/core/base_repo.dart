import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BaseRepo {
  final SupabaseClient client;
  BaseRepo(this.client);

  String get uid {
    final u = client.auth.currentUser?.id;
    if (u == null) throw StateError('Not authenticated');
    return u;
  }

  String d(DateTime x) =>
      '${x.year.toString().padLeft(4, '0')}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}';

  DateTime dayStart(DateTime x) => DateTime(x.year, x.month, x.day);
  DateTime monthStart(DateTime x) => DateTime(x.year, x.month, 1);
  DateTime nextMonth(DateTime x) => DateTime(x.year, x.month + 1, 1);
}
