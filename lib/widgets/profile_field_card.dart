import 'package:flutter/material.dart';

class ProfileFieldCard extends StatelessWidget {
  final String label;
  final dynamic value; // <- допускаем int, List, String, null

  const ProfileFieldCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null || (value is String && value.trim().isEmpty)) {
      return const SizedBox.shrink();
    }

    Widget subtitle;
    if (value is List) {
      final list = value.cast<dynamic>();
      if (list.isEmpty) return const SizedBox.shrink();
      subtitle = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list.map<Widget>((v) => Text('- ${v.toString()}')).toList(),
      );
    } else {
      subtitle = Text(value.toString());
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle,
      ),
    );
  }
}
