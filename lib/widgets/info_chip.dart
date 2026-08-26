import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nest_app/widgets/nest/nest_glass_colors.dart';

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoChip({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final c = NestGlassColors.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: c.tint.withOpacity(0.85),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: c.border),
            boxShadow: [
              BoxShadow(
                color: c.shadow,
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: c.text),
              const SizedBox(width: 8),
              Text(
                text,
                style: tt.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: c.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}