import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../../models/home_model.dart';

import '../goals_screen.dart';
import '../mood_screen.dart';
import '../profile_screen.dart';
import '../reports_screen.dart';
import '../expenses_screen.dart';
import '../user_goals_screen.dart';

import '../../widgets/frosted_rail.dart';
import '../../widgets/nest/nest_background.dart';
import '../../widgets/nest/nest_blur_card.dart';

import 'home_dashboard_tab.dart';
import 'home_launcher_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final _screens = <Widget>[
    const HomeDashboardTab(),
    const GoalsScreen(),
    const UserGoalsScreen(),
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

  String _titleFor(int idx, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return switch (idx) {
      0 => l.homeTitleHome,
      1 => l.homeTitleGoals,
      2 => l.homeTitleMood,
      3 => l.homeTitleProfile,
      4 => l.homeTitleReports,
      5 => l.homeTitleExpenses,
      _ => l.homeTitleApp,
    };
  }

  IconData _iconFor(int idx) {
    return switch (idx) {
      0 => Icons.home_rounded,
      1 => Icons.flag_rounded,
      2 => Icons.track_changes_rounded,
      3 => Icons.person_rounded,
      4 => Icons.insights_rounded,
      5 => Icons.account_balance_wallet_rounded,
      _ => Icons.apps_rounded,
    };
  }

  void _onDashboardScroll(ScrollDirection dir) {
    if (dir == ScrollDirection.reverse && _fabVisible.value) {
      _fabVisible.value = false;
    } else if (dir == ScrollDirection.forward && !_fabVisible.value) {
      _fabVisible.value = true;
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final l = AppLocalizations.of(context)!;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.homeSignOutTitle),
        content: Text(l.homeSignOutSubtitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.homeSignOutConfirm),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _signOut(context);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final l = AppLocalizations.of(context)!;

    try {
      await Supabase.instance.client.auth.signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.homeSignOutFailed('$e'))));
    }
  }

  Widget _logoFab(
    BuildContext context, {
    required VoidCallback onPressed,
    required String heroTag,
    double size = 110,
    bool small = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      cs.surfaceContainerHighest,
                      cs.primary.withOpacity(0.88),
                    ]
                  : [
                      cs.primary.withOpacity(0.92),
                      cs.secondary.withOpacity(0.90),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? cs.outline.withOpacity(0.70)
                  : Colors.white.withOpacity(0.85),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.22)
                    : cs.primary.withOpacity(0.16),
                blurRadius: small ? 10 : 18,
                offset: Offset(0, small ? 4 : 8),
              ),
            ],
          ),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size * 0.26),
              child: Container(
                color: isDark
                    ? cs.surfaceContainerLow.withOpacity(0.96)
                    : Colors.white.withOpacity(0.94),
                padding: EdgeInsets.all(small ? 5 : 8),
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

  Widget _buildTopBar(
    BuildContext context,
    HomeModel model, {
    required bool compact,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 16 : 0,
        compact ? 12 : 8,
        compact ? 16 : 0,
        12,
      ),
      child: NestBlurCard(
        radius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: compact ? 44 : 48,
              height: compact ? 44 : 48,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Icon(
                _iconFor(model.selectedIndex),
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titleFor(model.selectedIndex, context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Nest App',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: l.homeSignOutTooltip,
              style: IconButton.styleFrom(
                backgroundColor: cs.surfaceContainerHighest.withOpacity(0.55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => _confirmSignOut(context),
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedContent(
    BuildContext context,
    HomeModel model, {
    required double bottomInset,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
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
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: IndexedStack(
            index: model.selectedIndex,
            children: HomeScreen._screens,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<HomeModel>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final isDashboard = model.selectedIndex == 0;
        final safeBottom = MediaQuery.of(context).padding.bottom;

        // ↓↓↓ СДЕЛАНО НАМНОГО КОМПАКТНЕЕ
        final double fabSizeCompact = isDashboard ? 72 : 82;
        final double fabBottomCompact = 10 + safeBottom;
        final double fabReserveCompact = 64 + safeBottom;
        final double railFabSize = 44;

        final fab = ValueListenableBuilder<bool>(
          valueListenable: _fabVisible,
          builder: (context, visible, _) {
            final show = !isDashboard || visible;

            return IgnorePointer(
              ignoring: !show,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                offset: show ? Offset.zero : const Offset(0, 0.20),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: show ? 1 : 0,
                  child: _logoFab(
                    context,
                    heroTag: 'launcher-fab',
                    size: fabSizeCompact,
                    onPressed: () => _openLauncher(context, model),
                  ),
                ),
              ),
            );
          },
        );

        if (isCompact) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: NestBackground(
              child: Stack(
                children: [
                  Column(
                    children: [
                      _buildTopBar(
                        context,
                        model,
                        compact: true,
                      ),
                      Expanded(
                        child: NotificationListener<UserScrollNotification>(
                          onNotification: (n) {
                            if (isDashboard) _onDashboardScroll(n.direction);
                            return false;
                          },
                          child: _buildAnimatedContent(
                            context,
                            model,
                            bottomInset: fabReserveCompact,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: fabBottomCompact,
                    child: Center(child: fab),
                  ),
                ],
              ),
            ),
          );
        }

        final extendedRail = constraints.maxWidth >= 1200;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: NestBackground(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                  child: FrostedRail(
                    child: NavigationRail(
                      selectedIndex: model.selectedIndex,
                      onDestinationSelected: model.select,
                      extended: extendedRail,
                      useIndicator: true,
                      backgroundColor: Colors.transparent,
                      leading: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Tooltip(
                          message: AppLocalizations.of(context)!
                              .homeQuickActionsTooltip,
                          child: _logoFab(
                            context,
                            heroTag: 'launcher-fab-rail',
                            size: railFabSize,
                            small: true,
                            onPressed: () => _openLauncher(context, model),
                          ),
                        ),
                      ),
                      destinations: [
                        NavigationRailDestination(
                          icon: const Icon(Icons.home_outlined),
                          selectedIcon: const Icon(Icons.home_rounded),
                          label: Text(
                            AppLocalizations.of(context)!.homeTitleHome,
                          ),
                        ),
                        NavigationRailDestination(
                          icon: const Icon(Icons.flag_outlined),
                          selectedIcon: const Icon(Icons.flag_rounded),
                          label: Text(
                            AppLocalizations.of(context)!.homeTitleGoals,
                          ),
                        ),
                        NavigationRailDestination(
                          icon: const Icon(Icons.track_changes_outlined),
                          selectedIcon:
                              const Icon(Icons.track_changes_rounded),
                          label: Text(
                            AppLocalizations.of(context)!.homeTitleMood,
                          ),
                        ),
                        NavigationRailDestination(
                          icon: const Icon(Icons.person_outline),
                          selectedIcon: const Icon(Icons.person_rounded),
                          label: Text(
                            AppLocalizations.of(context)!.homeTitleProfile,
                          ),
                        ),
                        NavigationRailDestination(
                          icon: const Icon(Icons.insights_outlined),
                          selectedIcon: const Icon(Icons.insights_rounded),
                          label: Text(
                            AppLocalizations.of(context)!.homeTitleReports,
                          ),
                        ),
                        NavigationRailDestination(
                          icon: const Icon(
                            Icons.account_balance_wallet_outlined,
                          ),
                          selectedIcon:
                              const Icon(Icons.account_balance_wallet_rounded),
                          label: Text(
                            AppLocalizations.of(context)!.homeTitleExpenses,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      extendedRail ? 20 : 16,
                      12,
                      extendedRail ? 20 : 16,
                      12,
                    ),
                    child: Column(
                      children: [
                        _buildTopBar(
                          context,
                          model,
                          compact: false,
                        ),
                        Expanded(
                          child: NotificationListener<UserScrollNotification>(
                            onNotification: (n) {
                              if (isDashboard) _onDashboardScroll(n.direction);
                              return false;
                            },
                            child: _buildAnimatedContent(
                              context,
                              model,
                              bottomInset: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}