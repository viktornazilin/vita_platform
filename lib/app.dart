import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/onboarding_questionnaire_screen.dart';
import 'screens/settings_screen.dart' as screens;
import 'services/user_service.dart';
import 'screens/expenses_screen.dart';
import 'screens/budget_setup_screen.dart';

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
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final isLoggedIn = _userService.currentUser != null;
    final hasCompleted = _userService.hasCompletedQuestionnaire;

    return MaterialApp(
      title: 'Vita Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1565C0), // основной синий
        brightness: Brightness.light,

        scaffoldBackgroundColor: const Color(0xFFF4F8FC), // светло-голубой фон
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1565C0),
            side: const BorderSide(color: Color(0xFF1565C0)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF1565C0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),

        listTileTheme: const ListTileThemeData(
          iconColor: Color(0xFF1565C0),
          textColor: Colors.black87,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),

        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Color(0xFF1565C0),
          labelTextStyle: WidgetStatePropertyAll(TextStyle(color: Colors.black87)),
        ),
      ),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/register': (_) => const RegisterScreen(),
        '/login': (_) => const LoginScreen(),
        '/welcome': (_) => const WelcomeScreen(),
        '/onboarding': (_) => const OnboardingQuestionnaireScreen(),
        '/settings': (_) => const screens.SettingsScreen(),
        '/expenses': (_) => const ExpensesScreen(),   
        '/budget': (_) => const BudgetSetupScreen(), 
      },
      home: isLoggedIn
          ? (hasCompleted ? const HomeScreen() : const OnboardingQuestionnaireScreen())
          : const WelcomeScreen(),
    );
  }
}
