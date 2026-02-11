import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/habits_model.dart';
import '../../models/habit.dart';
import 'profile_ui_helpers.dart';

// Nest UI (проверь пути/имена)
import '../../widgets/nest/nest_card.dart';
import '../../widgets/nest/nest_sheet.dart';

class HabitsCard extends StatelessWidget {
  const HabitsCard({super.key});

  Future<(String title, bool neg)?> _openHabitEditor(
    BuildContext context, {
    Habit? existing,
  }) async {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    bool isNeg = existing?.isNegative ?? false;

    final res = await showModalBottomSheet<(String, bool)>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NestSheet(
        child: StatefulBuilder(
          builder: (ctx, setSt) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 14,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SheetHeader(
                    title: existing == null
                        ? 'Новая привычка'
                        : 'Редактировать привычку',
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: titleCtrl,
                    maxLength: 60,
                    decoration: const InputDecoration(
                      labelText: 'Название',
                      hintText: 'Например: Утренняя зарядка',
                    ),
                  ),
                  const SizedBox(height: 10),

                  NestCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isNeg
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle_outline_rounded,
                          color: const Color(0xFF2E4B5A),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Негативная привычка',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2E4B5A),
                            ),
                          ),
                        ),
                        Switch(
                          value: isNeg,
                          onChanged: (v) => setSt(() => isNeg = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isNeg
                        ? 'Отмечай, если хочешь отслеживать и сокращать.'
                        : 'Позитивная/нейтральная привычка для укрепления.',
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF2E4B5A).withOpacity(0.65),
                          fontWeight: FontWeight.w700,
                        ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Отмена'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final t = titleCtrl.text.trim();
                            if (t.isEmpty) return;
                            Navigator.pop(ctx, (t, isNeg));
                          },
                          child: const Text('Сохранить'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    titleCtrl.dispose();
    return res;
  }

  Future<bool> _confirmDelete(BuildContext context, Habit h) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NestSheet(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SheetHeader(title: 'Удалить привычку?'),
              const SizedBox(height: 10),
              Text(
                '«${h.title}» будет удалена без возможности восстановления.',
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF2E4B5A).withOpacity(0.8),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Удалить'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return ok == true;
  }

  Future<void> _saveHabit(BuildContext context, {Habit? existing}) async {
    final res = await _openHabitEditor(context, existing: existing);
    if (res == null) return;

    final habits = context.read<HabitsModel>();
    String? err;
    if (existing == null) {
      err = await habits.create(title: res.$1, isNegative: res.$2);
    } else {
      err = await habits.update(existing.id, title: res.$1, isNegative: res.$2);
    }

    if (err != null && context.mounted) ProfileUi.snack(context, err);
  }

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitsModel>();

    return NestCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Привычки',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2E4B5A),
                      ),
                ),
              ),
              IconButton(
                tooltip: 'Добавить',
                onPressed: () => _saveHabit(context),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (habits.loading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else if (habits.items.isEmpty)
            Text(
              'Пока нет привычек. Добавь первую.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF2E4B5A).withOpacity(0.7),
                    fontWeight: FontWeight.w700,
                  ),
            )
          else
            ...habits.items.map((h) => _HabitRow(
                  habit: h,
                  onTap: () => _saveHabit(context, existing: h),
                  onEdit: () => _saveHabit(context, existing: h),
                  onDelete: () async {
                    final ok = await _confirmDelete(context, h);
                    if (!ok) return;
                    final err = await context.read<HabitsModel>().delete(h.id);
                    if (err != null && context.mounted) ProfileUi.snack(context, err);
                  },
                )),

          const SizedBox(height: 10),
          Text(
            'Позже добавим “отсеивание” привычек на главном экране.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF2E4B5A).withOpacity(0.55),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _HabitRow extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HabitRow({
    required this.habit,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isNeg = habit.isNegative;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD6E6F5)),
          ),
          child: Row(
            children: [
              Icon(
                isNeg
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline_rounded,
                size: 18,
                color: const Color(0xFF2E4B5A),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2E4B5A),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isNeg ? 'Негативная' : 'Позитивная/нейтральная',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E4B5A).withOpacity(0.65),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              IconButton(
                tooltip: 'Изменить',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Удалить',
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final String title;
  const _SheetHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF2E4B5A).withOpacity(0.20),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2E4B5A),
                ),
          ),
        ),
      ],
    );
  }
}
