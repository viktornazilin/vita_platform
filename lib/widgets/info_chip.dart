import 'dart:ui';
import 'package:flutter/material.dart';

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoChip({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF7FF).withOpacity(0.85),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFBBD9F7)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A2B5B7A),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: const Color(0xFF2E4B5A)),
              const SizedBox(width: 8),
              Text(
                text,
                style: tt.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E4B5A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
