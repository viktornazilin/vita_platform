import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/register_model.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_questionnaire_screen.dart';
import 'screens/settings_screen.dart' as screens;
import 'services/user_service.dart';
import 'screens/expenses_screen.dart';
import 'screens/budget_setup_screen.dart';
import 'screens/epic_intro_screen.dart';
import 'screens/archetype_select_screen.dart';

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
    setState(() {
      _isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final isLoggedIn   = _userService.currentUser != null;
    final hasCompleted = _userService.hasCompletedQuestionnaire;
    final hasSeenIntro = _userService.hasSeenEpicIntro;
    final hasArchetype = _userService.selectedArchetype != null;

    return MaterialApp(
      title: 'Vita Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1565C0),
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF4F8FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
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
    return ArchetypeSelectScreen(userService: userService);
  }
}
