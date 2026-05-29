// lib/widgets/report_empty_chart.dart
import 'package:flutter/material.dart';

class ReportEmptyChart extends StatelessWidget {
  final String? text;

  const ReportEmptyChart({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final fallback = locale == 'ru' ? 'Пока недостаточно данных' : 'Not enough data yet';

    return SizedBox(
      height: 140,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0DCF0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1C1812).withOpacity(.07),
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
                  color: const Color(0xFF6B54C0).withOpacity(.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.insights_rounded, size: 18, color: Color(0xFF6B54C0)),
              ),
              const SizedBox(width: 10),
              Text(
                text ?? fallback,
                style: const TextStyle(
                  color: Color(0xFF9090A8),
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
