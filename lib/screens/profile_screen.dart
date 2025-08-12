import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart'; // dbRepo
import '../models/xp.dart';
import '../models/profile_model.dart';
import '../widgets/xp_progress_bar.dart';
import '../widgets/profile_field_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileModel(repo: dbRepo)..load(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ProfileModel>();

    // показать ошибку через Snackbar (однократно на ререндер)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final err = model.error;
      if (err != null && ScaffoldMessenger.maybeOf(context) != null) {
        ScaffoldMessenger.of(context)!.showSnackBar(SnackBar(content: Text(err)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 28),
            const SizedBox(width: 10),
            const Text('My Profile'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: model.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => context.read<ProfileModel>().load(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Аватар + XP
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 40,
                              child: Icon(Icons.person, size: 40),
                            ),
                            const SizedBox(height: 16),
                            model.xp != null
                                ? XPProgressBar(xp: model.xp!)
                                : const Text(
                                    'XP data not available',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Результаты опроса
                    Text(
                      'Результаты опросника',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),

                    if (!model.questionnaireCompleted)
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Вы ещё не прошли опросник.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else ...[
                      ProfileFieldCard(label: 'Возраст', value: model.questionnaire!['age']),
                      ProfileFieldCard(label: 'Здоровье', value: model.questionnaire!['health']),
                      ProfileFieldCard(label: 'Цели', value: model.questionnaire!['goals']),
                      ProfileFieldCard(label: 'Мечты', value: model.questionnaire!['dreams']),
                      ProfileFieldCard(label: 'Сильные стороны', value: model.questionnaire!['strengths']),
                      ProfileFieldCard(label: 'Слабые стороны', value: model.questionnaire!['weaknesses']),
                      ProfileFieldCard(label: 'Приоритеты', value: model.questionnaire!['priorities']),
                      ProfileFieldCard(label: 'Сферы жизни', value: model.questionnaire!['life_blocks']),
                    ],

                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.settings),
                      label: const Text('Открыть настройки'),
                      onPressed: () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
