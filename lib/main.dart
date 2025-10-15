import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'secrets.dart';
import 'app.dart';
import 'services/db_repo.dart';
import 'controllers/theme_controller.dart';

// Делаем репозиторий доступным по всему приложению
late final DbRepo dbRepo;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  dbRepo = DbRepo(Supabase.instance.client);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()..load()),
      ],
      child: const VitaApp(),
    ),
  );
}
