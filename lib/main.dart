import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'models/app_user.dart';
import 'models/goal.dart';
import 'models/mood.dart';
import 'models/xp.dart';
import 'models/life_block.dart';
import 'services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Регистрируем адаптеры только если они ещё не зарегистрированы
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AppUserAdapter());
  }

  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(GoalAdapter());
  }

  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(MoodAdapter());
  }

  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(XPAdapter());
  }

  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(LifeBlockAdapter());
  }

  // Открываем боксы
  await Hive.openBox<AppUser>('users');
  await Hive.openBox<Goal>('goals');
  await Hive.openBox<Mood>('moods');
  await Hive.openBox<XP>('xp');

  // Инициализируем сервис
  await UserService().init();

  runApp(const VitaApp());
}
