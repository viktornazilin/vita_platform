import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/home_model.dart';
import 'goals_screen.dart';
import 'mood_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';
import 'expenses_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final _screens = <Widget>[
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

class _HomeView extends StatelessWidget {
  const _HomeView();

  static final PageStorageBucket _bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<HomeModel>();
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;

        final content = SafeArea(
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
                child: SlideTransition(position: animation.drive(offsetTween), child: child),
              );
            },
            child: PageStorage(
              key: ValueKey(model.selectedIndex),
              bucket: _bucket,
              child: IndexedStack(index: model.selectedIndex, children: HomeScreen._screens),
            ),
          ),
        );

        // ------- компактный (мобила): без нижнего меню, стандартный FAB -------
        if (isCompact) {
          return Scaffold(
            body: content,
            floatingActionButton: FloatingActionButton(
              heroTag: 'launcher-fab',
              onPressed: () => _showQuickAddSheet(context, model),
              child: const Icon(Icons.add),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            backgroundColor: theme.colorScheme.surface,
          );
        }

        // ------- широкий (планшет/десктоп): оставляем NavigationRail -------
        final extendedRail = constraints.maxWidth >= 1200;
        return Scaffold(
          body: Row(
            children: [
              _FrostedRail(
                child: NavigationRail(
                  selectedIndex: model.selectedIndex,
                  onDestinationSelected: model.select,
                  extended: extendedRail,
                  useIndicator: true,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Tooltip(
                      message: 'Быстрое добавление',
                      child: FloatingActionButton.small(
                        heroTag: 'launcher-fab-rail',
                        onPressed: () => _showQuickAddSheet(context, model),
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: Text('Цели')),
                    NavigationRailDestination(icon: Icon(Icons.mood_outlined), selectedIcon: Icon(Icons.mood), label: Text('Настроение')),
                    NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Профиль')),
                    NavigationRailDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: Text('Отчёты')),
                    NavigationRailDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: Text('Расходы')),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: extendedRail ? 32 : 24, vertical: 12),
                  child: content,
                ),
              ),
            ],
          ),
          backgroundColor: theme.colorScheme.surface,
        );
      },
    );
  }

  void _showQuickAddSheet(BuildContext context, HomeModel model) {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Навигация по разделам (переносим бывший нижний бар под «плюс»)
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Разделы', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 8),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .95),
                children: [
                  _LauncherTile(icon: Icons.flag, label: 'Цели',    onTap: () { Navigator.pop(ctx); model.select(0); }),
                  _LauncherTile(icon: Icons.mood, label: 'Настроение', onTap: () { Navigator.pop(ctx); model.select(1); }),
                  _LauncherTile(icon: Icons.person, label: 'Профиль', onTap: () { Navigator.pop(ctx); model.select(2); }),
                  _LauncherTile(icon: Icons.insights, label: 'Отчёты', onTap: () { Navigator.pop(ctx); model.select(3); }),
                  _LauncherTile(icon: Icons.account_balance_wallet, label: 'Расходы', onTap: () { Navigator.pop(ctx); model.select(4); }),
                ],
              ),
              const SizedBox(height: 16),

              // Быстрые действия
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Быстрые действия', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 6),
              _QuickActionTile(
                icon: Icons.mood,
                color: cs.primary,
                title: 'Записать настроение',
                subtitle: 'Быстрая отметка за сегодня',
                onTap: () {
                  Navigator.pop(ctx);
                  model.select(1);
                  // здесь можешь открыть быстрый редактор
                },
              ),
              _QuickActionTile(
                icon: Icons.account_balance_wallet,
                color: cs.tertiary,
                title: 'Добавить расход',
                subtitle: 'Сумма, категория, заметка',
                onTap: () {
                  Navigator.pop(ctx);
                  model.select(4);
                },
              ),
              _QuickActionTile(
                icon: Icons.flag,
                color: cs.secondary,
                title: 'Создать цель',
                subtitle: 'Название, дедлайн, метрика',
                onTap: () {
                  Navigator.pop(ctx);
                  model.select(0);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FrostedRail extends StatelessWidget {
  const _FrostedRail({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surface.withOpacity(0.85),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 6)),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right, color: scheme.outline),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _LauncherTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _LauncherTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: cs.surfaceContainerHighest,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: cs.primary),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
