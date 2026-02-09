import 'package:flutter/material.dart';

class BlockChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const BlockChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: Colors.teal,
        labelStyle: TextStyle(color: selected ? Colors.white : null),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
