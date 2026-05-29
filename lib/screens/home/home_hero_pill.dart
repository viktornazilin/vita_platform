import 'package:flutter/material.dart';

class HomeHeroPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;

  const HomeHeroPill({
    super.key,
    required this.icon,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFE),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x1A6B54C0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C1812).withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x1F6B54C0),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF6B54C0)),
          ),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF160E38),
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                sublabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.labelSmall?.copyWith(
                  color: const Color(0xFF9090A8),
                  fontWeight: FontWeight.w500,
                  height: 1.05,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
