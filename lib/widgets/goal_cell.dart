import 'package:flutter/material.dart';
import '../models/goal.dart';
import 'chip_like.dart';
import '../controllers/life_block_ui.dart';

class GoalCell extends StatelessWidget {
  final Goal goal;
  const GoalCell({super.key, required this.goal});

  static const _ink = Color(0xFF2E4B5A);
  static const _border = Color(0xFFD6E6F5);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lb = lifeBlockUI(goal.lifeBlock);

    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w900,
      color: _ink,
      letterSpacing: 0.1,
    );

    final metaStyle = theme.textTheme.bodyMedium?.copyWith(
      color: _ink.withOpacity(0.72),
      height: 1.25,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                goal.title,
                style: titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _EmotionBadge(
              emoji: goal.emotion.isEmpty ? '🙂' : goal.emotion,
              accent: lb.accent,
            ),
          ],
        ),
        const SizedBox(height: 10),

        Wrap(
          runSpacing: 8,
          spacing: 10,
          children: [
            ChipLike.lifeBlock(
              label: lb.label,
              icon: lb.icon,
              accent: lb.accent,
            ),
            ChipLike(label: 'Важность ${goal.importance}/5', accent: lb.accent),
            ChipLike(label: 'Часы ${goal.spentHours.toStringAsFixed(1)}', accent: lb.accent),
          ],
        ),

        if (goal.description.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.62),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C2B5B7A),
                  blurRadius: 14,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Text(
              goal.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: metaStyle,
            ),
          ),
        ],
      ],
    );
  }
}

class _EmotionBadge extends StatelessWidget {
  final String emoji;
  final Color accent;
  const _EmotionBadge({required this.emoji, required this.accent});

  static const _ink = Color(0xFF2E4B5A);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.35), width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x122B5B7A),
            blurRadius: 18,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Color(0x08FFFFFF),
            blurRadius: 12,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 18, color: _ink),
      ),
    );
  }
}
