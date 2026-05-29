// lib/widgets/report_stat_card.dart
import 'package:flutter/material.dart';

class ReportStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const ReportStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  static const _surface = Color(0xFFFAFAFE);
  static const _border = Color(0xFFE0DCF0);
  static const _primary = Color(0xFF6B54C0);
  static const _dark = Color(0xFF160E38);
  static const _muted = Color(0xFF9090A8);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C1812).withOpacity(.07),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _primary.withOpacity(.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _primary.withOpacity(.18)),
            ),
            child: Icon(icon, color: _primary, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontFamilyFallback: ['Playfair Display', 'Georgia'],
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: _dark,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
