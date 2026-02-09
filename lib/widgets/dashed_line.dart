import 'package:flutter/material.dart';

class DashedLine extends StatelessWidget {
  final Color color;

  /// Можно подстроить под разные плотности UI (по умолчанию — премиум/мягко)
  final double width;
  final double dash;
  final double gap;

  const DashedLine({
    super.key,
    required this.color,
    this.width = 2.0,
    this.dash = 6.0,
    this.gap = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: color,
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
    final cx = size.width / 2;

    // Нежный градиент по высоте: вверху/внизу чуть растворяется,
    // выглядит мягче и “дороже”.
    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withOpacity(0.05),
        color.withOpacity(0.85),
        color.withOpacity(0.85),
        color.withOpacity(0.05),
      ],
      stops: const [0.0, 0.18, 0.82, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final paint = Paint()
      ..shader = shader
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double y = 0;
    while (y < size.height) {
      final y2 = (y + dash).clamp(0.0, size.height);
      canvas.drawLine(Offset(cx, y), Offset(cx, y2), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dash != dash ||
        oldDelegate.gap != gap;
  }
}
