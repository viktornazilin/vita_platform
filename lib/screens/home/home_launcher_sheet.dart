import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/home_model.dart';
import '../../models/goals_calendar_model.dart';
import 'home_google_calendar_sheet.dart';

import '../../services/habits_repo_mixin.dart' show HabitEntryUpsert;
import '../../services/mental_repo_mixin.dart';

import '../../widgets/launcher_tile.dart';
import '../../widgets/mass_daily_entry_sheet.dart';
import '../../widgets/recurring_goal_sheet.dart';
import '../../widgets/ai_plan_sheet.dart';
import '../../widgets/ai_insights_sheet.dart';

import '../../main.dart'; // dbRepo

void showHomeLauncherSheet({
  required BuildContext context,
  required HomeModel model,
}) {
  showModalBottomSheet<MassDailyEntryResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _NestSheet(
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            10,
            16,
            16 +
                MediaQuery.of(ctx).viewInsets.bottom +
                MediaQuery.of(ctx).padding.bottom,
          ),
          child: Column(
            children: [
              const _NestSheetHeader(
                title: 'Быстрые функции',
                subtitle: 'Навигация и действия в один тап',
              ),
              const SizedBox(height: 14),

              const _NestSectionTitle('Разделы'),
              const SizedBox(height: 10),

              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: .95,
                ),
                children: [
                  LauncherTile(
                    icon: Icons.home,
                    label: 'Главная',
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(0);
                    },
                  ),
                  LauncherTile(
                    icon: Icons.flag,
                    label: 'Цели',
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(1);
                    },
                  ),
                  LauncherTile(
                    icon: Icons.mood,
                    label: 'Настроение',
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(2);
                    },
                  ),
                  LauncherTile(
                    icon: Icons.person,
                    label: 'Профиль',
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(3);
                    },
                  ),
                  LauncherTile(
                    icon: Icons.insights,
                    label: 'Инсайты',
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(4);
                    },
                  ),
                  LauncherTile(
                    icon: Icons.account_balance_wallet,
                    label: 'Отчёты',
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(5);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const _NestSectionTitle('Быстро'),
              const SizedBox(height: 10),

              Builder(
                builder: (_) {
                  final cs = Theme.of(ctx).colorScheme;

                  return Column(
                    children: [
                      // ✅ Массовое добавление (логика 1-в-1)
                      _NestQuickActionTile(
                        icon: Icons.bolt,
                        color: cs.primary,
                        title: 'Массовое добавление за день',
                        subtitle: 'Расходы + Задачи + Настроение',
                        onTap: () async {
                          final goalsModel = GoalsCalendarModel();
                          await goalsModel.loadBlocks();

                          final result =
                              await showModalBottomSheet<MassDailyEntryResult>(
                                context: ctx,
                                useSafeArea: true,
                                isScrollControlled: true,
                                backgroundColor: cs.surface,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (_) => MassDailyEntrySheet(
                                  availableBlocks: goalsModel.lifeBlocks,
                                ),
                              );

                          if (result != null && context.mounted) {
                            Navigator.pop(ctx);

                            try {
                              // 1) Настроение
                              if (result.mood != null) {
                                await dbRepo.upsertMood(
                                  date: DateUtils.dateOnly(result.date),
                                  emoji: result.mood!.emoji,
                                  note: result.mood!.note,
                                );
                              }

                              // 2) Расходы
                              for (final e in result.expenses) {
                                final ts = DateTime(
                                  result.date.year,
                                  result.date.month,
                                  result.date.day,
                                  12,
                                  0,
                                );

                                await dbRepo.addTransaction(
                                  ts: ts,
                                  kind: 'expense',
                                  categoryId: e.categoryId,
                                  amount: e.amount,
                                  note: e.note.isEmpty ? null : e.note,
                                );
                              }

                              // 1.5) Привычки
                              if (result.habits.isNotEmpty) {
                                final habitRows = result.habits
                                    .map(
                                      (h) => HabitEntryUpsert(
                                        habitId: h.habitId,
                                        day: DateUtils.dateOnly(result.date),
                                        done: h.done,
                                        value: h.value,
                                      ),
                                    )
                                    .toList();

                                await dbRepo.upsertHabitEntries(habitRows);
                              }

                              // 1.6) Ментальное здоровье
                              if (result.mental.isNotEmpty) {
                                final rows = result.mental.map((a) {
                                  if (a.valueBool != null) {
                                    return MentalAnswerUpsert.yesNo(
                                      questionId: a.questionId,
                                      day: DateUtils.dateOnly(result.date),
                                      value: a.valueBool!,
                                    );
                                  }

                                  if (a.valueInt != null) {
                                    return MentalAnswerUpsert.scale(
                                      questionId: a.questionId,
                                      day: DateUtils.dateOnly(result.date),
                                      value: a.valueInt!,
                                    );
                                  }

                                  return MentalAnswerUpsert.text(
                                    questionId: a.questionId,
                                    day: DateUtils.dateOnly(result.date),
                                    value: (a.valueText ?? '').trim(),
                                  );
                                }).toList();

                                await dbRepo.upsertMentalAnswers(rows);
                              }

                              // 2.5) Доходы
                              for (final i in result.incomes) {
                                final ts = DateTime(
                                  result.date.year,
                                  result.date.month,
                                  result.date.day,
                                  12,
                                  0,
                                );

                                await dbRepo.addTransaction(
                                  ts: ts,
                                  kind: 'income',
                                  categoryId: i.categoryId,
                                  amount: i.amount,
                                  note: i.note.isEmpty ? null : i.note,
                                );
                              }

                              // 3) Задачи
                              DateTime _combine(DateTime day, TimeOfDay t) =>
                                  DateTime(
                                    day.year,
                                    day.month,
                                    day.day,
                                    t.hour,
                                    t.minute,
                                  );

                              for (final g in result.goals) {
                                final start = _combine(
                                  result.date,
                                  g.startTime ??
                                      const TimeOfDay(hour: 9, minute: 0),
                                );
                                final deadline = DateTime(
                                  result.date.year,
                                  result.date.month,
                                  result.date.day,
                                  23,
                                  59,
                                  0,
                                );

                                final desc = g.hours > 0
                                    ? 'План: ${g.hours.toStringAsFixed(g.hours.truncateToDouble() == g.hours ? 0 : 1)} ч'
                                    : '';

                                await dbRepo.createGoal(
                                  title: g.title,
                                  description: desc,
                                  deadline: deadline,
                                  lifeBlock: g.lifeBlock,
                                  importance: g.importance,
                                  emotion: g.emotion ?? '',
                                  spentHours: g.hours,
                                  startTime: start,
                                );
                              }

                              // 4) Привычки (повторная запись)
                              final habitRows = result.habits
                                  .map(
                                    (h) => HabitEntryUpsert(
                                      habitId: h.habitId,
                                      day: DateUtils.dateOnly(result.date),
                                      done: h.done,
                                      value: h.value,
                                    ),
                                  )
                                  .toList();

                              if (habitRows.isNotEmpty) {
                                await dbRepo.upsertHabitEntries(habitRows);
                              }

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Сохранено: '
                                    '${result.expenses.length} расход(ов), '
                                    '${result.incomes.length} доход(ов), '
                                    '${result.goals.length} задач(и), '
                                    '${result.habits.length} привыч(ек)'
                                    '${result.mood != null ? ', настроение' : ''}',
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Ошибка сохранения: $e'),
                                ),
                              );
                            }
                          }
                        },
                      ),

                      const SizedBox(height: 10),

                      // 🔮 AI-план
                      _NestQuickActionTile(
                        icon: Icons.auto_awesome,
                        color: cs.tertiary,
                        title: 'AI-план на неделю/месяц',
                        subtitle: 'Анализ целей, опроса и прогресса',
                        onTap: () async {
                          final created = await showModalBottomSheet<int>(
                            context: ctx,
                            useSafeArea: true,
                            isScrollControlled: true,
                            showDragHandle: true,
                            backgroundColor: cs.surface,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (_) => const AiPlanSheet(),
                          );

                          if (created != null && context.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Создано целей: $created'),
                              ),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 10),

                      // 🧠 AI-инсайты
                      _NestQuickActionTile(
                        icon: Icons.psychology_alt,
                        color: cs.secondary,
                        title: 'AI-инсайты',
                        subtitle: 'Как события влияют на цели и прогресс',
                        onTap: () async {
                          await showModalBottomSheet<void>(
                            context: ctx,
                            useSafeArea: true,
                            isScrollControlled: true,
                            backgroundColor: cs.surface,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (_) => const AiInsightsSheet(),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      // 🔁 Регулярная цель
                      _NestQuickActionTile(
                        icon: Icons.event_repeat_rounded,
                        color: cs.primaryContainer,
                        title: 'Регулярная цель',
                        subtitle: 'Планирование на несколько дней вперёд',
                        onTap: () async {
                          final plan =
                              await showModalBottomSheet<RecurringGoalPlan>(
                                context: ctx,
                                useSafeArea: true,
                                isScrollControlled: true,
                                showDragHandle: true,
                                backgroundColor: cs.surface,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (_) => const RecurringGoalSheet(),
                              );

                          if (plan == null) return;

                          final today = DateUtils.dateOnly(DateTime.now());

                          DateTime combine(DateTime day, TimeOfDay t) =>
                              DateTime(
                                day.year,
                                day.month,
                                day.day,
                                t.hour,
                                t.minute,
                              );

                          List<DateTime> buildOccurrences() {
                            final start = DateUtils.dateOnly(today);
                            final until = DateUtils.dateOnly(plan.until);

                            final out = <DateTime>[];
                            if (until.isBefore(start)) return out;

                            if (plan.type == RecurrenceType.everyNDays) {
                              final step = plan.everyNDays < 1
                                  ? 1
                                  : plan.everyNDays;
                              for (
                                var day = start;
                                !day.isAfter(until);
                                day = day.add(Duration(days: step))
                              ) {
                                out.add(combine(day, plan.time));
                              }
                              return out;
                            }

                            final wds = plan.weekdays.isEmpty
                                ? {start.weekday}
                                : plan.weekdays;
                            for (
                              var day = start;
                              !day.isAfter(until);
                              day = day.add(const Duration(days: 1))
                            ) {
                              if (wds.contains(day.weekday)) {
                                out.add(combine(day, plan.time));
                              }
                            }
                            return out;
                          }

                          final occurrences = buildOccurrences();

                          if (occurrences.isEmpty) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Нет дат для создания (проверь дедлайн/настройки).',
                                ),
                              ),
                            );
                            return;
                          }

                          try {
                            Navigator.pop(ctx);

                            for (final start in occurrences) {
                              final deadline = DateTime(
                                start.year,
                                start.month,
                                start.day,
                                23,
                                59,
                              );

                              final desc = plan.plannedHours > 0
                                  ? 'План: ${plan.plannedHours.toStringAsFixed(plan.plannedHours.truncateToDouble() == plan.plannedHours ? 0 : 1)} ч'
                                  : '';

                              await dbRepo.createGoal(
                                title: plan.title,
                                description: desc,
                                deadline: deadline,
                                lifeBlock: plan.lifeBlock,
                                importance: plan.importance,
                                emotion: plan.emotion,
                                spentHours: plan.plannedHours,
                                startTime: start,
                              );
                            }

                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Создано целей: ${occurrences.length}',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Не удалось создать серию целей: $e',
                                ),
                              ),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 10),

                      // ✅ Google Calendar (теперь КЛИКАБЕЛЬНО)
                      _NestQuickActionTile(
                        icon: Icons.calendar_month_rounded,
                        color: cs.primary,
                        title: 'Синхронизация с Google Calendar',
                        subtitle: 'Экспорт целей в календарь',
                        onTap: () async {
                          Navigator.pop(ctx); // закрываем launcher sheet

                          await showModalBottomSheet<void>(
                            context: context,
                            useSafeArea: true,
                            isScrollControlled: true,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surface,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (_) => const HomeGoogleCalendarSheet(),
                          );
                        },
                      ),

                      // Если хочешь оставить disabled-заготовку — оставь эту строку вместо плитки выше:
                      // _NestQuickActionTileDisabled(...),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ============================================================================
// Nest sheet widgets (локально)
// ============================================================================

class _NestSheet extends StatelessWidget {
  final Widget child;
  const _NestSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.78),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: const Color(0xFFD6E6F5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A2B5B7A),
              blurRadius: 28,
              offset: Offset(0, -10),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _NestSheetHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _NestSheetHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3AA8E6), Color(0xFF6C8CFF)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F2B5B7A),
                blurRadius: 16,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: tt.bodySmall?.copyWith(
                  color: const Color(0xFF2E4B5A).withOpacity(0.75),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NestSectionTitle extends StatelessWidget {
  final String text;
  const _NestSectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: const Color(0xFF2E4B5A),
        ),
      ),
    );
  }
}

class _NestQuickActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Future<void> Function() onTap;

  const _NestQuickActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => onTap(),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.72),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD6E6F5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x142B5B7A),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.14),
                border: Border.all(color: const Color(0xFFD6E6F5)),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: tt.bodySmall?.copyWith(
                      color: const Color(0xFF2E4B5A).withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF2E4B5A)),
          ],
        ),
      ),
    );
  }
}

class _NestQuickActionTileDisabled extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _NestQuickActionTileDisabled({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Opacity(
      opacity: 0.55,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.62),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD6E6F5)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2E4B5A).withOpacity(0.08),
                border: Border.all(color: const Color(0xFFD6E6F5)),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2E4B5A).withOpacity(0.7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: tt.bodySmall?.copyWith(
                      color: const Color(0xFF2E4B5A).withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
