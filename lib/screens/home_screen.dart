import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/home_model.dart';
import 'goals_screen.dart';
import 'mood_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';
import 'expenses_screen.dart';
import '../widgets/app_navigation_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final _screens = [
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

  static final PageStorageBucket _bucket = PageStorageBucket(); // <- вынесли сюда

  @override
  Widget build(BuildContext context) {
    final model = context.watch<HomeModel>();

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: PageStorage(
            bucket: _bucket, // <- используем статический bucket
            child: IndexedStack(
              key: ValueKey(model.selectedIndex),
              index: model.selectedIndex,
              children: HomeScreen._screens,
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: model.selectedIndex,
        onSelect: model.select,
      ),
    );
  }
}