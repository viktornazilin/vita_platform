import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/home_model.dart';
import 'dart:ui' show ImageFilter;

import '../goals_screen.dart';
import '../mood_screen.dart';
import '../profile_screen.dart';
import '../reports_screen.dart';
import '../expenses_screen.dart';

import '../../widgets/frosted_rail.dart';

import 'home_dashboard_tab.dart';
import 'home_launcher_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final _screens = <Widget>[
    const HomeDashboardTab(),
    const GoalsScreen(),
    const MoodScreen(),
    const ProfileScreen(),
    const ReportsScreen(),
    const ExpensesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeModel(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  static final PageStorageBucket _bucket = PageStorageBucket();
  final ValueNotifier<bool> _fabVisible = ValueNotifier<bool>(true);

  String _titleFor(int idx) => switch (idx) {
    0 => 'Главная',
    1 => 'Цели',
    2 => 'Настроение',
    3 => 'Профиль',
    4 => 'Отчёты',
    5 => 'Расходы',
    _ => 'MyNEST',
  };

  void _onDashboardScroll(ScrollDirection dir) {
    if (dir == ScrollDirection.reverse && _fabVisible.value) {
      _fabVisible.value = false;
    } else if (dir == ScrollDirection.forward && !_fabVisible.value) {
      _fabVisible.value = true;
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text('Текущая сессия будет завершена.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _signOut(context);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Не удалось выйти: $e')));
    }
  }

  Widget _logoFab(
    BuildContext context, {
    required VoidCallback onPressed,
    required String heroTag,
    double size = 110,
    bool small = false,
  }) {
    // ✅ Nest-styled FAB (дизайн), поведение то же
    return SizedBox(
      width: size,
      height: size,
      child: FloatingActionButton(
        heroTag: heroTag,
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size * 0.32),
        ),
        onPressed: onPressed,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.32),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3AA8E6), Color(0xFF6C8CFF)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2A2B5B7A),
                blurRadius: 22,
                offset: Offset(0, 14),
              ),
            ],
            border: Border.all(color: const Color(0x66FFFFFF)),
          ),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size * 0.26),
              child: Container(
                color: Colors.white.withOpacity(0.92),
                padding: EdgeInsets.all(small ? 6 : 10),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: size * 0.55,
                  height: size * 0.55,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openLauncher(BuildContext context, HomeModel model) {
    showHomeLauncherSheet(context: context, model: model);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<HomeModel>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final isDashboard = model.selectedIndex == 0;

        final double fabSizeCompact = 140;
        final double fabSizeRailSmall = 44;

        Widget content = Stack(
          children: [
            const _NestBackground(),
            SafeArea(
              bottom: false,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final offsetTween = Tween<Offset>(
                    begin: const Offset(0.02, 0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeOutCubic));
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: animation.drive(offsetTween),
                      child: child,
                    ),
                  );
                },
                child: PageStorage(
                  key: ValueKey(model.selectedIndex),
                  bucket: _bucket,
                  child: IndexedStack(
                    index: model.selectedIndex,
                    children: HomeScreen._screens,
                  ),
                ),
              ),
            ),
          ],
        );

        // padding от FAB: только в compact
        if (isCompact) {
          final bottomSafe = MediaQuery.of(context).padding.bottom;
          content = Padding(
            padding: EdgeInsets.only(
              bottom: (fabSizeCompact / 2) + bottomSafe + 16,
            ),
            child: content,
          );
        }

        // FAB size
        final double fabSize = isCompact
            ? (isDashboard ? 84 : fabSizeCompact)
            : fabSizeRailSmall;

        final fab = ValueListenableBuilder<bool>(
          valueListenable: _fabVisible,
          builder: (context, visible, _) {
            final show = !isDashboard || visible;
            return AnimatedSlide(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              offset: show ? Offset.zero : const Offset(0, 0.25),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: show ? 1 : 0,
                child: _logoFab(
                  context,
                  heroTag: isCompact ? 'launcher-fab' : 'launcher-fab-rail',
                  size: fabSize,
                  onPressed: () => _openLauncher(context, model),
                ),
              ),
            );
          },
        );

        if (isCompact) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(_titleFor(model.selectedIndex)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              actions: [
                IconButton(
                  tooltip: 'Выйти из аккаунта',
                  icon: const Icon(Icons.logout),
                  onPressed: () => _confirmSignOut(context),
                ),
              ],
            ),
            body: NotificationListener<UserScrollNotification>(
              onNotification: (n) {
                if (isDashboard) _onDashboardScroll(n.direction);
                return false;
              },
              child: content,
            ),
            floatingActionButton: fab,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        }

        final extendedRail = constraints.maxWidth >= 1200;
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(_titleFor(model.selectedIndex)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            actions: [
              IconButton(
                tooltip: 'Выйти из аккаунта',
                icon: const Icon(Icons.logout),
                onPressed: () => _confirmSignOut(context),
              ),
            ],
          ),
          body: Row(
            children: [
              FrostedRail(
                child: NavigationRail(
                  selectedIndex: model.selectedIndex,
                  onDestinationSelected: model.select,
                  extended: extendedRail,
                  useIndicator: true,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Tooltip(
                      message: 'Быстрые действия',
                      child: _logoFab(
                        context,
                        heroTag: 'launcher-fab-rail',
                        size: fabSizeRailSmall,
                        small: true,
                        onPressed: () => _openLauncher(context, model),
                      ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Главная'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.flag_outlined),
                      selectedIcon: Icon(Icons.flag),
                      label: Text('Цели'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.mood_outlined),
                      selectedIcon: Icon(Icons.mood),
                      label: Text('Настроение'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Профиль'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.insights_outlined),
                      selectedIcon: Icon(Icons.insights),
                      label: Text('Отчёты'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.account_balance_wallet_outlined),
                      selectedIcon: Icon(Icons.account_balance_wallet),
                      label: Text('Расходы'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: extendedRail ? 32 : 24,
                    vertical: 12,
                  ),
                  child: NotificationListener<UserScrollNotification>(
                    onNotification: (n) {
                      if (isDashboard) _onDashboardScroll(n.direction);
                      return false;
                    },
                    child: content,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// NEST background (оставляем тут)
// ============================================================================
class _NestBackground extends StatelessWidget {
  const _NestBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF7FCFF),
            Color(0xFFEAF6FF),
            Color(0xFFD7EEFF),
            Color(0xFFF2FAFF),
          ],
        ),
      ),
      child: Stack(
        children: const [
          Positioned(top: -140, left: -120, child: _SoftBlob(size: 360)),
          Positioned(bottom: -180, right: -140, child: _SoftBlob(size: 420)),
          Positioned(top: 120, right: -90, child: _SoftBlob(size: 240)),
        ],
      ),
    );
  }
}

class _SoftBlob extends StatelessWidget {
  final double size;
  const _SoftBlob({required this.size});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [Color(0x663AA8E6), Color(0x0058B9FF)],
          ),
        ),
      ),
    );
  }
}
