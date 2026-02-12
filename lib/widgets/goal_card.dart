import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/goal.dart';
import 'package:nest_app/l10n/app_localizations.dart';

import '../widgets/nest_card.dart';
import '../widgets/nest_pill.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final t = AppLocalizations.of(context)!;

    final done = goal.isCompleted;

    final titleStyle = tt.titleMedium?.copyWith(
      fontWeight: FontWeight.w900,
      height: 1.05,
      decoration: done ? TextDecoration.lineThrough : null,
      decorationThickness: 2.2,
      decorationColor: cs.onSurface.withOpacity(0.35),
    );

    final descStyle = tt.bodySmall?.copyWith(
      color: cs.onSurfaceVariant.withOpacity(0.9),
      height: 1.25,
    );

    final statusText = done ? t.goalStatusDone : t.goalStatusInProgress;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: NestCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusBubble(done: done, onTap: onToggle),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(goal.title, style: titleStyle, maxLines: 2),
                      ),
                      const SizedBox(width: 8),
                      _IconPillButton(
                        icon: Icons.delete_outline_rounded,
                        tooltip: t.actionDelete,
                        onTap: onDelete,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  if (goal.description.trim().isNotEmpty)
                    Text(
                      goal.description,
                      style: descStyle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      NestPill(
                        leading: Icon(
                          done
                              ? Icons.check_circle_rounded
                              : Icons.timelapse_rounded,
                          size: 16,
                          color: done ? cs.primary : cs.onSurfaceVariant,
                        ),
                        text: statusText,
                      ),
                      if ((goal.lifeBlock ?? '').trim().isNotEmpty)
                        NestPill(
                          leading: Icon(
                            Icons.grid_view_rounded,
                            size: 16,
                            color: cs.onSurfaceVariant,
                          ),
                          text: goal.lifeBlock!.trim(),
                        ),
                      if ((goal.emotion).trim().isNotEmpty)
                        NestPill(
                          leading: Icon(
                            Icons.emoji_emotions_outlined,
                            size: 16,
                            color: cs.onSurfaceVariant,
                          ),
                          text: goal.emotion.trim(),
                        ),
                    ],
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

class _StatusBubble extends StatelessWidget {
  final bool done;
  final VoidCallback onTap;

  const _StatusBubble({required this.done, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final gradient = done
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: done
                    ? cs.primary.withOpacity(0.25)
                    : cs.outlineVariant.withOpacity(0.8),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
                BoxShadow(
                  color: Color(0x1AFFFFFF),
                  blurRadius: 14,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            child: Icon(
              done ? Icons.check_rounded : Icons.circle_outlined,
              color: done ? Colors.white : cs.onSurfaceVariant,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _IconPillButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconPillButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.25),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.7)),
          ),
          child: Icon(icon, size: 18, color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}
