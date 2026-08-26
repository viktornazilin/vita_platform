import 'dart:ui';
import 'package:flutter/material.dart';
import 'nest/nest_glass_colors.dart';

class MoodSelector extends StatelessWidget {
  final String selectedEmoji;
  final Function(String) onSelect;

  const MoodSelector({
    super.key,
    required this.selectedEmoji,
    required this.onSelect,
  });

  static const List<String> emojis = ['😊', '😐', '😢', '😠', '😴', '🤩'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: emojis.map((emoji) {
        final selected = selectedEmoji == emoji;

        return _MoodChip(
          emoji: emoji,
          selected: selected,
          onTap: () => onSelect(emoji),
          primary: cs.primary,
        );
      }).toList(),
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String emoji;
  final bool selected;
  final VoidCallback onTap;
  final Color primary;

  const _MoodChip({
    required this.emoji,
    required this.selected,
    required this.onTap,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final c = NestGlassColors.of(context);

    final bg = selected ? primary.withOpacity(0.16) : c.tint;
    final border = selected
        ? primary.withOpacity(0.45)
        : c.border;
    final shadow = selected
        ? [
            BoxShadow(
              color: c.shadow,
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ]
        : [
            BoxShadow(
              color: c.shadow.withOpacity(c.isDark ? 0.20 : 0.08),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ];

    return Semantics(
      button: true,
      selected: selected,
      label: 'Mood $emoji',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: c.cardFill.withOpacity(0.70),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border),
                boxShadow: shadow,
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.6,
                  colors: [bg, c.cardFill.withOpacity(0.55)],
                ),
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 160),
                style: TextStyle(fontSize: selected ? 34 : 32, height: 1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji),
                    if (selected) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: primary.withOpacity(0.85),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}