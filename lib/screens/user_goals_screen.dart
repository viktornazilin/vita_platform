// lib/screens/user_goals_screen.dart
//
// After the Ladna UX redesign, long-term goals are no longer a separate
// navigation section. They live inside the unified "Цели и задачи" screen.
// This wrapper is kept for old routes/imports so the app does not break.

import 'package:flutter/material.dart';

import 'goals_screen.dart';

class UserGoalsScreen extends StatelessWidget {
  const UserGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GoalsScreen();
  }
}
