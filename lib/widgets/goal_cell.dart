import 'dart:ui';

import 'package:flutter/material.dart';
import '../models/goal.dart';

class GoalCell extends StatelessWidget {
  final Goal goal;
  const GoalCell({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDone = goal.isCompleted;

    final titleStyle = (theme.textTheme.titleMedium ?? const TextStyle())
        .copyWith(
          fontWeight: FontWeight.w800,
          height: 1.12,
          letterSpacing: 0.1,
          color: theme.colorScheme.onSurface.withOpacity(isDone ? 0.62 : 0.95),
          decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
          decorationThickness: 1.5,
        );

    final metaStyle = (theme.textTheme.bodyMedium ?? const TextStyle())
        .copyWith(
          height: 1.25,
          color: theme.colorScheme.onSurface.withOpacity(isDone ? 0.45 : 0.72),
        );

    final descStyle = (theme.textTheme.bodyMedium ?? const TextStyle())
        .copyWith(
          height: 1.3,
          color: theme.colorScheme.onSurface.withOpacity(isDone ? 0.42 : 0.68),
        );

    final importance = goal.importance.clamp(1, 5);
    final spent = goal.spentHours;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Верхняя строка: title + emotion
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                goal.title,
                style: titleStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (goal.emotion.isNotEmpty) ...[
              const SizedBox(width: 10),
              _EmojiPill(emoji: goal.emotion, isDone: isDone),
            ],
          ],
        ),

        const SizedBox(height: 10),

        // Метаданные (пиллы)
        Wrap(
          runSpacing: 8,
          spacing: 10,
          children: [
            _SoftPill(
              label: goal.lifeBlock,
              icon: Icons.circle,
              iconSize: 10,
              isDone: isDone,
            ),
            _SoftPill(
              label: 'Важность $importance/5',
              icon: Icons.local_fire_department_rounded,
              isDone: isDone,
              // аккуратный “акцент” по важности
              accentStrength: (importance / 5.0),
            ),
            _SoftPill(
              label: 'Часы ${spent.toStringAsFixed(1)}',
              icon: Icons.schedule_rounded,
              isDone: isDone,
            ),
          ],
        ),

        if (goal.description.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            goal.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: descStyle,
          ),
        ],

        // Тихая подсказка “план/статус” (не навязчиво)
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(
              isDone
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(
                isDone ? 0.45 : 0.28,
              ),
            ),
            const SizedBox(width: 6),
            Text(isDone ? 'Выполнено' : 'Запланировано', style: metaStyle),
          ],
        ),
      ],
    );
  }
}

class _SoftPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final double iconSize;
  final bool isDone;

  /// 0..1 — насколько сильно подсветить (например, важность)
  final double accentStrength;

  const _SoftPill({
    required this.label,
    this.icon,
    this.iconSize = 16,
    required this.isDone,
    this.accentStrength = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final baseBg = const Color(0x7011121A);
    final border = Colors.white.withOpacity(0.12);

    // мягкая подсветка (не цвет задаём “жёстко”, а работаем прозрачностью)
    final accent = primary.withOpacity(
      (0.10 + 0.18 * accentStrength) * (isDone ? 0.55 : 1.0),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: baseBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accent, Colors.transparent],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x44000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0x14FFFFFF),
                blurRadius: 12,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: iconSize,
                  color: theme.colorScheme.onSurface.withOpacity(
                    isDone ? 0.45 : 0.75,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: (theme.textTheme.labelMedium ?? const TextStyle())
                    .copyWith(
                      letterSpacing: 0.2,
                      color: theme.colorScheme.onSurface.withOpacity(
                        isDone ? 0.55 : 0.86,
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmojiPill extends StatelessWidget {
  final String emoji;
  final bool isDone;

  const _EmojiPill({required this.emoji, required this.isDone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0x7011121A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x44000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            emoji,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withOpacity(
                isDone ? 0.7 : 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
