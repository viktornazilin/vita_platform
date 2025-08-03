import 'package:flutter/material.dart';
import '../models/xp.dart';

class XPProgressBar extends StatelessWidget {
  final XP xp;

  const XPProgressBar({super.key, required this.xp});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Level ${xp.level}', style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: xp.progressPercent(),
          minHeight: 12,
          color: Colors.teal,
          backgroundColor: Colors.teal.withOpacity(0.2),
        ),
        const SizedBox(height: 8),
        Text('${xp.currentXP} / ${xp.xpToLevelUp()} XP'),
      ],
    );
  }
}
