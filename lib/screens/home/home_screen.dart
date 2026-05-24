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
import '../../services/onboarding_tour_service.dart';

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

  final GlobalKey _launcherKey = GlobalKey(debugLabel: 'nest_launcher');
  final GlobalKey _helpKey = GlobalKey(debugLabel: 'nest_help');
  final GlobalKey _railKey = GlobalKey(debugLabel: 'nest_navigation_rail');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = context.read<HomeModel>();
      OnboardingTourService.startFullAppOnboardingIfNeeded(
        context: context,
        onSelectTab: model.select,
        launcherKey: _launcherKey,
        helpKey: _helpKey,
        navigationKey: _railKey,
      );
    });
  }

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
    Key? key,
    required VoidCallback onPressed,
    required String heroTag,
    double size = 110,
    bool small = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = cs.secondary;

    final outerSize = size;
    final innerSize = small ? size * 0.68 : size * 0.66;
    final logoSize = small ? size * 0.44 : size * 0.42;

    return SizedBox(
      width: outerSize,
      height: outerSize,
      child: FloatingActionButton(
        key: key,
        heroTag: heroTag,
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: Colors.transparent,
        splashColor: cs.primary.withOpacity(0.10),
        shape: const CircleBorder(),
        onPressed: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      cs.primary.withOpacity(0.95),
                      cs.primaryContainer.withOpacity(0.96),
                      cs.secondary.withOpacity(0.72),
                    ]
                  : [
                      cs.primary.withOpacity(0.98),
                      Color.lerp(cs.primaryContainer, accent, 0.22)!.withOpacity(0.96),
                      accent.withOpacity(0.92),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.28)
                  : Colors.white.withOpacity(0.88),
              width: small ? 1.0 : 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? cs.primary.withOpacity(0.20)
                    : accent.withOpacity(0.28),
                blurRadius: small ? 12 : 22,
                offset: Offset(0, small ? 5 : 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.24 : 0.06),
                blurRadius: small ? 10 : 18,
                offset: Offset(0, small ? 4 : 8),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: innerSize,
              height: innerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? cs.surface.withOpacity(0.92)
                    : Colors.white.withOpacity(0.88),
                border: Border.all(
                  color: isDark
                      ? cs.outlineVariant.withOpacity(0.55)
                      : Colors.white.withOpacity(0.92),
                  width: small ? 0.8 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
                    blurRadius: small ? 8 : 12,
                    offset: Offset(0, small ? 3 : 5),
                  ),
                ],
              ),
              child: Center(
                child: ClipOval(
                  child: SizedBox(
                    width: logoSize,
                    height: logoSize,
                    child: Image.asset(
                      'assets/images/logo_simple.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 16 : 0,
        compact ? 12 : 8,
        compact ? 16 : 0,
        12,
      ),
      child: NestBlurCard(
        radius: 26,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        accentColor: cs.secondary,
        child: Row(
          children: [
            Container(
              width: compact ? 44 : 48,
              height: compact ? 44 : 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary.withOpacity(isDark ? 0.30 : 0.16),
                    cs.secondary.withOpacity(isDark ? 0.18 : 0.24),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color.lerp(cs.outlineVariant, cs.secondary, 0.28)!,
                ),
                boxShadow: [
                  BoxShadow(
                    color: cs.secondary.withOpacity(isDark ? 0.08 : 0.13),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
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
                    'Ladna',
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
              key: _helpKey,
              tooltip: 'How-To',
              style: IconButton.styleFrom(
                backgroundColor: Color.lerp(
                  cs.surfaceContainerHighest,
                  cs.secondary,
                  isDark ? 0.10 : 0.18,
                ),
                foregroundColor: isDark ? cs.onSurface : cs.onSecondaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                side: BorderSide(
                  color: Color.lerp(cs.outlineVariant, cs.secondary, 0.24)!,
                ),
              ),
              onPressed: () => OnboardingTourService.startFullAppOnboarding(
                context: context,
                onSelectTab: model.select,
                launcherKey: _launcherKey,
                helpKey: _helpKey,
                navigationKey: _railKey,
                forceRestart: true,
              ),
              icon: const Icon(Icons.help_outline_rounded),
            ),
            const SizedBox(width: 6),
            IconButton(
              tooltip: l.homeSignOutTooltip,
              style: IconButton.styleFrom(
                backgroundColor: Color.lerp(
                  cs.surfaceContainerHighest,
                  cs.primary,
                  isDark ? 0.08 : 0.12,
                ),
                foregroundColor: cs.onSurfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                side: BorderSide(color: cs.outlineVariant.withOpacity(0.75)),
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
    OnboardingTourService.setActiveHomeTab(model.selectedIndex);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final isDashboard = model.selectedIndex == 0;
        final safeBottom = MediaQuery.of(context).padding.bottom;

        // The launcher is a true floating button now.
        // No reserved bottom padding and no artificial bottom rectangle.
        final double fabSizeCompact = isDashboard ? 68 : 76;
        final double fabBottomCompact = -2;
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
                    key: _launcherKey,
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
            extendBody: true,
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: NestBackground(
              useSoftGradient: true,
              child: Stack(
                clipBehavior: Clip.none,
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
                            bottomInset: 0,
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
            useSoftGradient: true,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                  child: FrostedRail(
                    child: NavigationRail(
                      key: _railKey,
                      selectedIndex: model.selectedIndex,
                      onDestinationSelected: model.select,
                      extended: extendedRail,
                      useIndicator: true,
                      indicatorColor: Color.lerp(
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.secondaryContainer,
                        0.36,
                      ),
                      selectedIconTheme: IconThemeData(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      selectedLabelTextStyle: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                      backgroundColor: Colors.transparent,
                      leading: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Tooltip(
                          message: AppLocalizations.of(context)!
                              .homeQuickActionsTooltip,
                          child: _logoFab(
                            context,
                            key: _launcherKey,
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