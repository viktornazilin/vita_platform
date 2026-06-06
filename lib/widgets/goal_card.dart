// lib/widgets/goal_card.dart
import 'package:flutter/material.dart';

import '../models/goal.dart';

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
    final done = goal.isCompleted;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = _blockColor(goal.lifeBlock);
    final time = TimeOfDay.fromDateTime(goal.startTime.toLocal()).format(context);

    final cardColor = dark ? const Color(0xFF241C3B) : const Color(0xFFFAFAFE);
    final borderColor = dark
        ? const Color(0xFF7D67D8).withOpacity(0.42)
        : const Color(0x1A6B54C0);
    final titleColor = dark
        ? (done ? const Color(0xFFAEA6C9) : const Color(0xFFF4F0FF))
        : (done ? const Color(0xFF9090A8) : const Color(0xFF160E38));
    final descriptionColor = dark ? const Color(0xFFD7CEF5) : const Color(0xFF555268);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black.withOpacity(0.22) : const Color(0x121C1812),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? const Color(0xFF6B54C0) : Colors.transparent,
                border: Border.all(
                  color: done
                      ? const Color(0xFF6B54C0)
                      : const Color(0xFF8F7CF2).withOpacity(dark ? .75 : .30),
                  width: 1.5,
                ),
              ),
              child: done
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                  : null,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (goal.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    goal.description.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: descriptionColor,
                    ),
                  ),
                ],
                const SizedBox(height: 9),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Chip(icon: Icons.schedule_rounded, label: time, color: const Color(0xFF8F7CF2)),
                    _Chip(icon: Icons.timer_rounded, label: '${goal.spentHours.toStringAsFixed(1)} h', color: const Color(0xFF35C58D)),
                    _Chip(icon: Icons.circle_rounded, label: _prettyBlock(goal.lifeBlock), color: accent),
                    if (goal.emotion.trim().isNotEmpty)
                      _Chip(label: goal.emotion.trim(), color: const Color(0xFFEAE6F5)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: dark ? const Color(0xFFD7CEF5) : const Color(0xFF9090A8),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color color;

  const _Chip({
    this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final isNeutral = color.value == const Color(0xFFEAE6F5).value;

    final bg = dark
        ? (isNeutral ? const Color(0xFF33274F) : color.withOpacity(.22))
        : color.withOpacity(isNeutral ? 1 : .12);
    final border = dark
        ? (isNeutral ? const Color(0xFF7D67D8).withOpacity(.38) : color.withOpacity(.38))
        : color.withOpacity(isNeutral ? 1 : .18);
    final fg = dark ? const Color(0xFFF4F0FF) : const Color(0xFF555268);
    final iconColor = dark ? const Color(0xFFF4F0FF) : (isNeutral ? const Color(0xFF555268) : color);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: iconColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

String _prettyBlock(String key) {
  switch (key.trim().toLowerCase()) {
    case 'health':
      return 'Здоровье';
    case 'career':
      return 'Карьера';
    case 'family':
      return 'Семья';
    case 'finance':
    case 'finances':
      return 'Финансы';
    case 'education':
      return 'Образование';
    case 'hobbies':
    case 'hobby':
      return 'Хобби';
    case 'general':
      return 'Общее';
    default:
      return key.isEmpty ? 'Общее' : key;
  }
}

Color _blockColor(String key) {
  switch (key.trim().toLowerCase()) {
    case 'career':
      return const Color(0xFFD4E040);
    case 'finance':
    case 'finances':
      return const Color(0xFF35C58D);
    case 'education':
      return const Color(0xFF8F7CF2);
    case 'family':
      return const Color(0xFFB6F3E1);
    case 'health':
      return const Color(0xFFFFA7B7);
    case 'hobbies':
    case 'hobby':
      return const Color(0xFFBFA7FF);
    default:
      return const Color(0xFF8F7CF2);
  }
}
