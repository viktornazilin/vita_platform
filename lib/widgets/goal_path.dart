import 'package:flutter/material.dart';
import '../models/goal.dart';

class GoalPath extends StatelessWidget {
  final List<Goal> goals;
  final void Function(Goal goal) onToggle;

  const GoalPath({super.key, required this.goals, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final rows = <List<Goal>>[];
    for (int i = 0; i < goals.length; i += 3) {
      rows.add(goals.sublist(i, (i + 3).clamp(0, goals.length)));
    }

    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 24),
      itemBuilder: (context, rowIndex) {
        final row = rows[rowIndex];
        final reversed = rowIndex.isOdd;
        final display = reversed ? row.reversed.toList() : row;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int i = 0; i < display.length; i++) ...[
              _GoalBubble(
                goal: display[i],
                index: rowIndex * 3 + i + 1,
                onTap: () => onToggle(display[i]),
              ),
              if (i != display.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: Colors.black12,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
            ]
          ],
        );
      },
    );
  }
}

class _GoalBubble extends StatelessWidget {
  final Goal goal;
  final int index;
  final VoidCallback onTap;

  const _GoalBubble({required this.goal, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final done = goal.isCompleted;
    final bg = done ? Colors.teal : Colors.white;
    final fg = done ? Colors.white : Colors.black87;
    final border = done ? Colors.teal : Colors.black26;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: bg,
            child: done
                ? const Icon(Icons.check, color: Colors.white)
                : Text(index.toString(), style: TextStyle(color: fg, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 90,
            child: Text(
              goal.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(color: fg),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 56,
            height: 4,
            decoration: BoxDecoration(
              color: border.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
