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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppLocalizations.of(context)!;

    final done = goal.isCompleted;

    // ✅ LifeBlock accent (used for subtle card highlight + chips/icons)
    final lifeBlock = (goal.lifeBlock ?? '').trim();
    final accent = _LifeBlockColors.accentFor(lifeBlock, cs);

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

    // ✅ Subtle highlight styling (dense + contrast, works in dark)
    final highlightOpacity = isDark ? 0.18 : 0.14;
    final borderOpacity = isDark ? 0.40 : 0.30;

    final highlight = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        accent.withOpacity(highlightOpacity),
        accent.withOpacity(0.02),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Stack(
        children: [
          // ✅ Accent overlay behind the card (keeps NestCard unchanged)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: highlight,
                ),
              ),
            ),
          ),
          NestCard(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: accent.withOpacity(borderOpacity),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusBubble(
                      done: done,
                      onTap: onToggle,
                      accent: accent,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  goal.title,
                                  style: titleStyle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _IconPillButton(
                                icon: Icons.delete_outline_rounded,
                                tooltip: t.actionDelete,
                                onTap: onDelete,
                                accent: accent,
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
                              if (lifeBlock.isNotEmpty)
                                NestPill(
                                  leading: Icon(
                                    Icons.grid_view_rounded,
                                    size: 16,
                                    color: accent,
                                  ),
                                  text: lifeBlock,
                                ),
                              if ((goal.emotion).trim().isNotEmpty)
                                NestPill(
                                  leading: Icon(
                                    Icons.emoji_emotions_outlined,
                                    size: 16,
                                    color: accent.withOpacity(0.85),
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
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBubble extends StatelessWidget {
  final bool done;
  final VoidCallback onTap;
  final Color accent;

  const _StatusBubble({
    required this.done,
    required this.onTap,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              accent.withOpacity(isDark ? 0.22 : 0.18),
              cs.surfaceContainerHighest.withOpacity(isDark ? 0.35 : 0.55),
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
                    : accent.withOpacity(isDark ? 0.45 : 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.35 : 0.20),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(isDark ? 0.06 : 0.10),
                  blurRadius: 14,
                  offset: const Offset(0, -6),
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
  final Color accent;

  const _IconPillButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: accent.withOpacity(isDark ? 0.16 : 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: accent.withOpacity(isDark ? 0.38 : 0.30),
            ),
          ),
          child: Icon(icon, size: 18, color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}

/// Centralized mapping: lifeBlock -> accent color.
/// Uses dense, premium palette aligned with Nest-blue concept.
/// - If you already store lifeBlocks in RU, this handles both RU/EN keys.
class _LifeBlockColors {
  static Color accentFor(String raw, ColorScheme cs) {
    final k = raw.trim().toLowerCase();

    // Brand anchors
    const blue = Color(0xFF42B8FD); // brand accent
    const deepBlue = Color(0xFF005DBF);

    // Premium accents per life block
    switch (k) {
      case 'health':
      case 'здоровье':
        return const Color(0xFF34D399); // emerald
      case 'career':
      case 'работа':
      case 'карьера':
        return deepBlue; // strong blue
      case 'family':
      case 'семья':
        return const Color(0xFFA78BFA); // purple
      case 'finance':
      case 'финансы':
      case 'money':
      case 'деньги':
        return const Color(0xFFFBBF24); // amber
      case 'learning':
      case 'education':
      case 'study':
      case 'учёба':
      case 'развитие':
        return const Color(0xFF22D3EE); // cyan
      case 'social':
      case 'friends':
      case 'друзья':
        return const Color(0xFFFB7185); // rose
      case 'rest':
      case 'fun':
      case 'отдых':
        return const Color(0xFF60A5FA); // light blue
      case 'balance':
      case 'баланс':
        return const Color(0xFF2DD4BF); // teal
      case 'love':
      case 'любовь':
        return const Color(0xFFF43F5E); // red-rose
      case 'creativity':
      case 'творчество':
        return const Color(0xFFF97316); // orange
      case 'general':
      default:
        return blue; // default brand accent
    }
  }
}