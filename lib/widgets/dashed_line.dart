import 'package:flutter/material.dart';

class DashedLine extends StatelessWidget {
  final Color color;
  const DashedLine({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 3,
      child: CustomPaint(
        painter: _DashedLinePainter(color: color),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width
      ..strokeCap = StrokeCap.round;

    const dash = 8.0;
    const gap = 6.0;
    double y = 0;

    while (y < size.height) {
      double y2 = (y + dash).clamp(0, size.height).toDouble();
      final cx = size.width / 2;
      canvas.drawLine(Offset(cx, y), Offset(cx, y2), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
