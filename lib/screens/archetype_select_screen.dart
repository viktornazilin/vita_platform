import 'package:flutter/material.dart';
import '../services/user_service.dart';

class ArchetypeSelectScreen extends StatelessWidget {
  final UserService userService;
  const ArchetypeSelectScreen({super.key, required this.userService});

  @override
  Widget build(BuildContext context) {
    final archetypes = <_Archetype>[
      _Archetype(key: 'game',     title: 'Игровой мир',      emoji: '🎮', desc: 'RPG/киберпанк стиль'),
      _Archetype(key: 'sport',    title: 'Спорт',            emoji: '🏆', desc: 'Динамика и дисциплина'),
      _Archetype(key: 'business', title: 'Бизнес',           emoji: '💼', desc: 'Стратегия и рост'),
      _Archetype(key: 'creative', title: 'Творчество',       emoji: '🎭', desc: 'Сцена и вдохновение'),
      _Archetype(key: 'travel',   title: 'Путешествия',      emoji: '🌍', desc: 'Исследование мира'),
      _Archetype(key: 'science',  title: 'Наука и знания',   emoji: '📚', desc: 'Эксперименты и обучение'),
      _Archetype(key: 'balance',  title: 'Баланс/ЗОЖ',       emoji: '🌱', desc: 'Гармония и энергия'),
      _Archetype(key: 'family',   title: 'Семья и забота',   emoji: '❤️', desc: 'Тёплые связи'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Выбор стиля героя')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Кем бы ты был в этой истории?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: archetypes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.1,
                ),
                itemBuilder: (_, i) => _ArchetypeCard(
                  data: archetypes[i],
                  onTap: () async {
                    // сохраняем выбор
                    await userService.saveArchetype(archetypes[i].key);
                    // сразу ведём на опросник (без логина/регистрации)
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushReplacementNamed('/onboarding');
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'От твоего выбора зависит тон общения, но цель одна — баланс ресурсов и персональные рекомендации.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Archetype {
  final String key;
  final String title;
  final String emoji;
  final String desc;
  const _Archetype({required this.key, required this.title, required this.emoji, required this.desc});
}

class _ArchetypeCard extends StatelessWidget {
  final _Archetype data;
  final VoidCallback onTap;
  const _ArchetypeCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0, 6)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(data.emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(data.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Opacity(opacity: .7, child: Text(data.desc, textAlign: TextAlign.center)),
            ],
          ),
        ),
      ),
    );
  }
}
