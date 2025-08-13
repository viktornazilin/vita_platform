import 'package:flutter/material.dart';
import '../models/goal.dart';
import 'chip_like.dart';

class GoalCell extends StatelessWidget {
  final Goal goal;
  const GoalCell({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final metaColor = theme.colorScheme.onSurface.withOpacity(0.75);

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
            if (goal.emotion.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(goal.emotion, style: const TextStyle(fontSize: 16)),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          runSpacing: 6,
          spacing: 12,
          children: [
            ChipLike(label: goal.lifeBlock),
            ChipLike(label: 'Важность ${goal.importance}/5'),
            ChipLike(label: 'Часы ${goal.spentHours.toStringAsFixed(1)}'),
          ],
        ),
        if (goal.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            goal.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: metaColor),
          ),
        ],
      ],
    );
  }
}
