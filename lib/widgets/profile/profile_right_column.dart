import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/profile_model.dart';

import 'profile_ui_helpers.dart';
import 'goals_by_block_card.dart';
import 'habits_card.dart';

// Nest UI (проверь пути/имена)
import '../../widgets/nest/nest_card.dart';
import '../../widgets/nest/nest_section_title.dart';

class ProfileRightColumn extends StatelessWidget {
  const ProfileRightColumn({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ProfileModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ===== Header =====
        Row(
          children: [
            const Expanded(child: NestSectionTitle('Опросник и сферы жизни')),
            if (model.hasCompletedQuestionnaire)
              _NestLinkButton(
                icon: Icons.edit_outlined,
                label: 'Изменить',
                onTap: () => Navigator.pushNamed(context, '/onboarding'),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // ===== Content =====
        if (!model.hasCompletedQuestionnaire) ...[
          NestCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Вы ещё не прошли опросник.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF2E4B5A).withOpacity(0.75),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerLeft,
                  child: _NestPrimaryButton(
                    label: 'Пройти сейчас',
                    onTap: () => Navigator.pushNamed(context, '/onboarding'),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // chipsCard внутри ProfileUi пока может быть "серым" — мы оборачиваем в NestCard
          NestCard(
            padding: const EdgeInsets.all(12),
            child: ProfileUi.chipsCard(
              context,
              title: 'Сферы жизни',
              items: model.lifeBlocks,
              onEdit: () async {
                final v = await ProfileUi.editChipsDialog(
                  context,
                  title: 'Сферы жизни',
                  initial: model.lifeBlocks,
                  hint: 'Например: здоровье, карьера, семья',
                );
                if (v == null) return;
                final err = await model.setLifeBlocks(v);
                if (err != null && context.mounted) ProfileUi.snack(context, err);
              },
            ),
          ),
          const SizedBox(height: 10),

          NestCard(
            padding: const EdgeInsets.all(12),
            child: ProfileUi.chipsCard(
              context,
              title: 'Приоритеты',
              items: model.priorities,
              onEdit: () async {
                final v = await ProfileUi.editChipsDialog(
                  context,
                  title: 'Приоритеты',
                  initial: model.priorities,
                  hint: 'Например: спорт, финансы, чтение',
                );
                if (v == null) return;
                final err = await model.setPriorities(v);
                if (err != null && context.mounted) ProfileUi.snack(context, err);
              },
            ),
          ),

          const SizedBox(height: 10),

          // Эти два виджета дальше тоже переведём на Nest-стили.
          GoalsByBlockCard(onSnack: (t) => ProfileUi.snack(context, t)),
          const SizedBox(height: 10),
          const HabitsCard(),
        ],
      ],
    );
  }
}

/// Мини-ссылка-кнопка в стиле Nest (не "серый" TextButton)
class _NestLinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NestLinkButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF2E4B5A)),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E4B5A),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Primary-кнопка в стиле твоего Nest (голубой градиент)
class _NestPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NestPrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3AA8E6), Color(0xFF6C8CFF)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A2B5B7A),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}
