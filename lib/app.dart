import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/user_service.dart';
import 'models/register_model.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_questionnaire_screen.dart';
import 'screens/settings_screen.dart' as screens;
import 'screens/expenses_screen.dart';
import 'screens/budget_setup_screen.dart';
import 'screens/epic_intro_screen.dart';
import 'screens/archetype_select_screen.dart';
import 'controllers/theme_controller.dart';
import 'main.dart'; // dbRepo (если нужно где-то в роутинге)

class VitaApp extends StatefulWidget {
  const VitaApp({super.key});

  @override
  State<VitaApp> createState() => _VitaAppState();
}

class _VitaAppState extends State<VitaApp> {
  late final UserService _userService;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _userService = UserService();
    await _userService.init();
    if (mounted) {
      setState(() => _isReady = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final theme = context.watch<ThemeController>();

    final isLoggedIn   = _userService.currentUser != null;
    final hasCompleted = _userService.hasCompletedQuestionnaire;
    final hasSeenIntro = _userService.hasSeenEpicIntro;
    final hasArchetype = _userService.selectedArchetype != null;

    return MaterialApp(
      title: 'Vita Platform',
      debugShowCheckedModeBanner: false,

      // <-- подключаем контроллер темы
      themeMode: theme.mode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: theme.seedColor,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF4F8FC),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: theme.seedColor,
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),

      routes: {
        '/home': (_) => const HomeScreen(),
        '/register': (_) => ChangeNotifierProvider(
              create: (_) => RegisterModel(),
              child: const RegisterScreen(),
            ),
        '/login': (_) => const LoginScreen(),
        '/onboarding': (ctx) => OnboardingQuestionnaireScreen(
              userService: _userService,
              onCompleted: () {
                Navigator.of(ctx).pushReplacementNamed('/login');
              },
            ),
        '/settings': (_) => const screens.SettingsScreen(),
        '/expenses': (_) => const ExpensesScreen(),
        '/budget': (_) => const BudgetSetupScreen(),
        '/intro': (_) => EpicIntroScreen(userService: _userService),
        '/archetype': (_) => ArchetypeSelectScreen(userService: _userService),
      },

      home: _StartGate(
        userService: _userService,
        isLoggedIn: isLoggedIn,
        hasCompleted: hasCompleted,
        hasSeenIntro: hasSeenIntro,
        hasArchetype: hasArchetype,
      ),
    );
  }
}

/// 🔑 Шлюз выбора стартового экрана
class _StartGate extends StatelessWidget {
  final UserService userService;
  final bool isLoggedIn;
  final bool hasCompleted;
  final bool hasSeenIntro;
  final bool hasArchetype;

  const _StartGate({
    required this.userService,
    required this.isLoggedIn,
    required this.hasCompleted,
    required this.hasSeenIntro,
    required this.hasArchetype,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasSeenIntro) {
      return EpicIntroScreen(userService: userService);
    }
    if (!hasArchetype) {
      return ArchetypeSelectScreen(userService: userService);
    }
    if (isLoggedIn) {
      return hasCompleted
          ? const HomeScreen()
          : OnboardingQuestionnaireScreen(userService: userService);
    }
    // если не залогинен — на логин
    return const LoginScreen();
  }
}
