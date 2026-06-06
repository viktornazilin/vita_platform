import 'package:flutter/material.dart';
import '../models/goal.dart';
import 'chip_like.dart';
import '../controllers/life_block_ui.dart';
import 'package:nest_app/l10n/app_localizations.dart';

class GoalCell extends StatelessWidget {
  final Goal goal;
  const GoalCell({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final t = AppLocalizations.of(context)!;

    final lb = lifeBlockUI(goal.lifeBlock);

    final ink = dark ? const Color(0xFFF4F0FF) : const Color(0xFF2E4B5A);
    final metaInk = dark ? const Color(0xFFD7CEF5) : const Color(0xFF2E4B5A).withOpacity(0.72);
    final descriptionBg = dark ? const Color(0xFF2A2144) : Colors.white.withOpacity(0.62);
    final descriptionBorder = dark
        ? const Color(0xFF7D67D8).withOpacity(0.42)
        : const Color(0xFFD6E6F5);

    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w900,
      color: ink,
      letterSpacing: 0.1,
    );

    final metaStyle = theme.textTheme.bodyMedium?.copyWith(
      color: metaInk,
      height: 1.25,
      fontWeight: FontWeight.w600,
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
            ChipLike(
              label: t.goalImportanceChip(goal.importance),
              accent: lb.accent,
            ),
            ChipLike(
              label: t.goalHoursChip(goal.spentHours.toStringAsFixed(1)),
              accent: lb.accent,
            ),
          ],
        ),

        if (goal.description.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: descriptionBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: descriptionBorder),
              boxShadow: [
                BoxShadow(
                  color: dark ? Colors.black.withOpacity(0.18) : const Color(0x0C2B5B7A),
                  blurRadius: 14,
                  offset: const Offset(0, 10),
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

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF33274F) : Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: dark ? const Color(0xFF7D67D8).withOpacity(0.48) : accent.withOpacity(0.35),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black.withOpacity(0.18) : const Color(0x122B5B7A),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 18)),
    );
  }
}
