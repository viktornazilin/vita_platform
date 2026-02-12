import 'package:flutter/material.dart';

import '../../models/habit.dart';
import '../../models/week_insights.dart';
import '../../widgets/report_section_card.dart';

class HabitsWeekCard extends StatelessWidget {
  final List<DateTime> days;
  final List<Habit> habits; // уже отфильтрованные top (например take(3))
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (habits.isEmpty) {
      return ReportSectionCard(
        title: 'Привычки',
        child: Text(
          'Добавь хотя бы одну привычку — и тут появится прогресс.',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      );
    }

    return ReportSectionCard(
      title: 'Привычки (топ недели)',
      child: Column(
        children: [
          for (final h in habits) ...[
            _HabitHeatmapRow(
              habit: h,
              days: days,
              entriesByDay: entriesByDay,
              doneCount: doneCount[h.id] ?? 0,
              weekdayLabel: weekdayLabel,
            ),
            if (h != habits.last) const SizedBox(height: 12),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Показываем самые активные привычки за 7 дней.',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$doneCount/7',
              style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
                    height: 22,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: done
                          ? cs.tertiary.withOpacity(0.80)
                          : cs.surfaceContainerHighest.withOpacity(0.30),
                      border: Border.all(
                        color: cs.outlineVariant.withOpacity(0.55),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    weekdayLabel(d),
                    style: TextStyle(
                      fontSize: 11,
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
