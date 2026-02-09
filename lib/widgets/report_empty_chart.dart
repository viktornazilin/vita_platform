import 'package:flutter/material.dart';

class ReportEmptyChart extends StatelessWidget {
  const ReportEmptyChart({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insights_outlined, color: cs.onSurfaceVariant),
            const SizedBox(height: 6),
            Text(
              'Недостаточно данных',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
