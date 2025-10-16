import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart'; // dbRepo
import '../models/profile_model.dart';
import '../widgets/xp_progress_bar.dart';
import '../widgets/profile_field_card.dart';
import '../controllers/theme_controller.dart';

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

  String _humanSleep(String? v) {
    switch (v) {
      case '4-5': return '4–5 часов';
      case '6-7': return '6–7 часов';
      case '8+':  return '8+ часов';
      default:    return '—';
    }
  }

  String _humanActivity(String? v) {
    switch (v) {
      case 'daily': return 'Каждый день';
      case '3-4w':  return '3–4 раза/нед.';
      case 'rare':  return 'Иногда';
      case 'none':  return 'Почти нет';
      default:      return '—';
    }
  }

  String _humanStress(String? v) {
    switch (v) {
      case 'daily':     return 'Почти каждый день';
      case 'sometimes': return 'Иногда';
      case 'rare':      return 'Редко';
      case 'never':     return 'Почти никогда';
      default:          return '—';
    }
  }

  Widget _chips(String title, List<String> items) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Opacity(opacity: .7, child: Text('—'))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map((e) => Chip(label: Text(e))).toList(),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ProfileModel>();

    // показать ошибку через Snackbar (однократно)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final err = model.error;
      if (err != null && ScaffoldMessenger.maybeOf(context) != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      }
    });

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final isWide = w >= 960;
        final outerPad = EdgeInsets.symmetric(
          horizontal: isWide ? 24 : 16,
          vertical: isWide ? 16 : 12,
        );

        final leftColumnChildren = <Widget>[
          // Аватар + XP
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
                  const SizedBox(height: 16),
                  model.xp != null
                      ? XPProgressBar(xp: model.xp!)
                      : const Text('XP data not available', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Аккаунт
          Text('Аккаунт',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ProfileFieldCard(label: 'Архетип', value: model.archetype ?? '—'),
          ProfileFieldCard(label: 'Пролог пройден', value: model.hasSeenIntro ? 'Да' : 'Нет'),

          const SizedBox(height: 24),

          // Оформление
          Text('Оформление',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const _ThemeSection(),

          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.settings),
            label: const Text('Открыть настройки'),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ];

        final rightColumnChildren = <Widget>[
          // Заголовок + кнопка "Изменить ответы"
          Row(
            children: [
              Expanded(
                child: Text(
                  'Результаты опросника',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (model.questionnaireCompleted)
                TextButton.icon(
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Изменить ответы'),
                  onPressed: () => Navigator.pushNamed(context, '/onboarding'),
                ),
            ],
          ),
          const SizedBox(height: 8),

          if (!model.questionnaireCompleted) ...[
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Вы ещё не прошли опросник.', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => Navigator.pushNamed(context, '/onboarding'),
                      child: const Text('Пройти сейчас'),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Метрики
            ProfileFieldCard(label: 'Сон', value: _humanSleep(model.sleep)),
            ProfileFieldCard(label: 'Активность', value: _humanActivity(model.activity)),
            ProfileFieldCard(label: 'Энергия', value: model.energy != null ? '${model.energy}/10' : '—'),
            ProfileFieldCard(label: 'Стресс', value: _humanStress(model.stress)),
            ProfileFieldCard(
              label: 'Финансы',
              value: model.financeSatisfaction != null ? '${model.financeSatisfaction}/5' : '—',
            ),
            const SizedBox(height: 8),
            _chips('Сферы жизни', model.lifeBlocks),
            _chips('Приоритеты', model.priorities),

            if (model.dreamsByBlock.isNotEmpty || model.goalsByBlock.isNotEmpty) ...[
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Мечты и цели по сферам', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      ..._buildDreamsGoals(model),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ];

        // ======= МОБИЛЬНЫЙ =======
        if (!isWide) {
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
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: outerPad,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ...leftColumnChildren,
                              const SizedBox(height: 24),
                              ...rightColumnChildren,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          );
        }

        // ======= ШИРОКИЙ (скролл добавлен) =======
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
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Padding(
                          padding: outerPad,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [...leftColumnChildren],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 7,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [...rightColumnChildren],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  List<Widget> _buildDreamsGoals(ProfileModel m) {
    final keys = <String>{...m.dreamsByBlock.keys, ...m.goalsByBlock.keys}.toList()..sort();
    if (keys.isEmpty) return [const Opacity(opacity: .7, child: Text('—'))];

    return keys.map((k) {
      final dreams = m.dreamsByBlock[k];
      final goals = m.goalsByBlock[k];
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(k, style: const TextStyle(fontWeight: FontWeight.w600)),
            if ((dreams ?? '').isNotEmpty)
              Padding(padding: const EdgeInsets.only(top: 2), child: Text('Мечты: $dreams')),
            if ((goals ?? '').isNotEmpty)
              Padding(padding: const EdgeInsets.only(top: 2), child: Text('Цели: $goals')),
            if ((dreams ?? '').isEmpty && (goals ?? '').isEmpty)
              const Opacity(opacity: .7, child: Text('—')),
          ],
        ),
      );
    }).toList();
  }
}

class _ThemeSection extends StatelessWidget {
  const _ThemeSection();

  static const _swatches = <Color>[
    Color(0xFF6750A4), // фиолетовый
    Color(0xFF0061A4), // синий
    Color(0xFF006E1C), // зелёный
    Color(0xFF8B5000), // янтарный
    Color(0xFF7D5260), // розово-коричневый
    Color(0xFFB00020), // красный
    Color(0xFF005457), // бирюзовый
    Color(0xFF4E342E), // кофейный
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final cs = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Цвет приложения', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _swatches.map((c) {
                final selected = theme.seedColor.value == c.value;
                return InkWell(
                  onTap: () => context.read<ThemeController>().setSeedColor(c),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? cs.primary : cs.outlineVariant, width: selected ? 2.5 : 1),
                      boxShadow: [
                        if (selected) BoxShadow(color: cs.primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: selected ? const Icon(Icons.check, color: Colors.white) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Режим', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Светлая'), icon: Icon(Icons.light_mode)),
                ButtonSegment(value: ThemeMode.dark, label: Text('Тёмная'), icon: Icon(Icons.dark_mode)),
                ButtonSegment(value: ThemeMode.system, label: Text('Системная'), icon: Icon(Icons.phone_android)),
              ],
              selected: {theme.mode},
              onSelectionChanged: (v) => context.read<ThemeController>().setMode(v.first),
            ),
          ],
        ),
      ),
    );
  }
}
