import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/goal.dart';

import '../widgets/nest_card.dart';
import '../widgets/nest_pill.dart';

class GoalPath extends StatelessWidget {
  final List<Goal> goals;
  final void Function(Goal goal) onToggle;

  const GoalPath({super.key, required this.goals, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // режем по 3 в ряд
    final rows = <List<Goal>>[];
    for (int i = 0; i < goals.length; i += 3) {
      rows.add(goals.sublist(i, math.min(i + 3, goals.length)));
    }

    if (rows.isEmpty) {
      return Center(
        child: NestPill(
          leading: Icon(Icons.route_rounded, size: 16, color: cs.primary),
          text: 'Нет целей в пути',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 22),
      itemBuilder: (context, rowIndex) {
        final row = rows[rowIndex];
        final reversed = rowIndex.isOdd;
        final display = reversed ? row.reversed.toList() : row;

        return _RowTrack(
          indexOffset: rowIndex * 3,
          goals: display,
          onToggle: onToggle,
        );
      },
    );
  }
}

class _RowTrack extends StatelessWidget {
  final int indexOffset;
  final List<Goal> goals;
  final void Function(Goal) onToggle;

  const _RowTrack({
    required this.indexOffset,
    required this.goals,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return NestCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < goals.length; i++) ...[
                _GoalBubble(
                  goal: goals[i],
                  index: indexOffset + i + 1,
                  onTap: () => onToggle(goals[i]),
                ),
                if (i != goals.length - 1)
                  Expanded(
                    child: _ConnectorLine(
                      height: 3,
                      color: cs.outlineVariant.withOpacity(0.65),
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          _RowProgress(goals: goals, color: cs.primary),
        ],
      ),
    );
  }
}

class _ConnectorLine extends StatelessWidget {
  final double height;
  final Color color;
  const _ConnectorLine({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color,
      ),
    );
  }
}

class _RowProgress extends StatelessWidget {
  final List<Goal> goals;
  final Color color;

  const _RowProgress({required this.goals, required this.color});

  @override
  Widget build(BuildContext context) {
    final done = goals.where((g) => g.isCompleted).length;
    final total = goals.length == 0 ? 1 : goals.length;
    final v = (done / total).clamp(0.0, 1.0);

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(value: v, minHeight: 8),
          ),
        ),
        const SizedBox(width: 10),
        NestPill(
          leading: const Icon(Icons.check_circle_rounded, size: 16),
          text: '$done/$total',
        ),
      ],
    );
  }
}

class _GoalBubble extends StatelessWidget {
  final Goal goal;
  final int index;
  final VoidCallback onTap;

  const _GoalBubble({
    required this.goal,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final done = goal.isCompleted;

    final bg = done
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primary.withOpacity(0.95),
              cs.primary.withOpacity(0.55),
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.surface.withOpacity(0.92),
              cs.surfaceContainerHighest.withOpacity(0.55),
            ],
          );

    final border = done
        ? cs.primary.withOpacity(0.25)
        : cs.outlineVariant.withOpacity(0.8);

    final fg = done ? Colors.white : cs.onSurface;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: SizedBox(
        width: 98,
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: bg,
                border: Border.all(color: border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A2B5B7A),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Color(0x22FFFFFF),
                    blurRadius: 14,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check_rounded, color: Colors.white)
                    : Text(
                        index.toString(),
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: fg,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              goal.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: tt.labelMedium?.copyWith(
                color: done ? cs.primary : cs.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 54,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: done
                    ? cs.primary.withOpacity(0.35)
                    : cs.outlineVariant.withOpacity(0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
