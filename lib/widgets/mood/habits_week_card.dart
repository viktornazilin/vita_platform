// lib/widgets/mood/habits_week_card.dart
import 'package:flutter/material.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../../models/habit.dart';
import '../../models/week_insights.dart';
import '../../widgets/report_section_card.dart';

class HabitsWeekCard extends StatelessWidget {
  final List<DateTime> days;
  final List<Habit> habits;
  final Map<DateTime, Map<String, Map<String, dynamic>>> entriesByDay;
  final Map<String, int> doneCount;
  final WeekdayLabel weekdayLabel;

  const HabitsWeekCard({
    super.key,
    required this.days,
    required this.habits,
    required this.entriesByDay,
    required this.doneCount,
    required this.weekdayLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (habits.isEmpty) {
      return ReportSectionCard(
        title: l.habitsWeekTitle,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Color.lerp(
              cs.surfaceContainerLowest,
              cs.secondary,
              isDark ? 0.045 : 0.065,
            ),
            border: Border.all(
              color: Color.lerp(
                cs.outlineVariant,
                cs.secondary,
                isDark ? 0.16 : 0.20,
              )!,
            ),
          ),
          child: Text(
            l.habitsWeekEmptyHint,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return ReportSectionCard(
      title: l.habitsWeekTopTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final h in habits) ...[
            _HabitHeatmapRow(
              habit: h,
              days: days,
              entriesByDay: entriesByDay,
              doneCount: doneCount[h.id] ?? 0,
              weekdayLabel: weekdayLabel,
            ),
            if (h != habits.last) const SizedBox(height: 16),
          ],
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Color.lerp(
                cs.surfaceContainerHighest,
                cs.secondary,
                isDark ? 0.07 : 0.10,
              ),
              border: Border.all(
                color: Color.lerp(
                  cs.outlineVariant,
                  cs.secondary,
                  isDark ? 0.18 : 0.22,
                )!,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, size: 18, color: cs.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.habitsWeekFooterHint,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitHeatmapRow extends StatelessWidget {
  final Habit habit;
  final List<DateTime> days;
  final Map<DateTime, Map<String, Map<String, dynamic>>> entriesByDay;
  final int doneCount;
  final WeekdayLabel weekdayLabel;

  const _HabitHeatmapRow({
    required this.habit,
    required this.days,
    required this.entriesByDay,
    required this.doneCount,
    required this.weekdayLabel,
  });

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = _isDark(context);
    final completion = (doneCount / 7).clamp(0.0, 1.0);

    final accent = completion >= 0.85
        ? cs.secondary
        : completion >= 0.45
            ? cs.primary
            : cs.tertiary;

    final doneFill = Color.lerp(cs.primary, cs.secondary, 0.30)!;
    final doneBorder = Color.lerp(cs.primary, cs.secondary, 0.42)!;

    final emptyFill = Color.lerp(
      cs.surfaceContainerHighest,
      cs.secondary,
      isDark ? 0.035 : 0.055,
    )!;

    final emptyBorder = Color.lerp(
      cs.outlineVariant,
      cs.secondary,
      isDark ? 0.12 : 0.16,
    )!;

    final countBg = Color.lerp(
      cs.surfaceContainerHighest,
      accent,
      isDark ? 0.14 : 0.18,
    )!;

    final countBorder = Color.lerp(
      cs.outlineVariant,
      accent,
      isDark ? 0.28 : 0.32,
    )!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Color.lerp(
          cs.surfaceContainerLowest,
          accent,
          isDark ? 0.030 : 0.045,
        ),
        border: Border.all(
          color: Color.lerp(cs.outlineVariant, accent, isDark ? 0.12 : 0.16)!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 24,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.20),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  habit.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: countBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: countBorder, width: 1.2),
                ),
                child: Text(
                  '$doneCount/7',
                  style: tt.titleSmall?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(days.length, (i) {
              final d = days[i];
              final map = entriesByDay[d] ?? {};
              final e = map[habit.id];
              final done = (e?['done'] as bool?) ?? false;

              return Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      height: 46,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: done
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  cs.primary,
                                  doneFill,
                                  cs.secondary.withOpacity(isDark ? 0.78 : 0.88),
                                ],
                              )
                            : null,
                        color: done ? null : emptyFill,
                        border: Border.all(
                          color: done ? doneBorder : emptyBorder,
                          width: done ? 1.6 : 1.2,
                        ),
                        boxShadow: done
                            ? [
                                BoxShadow(
                                  color: cs.primary.withOpacity(
                                    isDark ? 0.24 : 0.16,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                                BoxShadow(
                                  color: cs.secondary.withOpacity(
                                    isDark ? 0.10 : 0.14,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: done
                            ? Icon(
                                Icons.check_rounded,
                                size: 20,
                                color: cs.onPrimary,
                              )
                            : Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: cs.outlineVariant.withOpacity(
                                    isDark ? 0.46 : 0.72,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weekdayLabel(d),
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
