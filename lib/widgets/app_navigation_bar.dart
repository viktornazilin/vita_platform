import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nest_app/l10n/app_localizations.dart';

class AppNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const AppNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t9n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cs.surface.withOpacity(0.82),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: NavigationBar(
                height: 66,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                selectedIndex: selectedIndex,
                onDestinationSelected: onSelect,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                indicatorColor: cs.primary.withOpacity(0.16),
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.flag_outlined),
                    selectedIcon: const Icon(Icons.flag),
                    label: t9n.navGoals,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.mood_outlined),
                    selectedIcon: const Icon(Icons.mood),
                    label: t9n.navMood,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person_outline),
                    selectedIcon: const Icon(Icons.person),
                    label: t9n.navProfile,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.insights_outlined),
                    selectedIcon: const Icon(Icons.insights),
                    label: t9n.navReports,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.account_balance_wallet_outlined),
                    selectedIcon: const Icon(Icons.account_balance_wallet),
                    label: t9n.navExpenses,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
