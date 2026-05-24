// lib/widgets/mood/mood_week_card.dart
import 'package:flutter/material.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../../widgets/report_section_card.dart';
import '../../models/week_insights.dart';

class MoodWeekCard extends StatelessWidget {
  final List<DateTime> days;
  final List<int> scores;
  final WeekdayLabel weekdayLabel;

  const MoodWeekCard({
    super.key,
    required this.days,
    required this.scores,
    required this.weekdayLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final filled = scores.where((v) => v > 0).length;
    final valid = scores.where((v) => v > 0).toList();
    final avg = valid.isEmpty
        ? null
        : valid.reduce((a, b) => a + b) / valid.length;

    return ReportSectionCard(
      title: l.moodWeekTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MoodBars(days: days, scores: scores, weekdayLabel: weekdayLabel),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniPill(
                icon: Icons.check_circle_rounded,
                label: l.moodWeekMarkedCount(filled, 7),
              ),
              _MiniPill(
                icon: Icons.auto_graph_rounded,
                label: avg == null
                    ? l.moodWeekAverageDash
                    : l.moodWeekAverageValue(avg.toStringAsFixed(1)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l.moodWeekFooterHint,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _MoodBars extends StatelessWidget {
  final List<DateTime> days;
  final List<int> scores;
  final WeekdayLabel weekdayLabel;

  const _MoodBars({
    required this.days,
    required this.scores,
    required this.weekdayLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color fillFor(int score) {
      if (score >= 4) return cs.secondary;
      if (score == 3) return cs.primary;
      if (score > 0) return cs.tertiary;
      return cs.surfaceContainerHighest;
    }

    return _Inset(
      radius: 18,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(days.length, (i) {
            final v = scores[i].clamp(0, 5);
            final h = 10 + (v * 10);

            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    height: v == 0 ? 8 : h.toDouble(),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: v == 0
                          ? null
                          : LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.lerp(fillFor(v), Colors.white, isDark ? 0.06 : 0.18)!,
                                fillFor(v),
                              ],
                            ),
                      color: v == 0
                          ? cs.surfaceContainerHighest.withOpacity(
                              isDark ? 0.24 : 0.42,
                            )
                          : null,
                      border: Border.all(
                        color: v == 0
                            ? cs.outlineVariant.withOpacity(isDark ? 0.38 : 0.52)
                            : fillFor(v).withOpacity(isDark ? 0.72 : 0.86),
                      ),
                      boxShadow: v == 0
                          ? null
                          : [
                              BoxShadow(
                                color: fillFor(v).withOpacity(isDark ? 0.20 : 0.18),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    weekdayLabel(days[i]),
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
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return _Inset(
      radius: 999,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: cs.secondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _Inset extends StatelessWidget {
  final Widget child;
  final double radius;

  const _Inset({required this.child, this.radius = 18});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = cs.secondary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color.lerp(
            cs.surfaceContainerHighest,
            accent,
            isDark ? 0.055 : 0.095,
          ),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: Color.lerp(
              cs.outlineVariant,
              accent,
              isDark ? 0.16 : 0.24,
            )!,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(isDark ? 0.025 : 0.055),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
