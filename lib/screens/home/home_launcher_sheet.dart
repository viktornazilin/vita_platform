import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/home_model.dart';
import '../../models/goals_calendar_model.dart';
import 'home_google_calendar_sheet.dart';
import 'package:nest_app/l10n/app_localizations.dart';

import '../../services/habits_repo_mixin.dart' show HabitEntryUpsert;
import '../../services/mental_repo_mixin.dart';

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
                  _NestLauncherTile(
                    icon: Icons.home,
                    label: AppLocalizations.of(ctx)!.launcherHome,
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(0);
                    },
                  ),
                  _NestLauncherTile(
                    icon: Icons.flag,
                    label: AppLocalizations.of(ctx)!.launcherGoals,
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(1);
                    },
                  ),
                  _NestLauncherTile(
                    icon: Icons.track_changes_rounded,
                    label: AppLocalizations.of(ctx)!.launcherDayGoals,
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(2);
                    },
                  ),
                  _NestLauncherTile(
                    icon: Icons.person,
                    label: AppLocalizations.of(ctx)!.launcherProfile,
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(3);
                    },
                  ),
                  _NestLauncherTile(
                    icon: Icons.insights,
                    label: AppLocalizations.of(ctx)!.launcherInsights,
                    onTap: () {
                      Navigator.pop(ctx);
                      model.select(4);
                    },
                  ),
                  _NestLauncherTile(
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

                              DateTime combine(DateTime day, TimeOfDay t) =>
                                  DateTime(
                                    day.year,
                                    day.month,
                                    day.day,
                                    t.hour,
                                    t.minute,
                                  );

                              for (final g in result.goals) {
                                final start = combine(
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

                                final hoursText = g.hours.toStringAsFixed(
                                  g.hours.truncateToDouble() == g.hours
                                      ? 0
                                      : 1,
                                );

                                final desc = g.hours > 0
                                    ? l.launcherPlannedHoursDescription(
                                        hoursText,
                                      )
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
                        color: cs.primary,
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
                        color: cs.primary,
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
                        color: cs.primary,
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

                              final hoursText =
                                  plan.plannedHours.toStringAsFixed(
                                plan.plannedHours.truncateToDouble() ==
                                        plan.plannedHours
                                    ? 0
                                    : 1,
                              );

                              final desc = plan.plannedHours > 0
                                  ? l.launcherPlannedHoursDescription(
                                      hoursText,
                                    )
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

    final sheetColor = Color.lerp(
      cs.surface,
      cs.primaryContainer,
      isDark ? 0.06 : 0.10,
    )!;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: Container(
        decoration: BoxDecoration(
          color: sheetColor.withOpacity(isDark ? 0.96 : 0.98),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(
            color: cs.primary.withOpacity(isDark ? 0.18 : 0.16),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.30)
                  : cs.primary.withOpacity(0.10),
              blurRadius: 34,
              offset: const Offset(0, -12),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerEnd = Color.lerp(
      cs.primary,
      cs.surface,
      isDark ? 0.20 : 0.10,
    )!;

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
              colors: [cs.primary, headerEnd],
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


class _NestLauncherTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NestLauncherTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = Color.lerp(
      cs.surface,
      cs.primaryContainer,
      isDark ? 0.08 : 0.14,
    )!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: cardColor.withOpacity(isDark ? 0.78 : 0.88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: cs.primary.withOpacity(isDark ? 0.20 : 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.14)
                    : cs.primary.withOpacity(0.07),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: cs.primary.withOpacity(isDark ? 0.16 : 0.10),
                    border: Border.all(
                      color: cs.primary.withOpacity(isDark ? 0.28 : 0.22),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: cs.primary,
                    size: 25,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                    height: 1.12,
                  ),
                ),
              ],
            ),
          ),
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

    final tileColor = Color.lerp(
      cs.surface,
      cs.primaryContainer,
      isDark ? 0.08 : 0.13,
    )!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(),
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: tileColor.withOpacity(isDark ? 0.80 : 0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: cs.primary.withOpacity(isDark ? 0.18 : 0.16),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.14)
                    : cs.primary.withOpacity(0.07),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primary.withOpacity(isDark ? 0.18 : 0.10),
                  border: Border.all(
                    color: cs.primary.withOpacity(isDark ? 0.30 : 0.20),
                  ),
                ),
                child: Icon(
                  icon,
                  color: cs.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: cs.onSurface,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        height: 1.18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: cs.primary.withOpacity(isDark ? 0.75 : 0.68),
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