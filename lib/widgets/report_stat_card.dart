// lib/widgets/report_stat_card.dart
import 'package:flutter/material.dart';
import 'package:nest_app/controllers/theme_controller.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? ThemeController.kLadnaCardDark : ThemeController.kLadnaCardLight;
    final border = isDark ? ThemeController.kLadnaBorderDark : ThemeController.kLadnaBorderLight;
    final dark = isDark ? ThemeController.kLadnaTextDark : ThemeController.kLadnaTextLight;
    final muted = isDark ? const Color(0x99FFFFFF) : ThemeController.kLadnaMuted;
    const primary = ThemeController.kLadnaPrimary;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.24 : 0.07),
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
              color: primary.withOpacity(.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primary.withOpacity(.18)),
            ),
            child: const Icon(Icons.insights_rounded, color: primary, size: 20),
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
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: dark,
                    height: 1,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    color: muted,
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