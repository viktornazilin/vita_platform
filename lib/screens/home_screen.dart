import 'package:flutter/material.dart';
import 'goals_screen.dart';
import 'mood_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';
import 'expenses_screen.dart'; // 👈 новый экран для ввода расходов

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final _screens = const [
    GoalsScreen(),
    MoodScreen(),
    ProfileScreen(),
    ReportsScreen(),
    ExpensesScreen(), // 👈 новый экран расходов
  ];

  void _onDestinationSelected(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: IndexedStack(
            key: ValueKey(_selectedIndex),
            index: _selectedIndex,
            children: _screens,
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            height: 65,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            backgroundColor: Colors.white,
            indicatorColor: Colors.teal.withOpacity(0.2),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.flag_outlined),
                selectedIcon: Icon(Icons.flag),
                label: 'Goals',
              ),
              NavigationDestination(
                icon: Icon(Icons.mood_outlined),
                selectedIcon: Icon(Icons.mood),
                label: 'Mood',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights),
                label: 'Reports',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined), // 💰
                selectedIcon: Icon(Icons.account_balance_wallet),
                label: 'Expenses',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
