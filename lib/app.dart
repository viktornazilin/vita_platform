import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/user_service.dart';
import 'models/register_model.dart';

import 'screens/home/home_screen.dart';
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

  /// Патчим тему аккуратно:
  /// - НЕ перезатираем полностью ColorScheme через fromSeed (иначе "light" станет почти белым)
  /// - но при этом фиксируем единый "Nest-blue" и базовые компоненты
  ThemeData _patchNestTheme(ThemeData base, {required bool isDark}) {
    // Твой фирменный цвет
    const seed = Color(0xFF2F80FF);

    final cs0 = base.colorScheme;
    final cs = cs0.copyWith(primary: seed, onPrimary: Colors.white);

    // Лёгкий фирменный фон, чтобы светлая тема не была «больнично белой»
    final scaffoldBg = isDark
        ? (cs.surface) // в dark обычно норм
        : const Color(0xFFF4F8FF); // мягкий голубоватый вместо белого

    final surfaceTint = isDark
        ? cs.primary.withOpacity(0.08)
        : cs.primary.withOpacity(0.06);

    return base.copyWith(
      useMaterial3: true,
      colorScheme: cs,

      scaffoldBackgroundColor: scaffoldBg,

      appBarTheme: base.appBarTheme.copyWith(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      // Чтобы карточки/контейнеры не уходили в "зелень" и выглядели консистентно
      cardTheme: base.cardTheme.copyWith(
        color: cs.surface,
        surfaceTintColor: surfaceTint,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: cs.outlineVariant.withOpacity(isDark ? 0.35 : 0.55),
          ),
        ),
      ),

      dialogTheme: base.dialogTheme.copyWith(
        backgroundColor: cs.surface,
        surfaceTintColor: surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),

      bottomSheetTheme: base.bottomSheetTheme.copyWith(
        backgroundColor: cs.surface,
        surfaceTintColor: surfaceTint,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: isDark ? cs.surface.withOpacity(0.55) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
      ),

      dividerColor: cs.outlineVariant.withOpacity(isDark ? 0.35 : 0.65),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeCtl = context.watch<ThemeController>();

    final ThemeData light = _patchNestTheme(themeCtl.lightTheme, isDark: false);
    final ThemeData dark = _patchNestTheme(themeCtl.darkTheme, isDark: true);

    final bool isLoggedIn = _isReady && _userService.currentUser != null;
    final bool hasCompleted =
        _isReady && _userService.hasCompletedQuestionnaire;
    final bool hasSeenIntro = _isReady && _userService.hasSeenEpicIntro;

    return MaterialApp(
      title: 'Nest App',
      debugShowCheckedModeBanner: false,

      themeMode: themeCtl.mode,
      theme: light,
      darkTheme: dark,

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
            Navigator.of(
              ctx,
            ).pushReplacementNamed(loggedIn ? '/home' : '/login');
          },
        ),

        '/settings': (_) => const screens.SettingsScreen(),
        '/expenses': (_) => const ExpensesScreen(),
        '/budget': (_) => const BudgetSetupScreen(),

        '/intro': (_) => EpicIntroScreen(userService: _userService),
      },

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
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

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
