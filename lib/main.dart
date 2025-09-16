import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // ⬅️ добавили

import 'secrets.dart';
import 'app.dart';
import 'services/db_repo.dart';

// Делаем репозиторий доступным по всему приложению
late final DbRepo dbRepo;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⬅️ важно вызвать до runApp (на mobile — просто no-op)
  usePathUrlStrategy();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  dbRepo = DbRepo(Supabase.instance.client);
  runApp(const VitaApp());
}
