import 'package:flutter/material.dart';

class DashedLine extends StatelessWidget {
  /// Если не задан — берём аккуратный цвет из темы.
  final Color? color;

  /// Толщина линии (по умолчанию мягко)
  final double width;

  /// Длина штриха
  final double dash;

  /// Пробел между штрихами
  final double gap;

  const DashedLine({
    super.key,
    this.color,
    this.width = 2.0,
    this.dash = 7.0,
    this.gap = 7.0,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Очень спокойно выглядит в светлой/тёмной теме
    final base = color ?? cs.outlineVariant.withOpacity(0.9);

    return SizedBox(
      width: width,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: base,
          strokeWidth: width,
          dash: dash,
          gap: gap,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dash;
  final double gap;

  const _DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dash,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= 0 || size.width <= 0) return;

    final cx = size.width / 2;

    // “Премиум”-эффект: лёгкий мягкий glow + основная линия поверх.
    // И плюс fade сверху/снизу, чтобы не резало глаз.
    final fadeShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withOpacity(0.00),
        color.withOpacity(0.65),
        color.withOpacity(0.65),
        color.withOpacity(0.00),
      ],
      stops: const [0.0, 0.18, 0.82, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final glowPaint = Paint()
      ..color = color.withOpacity(0.18)
      ..strokeWidth = strokeWidth + 2.2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final mainPaint = Paint()
      ..shader = fadeShader
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double y = 0;
    while (y < size.height) {
      final y2 = (y + dash).clamp(0.0, size.height);

      // glow
      canvas.drawLine(Offset(cx, y), Offset(cx, y2), glowPaint);
      // main
      canvas.drawLine(Offset(cx, y), Offset(cx, y2), mainPaint);

      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) {
    return old.color != color ||
        old.strokeWidth != strokeWidth ||
        old.dash != dash ||
        old.gap != gap;
  }
}
