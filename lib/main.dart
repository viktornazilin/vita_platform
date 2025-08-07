import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'secrets.dart';
import 'app.dart';
import 'services/db_repo.dart';

// Делаем репозиторий доступным по всему приложению
late final DbRepo dbRepo;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  dbRepo = DbRepo(Supabase.instance.client);
  runApp(const VitaApp());
}
