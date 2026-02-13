import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'secrets.dart';
import 'app.dart';
import 'services/db_repo.dart';
import 'controllers/theme_controller.dart';
import 'controllers/locale_controller.dart';

// ✅ Web notifications (работают в браузере, пока приложение открыто)
import 'services/web_notifications_service.dart';

// Делаем репозиторий доступным по всему приложению
late final DbRepo dbRepo;

// ✅ глобальный сервис web-уведомлений (можно использовать в Settings и т.д.)
late final WebNotificationsService webNotifs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  dbRepo = DbRepo(Supabase.instance.client);

  // ✅ init web notifications (без запроса permission — его лучше делать по кнопке в UI)
  webNotifs = WebNotificationsService();
  await webNotifs.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()..load()),
        ChangeNotifierProvider(create: (_) => LocaleController()..init()),
      ],
      child: const VitaApp(),
    ),
  );
}
