import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart'; // dbRepo
import '../models/profile_model.dart';

// HABITS
import '../models/habits_model.dart';

// GOALS
import '../models/user_goals_model.dart';

import '../widgets/profile/profile_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProfileModel(repo: dbRepo)..load(),
        ),
        ChangeNotifierProvider(create: (_) => HabitsModel()..load()),
        ChangeNotifierProvider(
          create: (_) => UserGoalsModel(repo: dbRepo)..load(),
        ),
      ],
      child: const ProfileView(),
    );
  }
}
