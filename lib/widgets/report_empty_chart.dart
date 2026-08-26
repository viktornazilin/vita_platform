// lib/widgets/report_empty_chart.dart
import 'package:flutter/material.dart';
import 'package:nest_app/controllers/theme_controller.dart';

class ReportEmptyChart extends StatelessWidget {
  final String? text;

  const ReportEmptyChart({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final fallback = locale == 'ru' ? 'Пока недостаточно данных' : 'Not enough data yet';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final surface = isDark ? ThemeController.kLadnaCardDark : ThemeController.kLadnaCardLight;
    final border = isDark ? ThemeController.kLadnaBorderDark : ThemeController.kLadnaBorderLight;
    final muted = isDark ? const Color(0x99FFFFFF) : ThemeController.kLadnaMuted;

    return SizedBox(
      height: 140,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: ThemeController.kLadnaPrimary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.insights_rounded, size: 18, color: ThemeController.kLadnaPrimary),
              ),
              const SizedBox(width: 10),
              Text(
                text ?? fallback,
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}