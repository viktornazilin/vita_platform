import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/base_repo.dart';
import 'finance_repo_mixin.dart';
import 'goals_repo_mixin.dart';
import 'moods_repo_mixin.dart';
import 'xp_repo_mixin.dart';
import 'users_repo_mixin.dart';
import 'legacy_expenses_mixin.dart';

class DbRepo extends BaseRepo
    with
        FinanceRepoMixin,
        GoalsRepoMixin,
        MoodsRepoMixin,
        XpRepoMixin,
        UsersRepoMixin,
        LegacyExpensesRepoMixin
    implements FinanceRepo {
  DbRepo(super.client);
}
