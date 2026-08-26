import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nest_app/widgets/nest/nest_glass_colors.dart';

import '../../models/ai/ai_suggestion.dart';
import '../widgets/info_chip.dart';

class AiSuggestionTile extends StatelessWidget {
  final AiSuggestion item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  const AiSuggestionTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final c = NestGlassColors.of(context);

    final d = item.displayDate;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
    final timeStr = item.time.format(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: c.cardFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.border),
            boxShadow: [
              BoxShadow(
                color: c.shadow,
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 9, 9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(-2, -2),
                  child: Checkbox(
                    value: item.selected,
                    activeColor: cs.primary,
                    // ✅ фикс: null не превращаем в true
                    onChanged: (v) => onToggle(v ?? item.selected),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: tt.labelLarge?.copyWith(
                          fontSize: 13,
                          height: 1.08,
                          fontWeight: FontWeight.w900,
                          color: c.text,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          InfoChip(icon: Icons.calendar_today, text: dateStr),
                          InfoChip(icon: Icons.access_time, text: timeStr),

                          if (item.lifeBlock != null)
                            InfoChip(
                              icon: Icons.category_outlined,
                              text: item.lifeBlock!,
                            ),

                          if (item.hours != null)
                            InfoChip(
                              icon: Icons.timer_outlined,
                              text:
                                  '${item.hours!.toStringAsFixed(item.hours!.truncateToDouble() == item.hours ? 0 : 1)} ч',
                            ),
                        ],
                      ),

                      if ((item.description ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.description!.trim(),
                          style: tt.bodySmall?.copyWith(
                            fontSize: 11.5,
                            height: 1.22,
                            fontWeight: FontWeight.w600,
                            color: c.muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                _EditButton(onTap: onEdit, c: c),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final VoidCallback onTap;
  final NestGlassColors c;
  const _EditButton({required this.onTap, required this.c});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: c.tint,
          border: Border.all(color: c.border),
        ),
        child: Icon(
          Icons.edit_outlined,
          size: 20,
          color: c.accent,
        ),
      ),
    );
  }
}