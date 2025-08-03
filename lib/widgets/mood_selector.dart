import 'package:flutter/material.dart';

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
    return Wrap(
      spacing: 12,
      children: emojis.map((emoji) {
        return GestureDetector(
          onTap: () => onSelect(emoji),
          child: Text(
            emoji,
            style: TextStyle(
              fontSize: 32,
              decoration: selectedEmoji == emoji ? TextDecoration.underline : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
