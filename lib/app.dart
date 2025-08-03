import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/onboarding_questionnaire_screen.dart';

import 'services/user_service.dart';

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
    await _userService.init(); // <- если у тебя есть init() или загрузка пользователя
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
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/register': (_) => const RegisterScreen(),
        '/login': (_) => const LoginScreen(),
        '/welcome': (_) => const WelcomeScreen(),
        '/onboarding': (_) => const OnboardingQuestionnaireScreen(),
      },
      home: isLoggedIn
          ? (hasCompleted
              ? const HomeScreen()
              : const OnboardingQuestionnaireScreen())
          : const WelcomeScreen(),
    );
  }
}
