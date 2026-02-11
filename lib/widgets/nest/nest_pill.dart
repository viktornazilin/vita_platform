import 'package:flutter/material.dart';

class NestPill extends StatelessWidget {
  final Widget leading;
  final String text;

  const NestPill({super.key, required this.leading, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBBD9F7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2E4B5A),
            ),
          ),
        ],
      ),
    );
  }
}
