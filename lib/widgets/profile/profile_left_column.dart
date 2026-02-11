import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/profile_model.dart';
import 'profile_ui_helpers.dart';

// Nest UI
import '../../widgets/nest/nest_card.dart'; // <-- проверь путь/имя
import '../../widgets/nest/nest_section_title.dart'; // <-- если нет, скажи — дам без него

class ProfileLeftColumn extends StatelessWidget {
  const ProfileLeftColumn({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ProfileModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ====== HERO CARD ======
        NestCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const _Avatar(),
              const SizedBox(height: 14),

              ProfileUi.editableRow(
                context: context,
                label: 'Имя',
                value: model.name?.isNotEmpty == true ? model.name! : '—',
                onEdit: () async {
                  final v = await ProfileUi.promptText(
                    context,
                    title: 'Имя',
                    label: 'Как тебя называть?',
                    initial: model.name ?? '',
                    maxLen: 40,
                  );
                  if (v == null) return;
                  final err = await model.setName(v.isEmpty ? null : v);
                  if (err != null && context.mounted) {
                    ProfileUi.snack(context, err);
                  }
                },
              ),

              ProfileUi.editableRow(
                context: context,
                label: 'Возраст',
                value: model.age?.toString() ?? '—',
                onEdit: () async {
                  final v = await ProfileUi.promptInt(
                    context,
                    title: 'Возраст',
                    label: 'Введите возраст',
                    initial: model.age,
                    min: 10,
                    max: 120,
                  );
                  final err = await model.setAge(v);
                  if (err != null && context.mounted) {
                    ProfileUi.snack(context, err);
                  }
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ====== ACCOUNT ======
        const NestSectionTitle('Аккаунт'),
        const SizedBox(height: 10),

        NestCard(
          padding: EdgeInsets.zero,
          child: SwitchListTile(
            dense: true,
            title: const Text('Пролог пройден'),
            subtitle: const Text('Можно изменить вручную'),
            value: model.hasSeenIntro,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(22)),
            ),
            onChanged: (v) async {
              final err = await model.setHasSeenIntro(v);
              if (err != null && context.mounted) {
                ProfileUi.snack(context, err);
              }
            },
          ),
        ),

        const SizedBox(height: 16),

        // ====== TARGET HOURS ======
        const NestSectionTitle('Фокус'),
        const SizedBox(height: 10),

        ProfileUi.editableRow(
          context: context,
          label: 'Целевая норма часов/день',
          value: '${model.targetHours.toStringAsFixed(1)} ч',
          onEdit: () async {
            final v = await ProfileUi.promptDouble(
              context,
              title: 'Цель по часам в день',
              label: 'Часы',
              initial: model.targetHours,
              min: 1,
              max: 24,
              decimals: 1,
            );
            if (v == null) return;
            final err = await model.setTargetHours(v);
            if (err != null && context.mounted) {
              ProfileUi.snack(context, err);
            }
          },
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    // нежный “стеклянный” аватар как в Nest
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFD6E6F5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x142B5B7A),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.person, size: 44, color: Color(0xFF2E4B5A)),
    );
  }
}
