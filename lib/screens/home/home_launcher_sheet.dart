import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/home_model.dart';
import '../../models/goals_calendar_model.dart';
import 'home_google_calendar_sheet.dart';
import 'package:nest_app/l10n/app_localizations.dart';

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
              _NestSheetHeader(
                title: AppLocalizations.of(ctx)!.launcherQuickFunctionsTitle,
                subtitle: AppLocalizations.of(
                  ctx,
                )!.launcherQuickFunctionsSubtitle,
              ),
              const SizedBox(height: 14),

              _NestSectionTitle(
                AppLocalizations.of(ctx)!.launcherSectionsTitle,
              ),
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
                    label: AppLocalizations.of(ctx)!.launcherHome,
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(0);
                    },
                  ),
                  LauncherTile(
                    icon: Icons.flag,
                    label: AppLocalizations.of(ctx)!.launcherGoals,
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(1);
                    },
                  ),
                  LauncherTile(
                    icon: Icons.track_changes_rounded,
                    label: 'Цели',
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(2);
                    },
                  ),
                  LauncherTile(
                    icon: Icons.person,
                    label: AppLocalizations.of(ctx)!.launcherProfile,
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(3);
                    },
                  ),
                  LauncherTile(
                    icon: Icons.insights,
                    label: AppLocalizations.of(ctx)!.launcherInsights,
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(4);
                    },
                  ),
                  LauncherTile(
                    icon: Icons.account_balance_wallet,
                    label: AppLocalizations.of(ctx)!.launcherReports,
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(5);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 18),
              _NestSectionTitle(AppLocalizations.of(ctx)!.launcherQuickTitle),
              const SizedBox(height: 10),

              Builder(
                builder: (_) {
                  final cs = Theme.of(ctx).colorScheme;
                  final l = AppLocalizations.of(ctx)!;

                  return Column(
                    children: [
                      _NestQuickActionTile(
                        icon: Icons.bolt,
                        color: cs.primary,
                        title: l.launcherMassAddTitle,
                        subtitle: l.launcherMassAddSubtitle,
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
                              if (result.mood != null) {
                                await dbRepo.upsertMood(
                                  date: DateUtils.dateOnly(result.date),
                                  emoji: result.mood!.emoji,
                                  note: result.mood!.note,
                                );
                              }

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
                                    l.launcherSavedSummary(
                                      result.expenses.length,
                                      result.incomes.length,
                                      result.goals.length,
                                      result.habits.length,
                                      result.mood != null,
                                    ),
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l.launcherSaveError('$e')),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      _NestQuickActionTile(
                        icon: Icons.auto_awesome,
                        color: cs.tertiary,
                        title: l.launcherAiPlanTitle,
                        subtitle: l.launcherAiPlanSubtitle,
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
                            builder: (_) => AiPlanSheet(date: DateTime.now()),
                          );

                          if (created != null && context.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l.launcherCreatedGoalsCount(created),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      _NestQuickActionTile(
                        icon: Icons.psychology_alt,
                        color: cs.secondary,
                        title: l.launcherAiInsightsTitle,
                        subtitle: l.launcherAiInsightsSubtitle,
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
                      _NestQuickActionTile(
                        icon: Icons.event_repeat_rounded,
                        color: cs.primaryContainer,
                        title: l.launcherRecurringGoalTitle,
                        subtitle: l.launcherRecurringGoalSubtitle,
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
                              SnackBar(
                                content: Text(l.launcherNoDatesToCreate),
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
                                  l.launcherCreatedGoalsCount(
                                    occurrences.length,
                                  ),
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l.launcherCreateSeriesFailed('$e'),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      _NestQuickActionTile(
                        icon: Icons.calendar_month_rounded,
                        color: cs.primary,
                        title: l.launcherGoogleCalendarSyncTitle,
                        subtitle: l.launcherGoogleCalendarSyncSubtitle,
                        onTap: () async {
                          Navigator.pop(ctx);

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

class _NestSheet extends StatelessWidget {
  final Widget child;
  const _NestSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? cs.surface.withOpacity(0.92)
              : cs.surface.withOpacity(0.94),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: cs.outlineVariant.withOpacity(isDark ? 0.42 : 0.72),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.24)
                  : cs.shadow.withOpacity(0.12),
              blurRadius: 28,
              offset: const Offset(0, -10),
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
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cs.primary, cs.tertiary],
            ),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withOpacity(0.22),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(Icons.auto_awesome, color: cs.onPrimary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
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
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: cs.onSurface,
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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? cs.surfaceContainerHigh.withOpacity(0.78)
                : cs.surface.withOpacity(0.96),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: cs.outlineVariant.withOpacity(isDark ? 0.38 : 0.65),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.16)
                    : cs.shadow.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
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
                  color: color.withOpacity(isDark ? 0.20 : 0.16),
                  border: Border.all(
                    color: color.withOpacity(isDark ? 0.32 : 0.24),
                  ),
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
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Opacity(
      opacity: 0.62,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? cs.surfaceContainerHigh.withOpacity(0.72)
              : cs.surface.withOpacity(0.90),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: cs.outlineVariant.withOpacity(isDark ? 0.34 : 0.60),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.surfaceContainerHighest.withOpacity(
                  isDark ? 0.34 : 0.78,
                ),
                border: Border.all(
                  color: cs.outlineVariant.withOpacity(isDark ? 0.34 : 0.60),
                ),
              ),
              child: Icon(
                icon,
                color: cs.onSurfaceVariant.withOpacity(0.85),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
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