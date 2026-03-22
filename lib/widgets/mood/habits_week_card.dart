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

    if (habits.isEmpty) {
      return ReportSectionCard(
        title: l.habitsWeekTitle,
        child: Text(
          l.habitsWeekEmptyHint,
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
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
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l.habitsWeekFooterHint,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
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

    final doneFill = cs.primary;
    final doneBorder = isDark
        ? cs.primary.withOpacity(0.95)
        : cs.primary.withOpacity(0.90);

    final emptyFill = isDark
        ? cs.surfaceContainerHighest.withOpacity(0.22)
        : Colors.white.withOpacity(0.06);

    final emptyBorder = isDark
        ? cs.outlineVariant.withOpacity(0.60)
        : Colors.white.withOpacity(0.55);

    final countBg = isDark
        ? cs.primary.withOpacity(0.22)
        : Colors.white.withOpacity(0.10);

    final countBorder = isDark
        ? cs.primary.withOpacity(0.45)
        : Colors.white.withOpacity(0.35);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: countBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: countBorder, width: 1.4),
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
        const SizedBox(height: 10),
        Row(
          children: List.generate(days.length, (i) {
            final d = days[i];
            final map = entriesByDay[d] ?? {};
            final e = map[habit.id];
            final done = (e?['done'] as bool?) ?? false;

            return Expanded(
              child: Column(
                children: [
                  Container(
                    height: 46,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: done ? doneFill : emptyFill,
                      border: Border.all(
                        color: done ? doneBorder : emptyBorder,
                        width: done ? 1.8 : 1.4,
                      ),
                      boxShadow: done
                          ? [
                              BoxShadow(
                                color: cs.primary.withOpacity(
                                  isDark ? 0.35 : 0.22,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
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
                          : null,
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
    );
  }
}