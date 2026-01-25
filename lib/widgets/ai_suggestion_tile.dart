import 'package:flutter/material.dart';

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

    final d = item.displayDate;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
    final timeStr = item.time.format(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: item.selected,
              onChanged: (v) => onToggle(v ?? true),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: -6,
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
                      if ((item.description ?? '').isNotEmpty)
                        Text(
                          item.description!,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
