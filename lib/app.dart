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

import 'controllers/theme_controller.dart';

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
    if (mounted) setState(() => _isReady = true);
  }

  @override
  Widget build(BuildContext context) {
    final themeCtl = context.watch<ThemeController>();

    // ✅ Единственный MaterialApp на всё приложение (важно для Web!)
    final ThemeData light = themeCtl.lightTheme;
    final ThemeData dark = themeCtl.darkTheme;

    // если хочешь centerTitle=true — делаем безопасный patch
    final ThemeData lightPatched = light.copyWith(
      appBarTheme: light.appBarTheme.copyWith(centerTitle: true),
    );
    final ThemeData darkPatched = dark.copyWith(
      appBarTheme: dark.appBarTheme.copyWith(centerTitle: true),
    );

    // вычисляем стартовые флаги (если сервис ещё не готов — не трогаем userService поля)
    final bool isLoggedIn = _isReady && _userService.currentUser != null;
    final bool hasCompleted = _isReady && _userService.hasCompletedQuestionnaire;
    final bool hasSeenIntro = _isReady && _userService.hasSeenEpicIntro;

    return MaterialApp(
      title: 'Vita Platform',
      debugShowCheckedModeBanner: false,

      themeMode: themeCtl.mode,
      theme: lightPatched,
      darkTheme: darkPatched,

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
                final loggedIn = _userService.currentUser != null;
                Navigator.of(ctx).pushReplacementNamed(
                  loggedIn ? '/home' : '/login',
                );
              },
            ),

        '/settings': (_) => const screens.SettingsScreen(),
        '/expenses': (_) => const ExpensesScreen(),
        '/budget': (_) => const BudgetSetupScreen(),

        '/intro': (_) => EpicIntroScreen(userService: _userService),
      },

      // ✅ Важно: во время загрузки — НЕ другой MaterialApp, а просто home = splash
      home: !_isReady
          ? const _BootSplash()
          : _StartGate(
              userService: _userService,
              isLoggedIn: isLoggedIn,
              hasCompleted: hasCompleted,
              hasSeenIntro: hasSeenIntro,
            ),
    );
  }
}

class _BootSplash extends StatelessWidget {
  const _BootSplash();

  @override
  Widget build(BuildContext context) {
    // можешь сделать сюда свой красивый glass фон
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/// 🔑 Шлюз выбора стартового экрана
class _StartGate extends StatelessWidget {
  final UserService userService;
  final bool isLoggedIn;
  final bool hasCompleted;
  final bool hasSeenIntro;

  const _StartGate({
    required this.userService,
    required this.isLoggedIn,
    required this.hasCompleted,
    required this.hasSeenIntro,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasSeenIntro) {
      return EpicIntroScreen(userService: userService);
    }

    if (!hasCompleted) {
      return OnboardingQuestionnaireScreen(userService: userService);
    }

    if (isLoggedIn) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}
