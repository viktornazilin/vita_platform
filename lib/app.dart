import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ✅ i18n (Flutter gen-l10n)
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nest_app/l10n/app_localizations.dart';

import 'services/user_service.dart';
import 'models/register_model.dart';

import 'screens/home/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/budget_setup_screen.dart';
import 'screens/user_goals_screen.dart';

import 'controllers/theme_controller.dart';
// ✅ locale controller (manual language switch)
import 'controllers/locale_controller.dart';

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

  ThemeData _patchLadnaTheme(ThemeData base, {required bool isDark}) {
    const seed = Color(0xFF2F80FF);

    final cs0 = base.colorScheme;
    final cs = cs0.copyWith(primary: seed, onPrimary: Colors.white);

    final scaffoldBg = isDark
        ? (cs.surface)
        : const Color(0xFFF4F8FF);

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
    final localeCtl = context.watch<LocaleController>();

    final ThemeData light = themeCtl.lightTheme;
    final ThemeData dark = themeCtl.darkTheme;

    final bool isLoggedIn = _isReady && _userService.currentUser != null;

    return MaterialApp(
      title: 'Ladna',
      debugShowCheckedModeBanner: false,
      locale: localeCtl.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Follow the iOS/Android system appearance so Simulator → Toggle Appearance works.
      // The user's in-app preference can still be wired back later through ThemeController.
      themeMode: ThemeMode.system,
      theme: light,
      darkTheme: dark,
      routes: {
        '/home': (_) => const HomeScreen(),
        '/user-goals': (_) => const UserGoalsScreen(),

        '/register': (_) => ChangeNotifierProvider(
          create: (_) => RegisterModel(),
          child: const RegisterScreen(),
        ),

        '/login': (_) => const LoginScreen(),

        '/expenses': (_) => const ExpensesScreen(),
        '/budget': (_) => const BudgetSetupScreen(),
      },
      home: !_isReady
          ? const _BootSplash()
          : _StartGate(
              isLoggedIn: isLoggedIn,
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
  final bool isLoggedIn;

  const _StartGate({
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}
