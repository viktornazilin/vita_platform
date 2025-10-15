// lib/ui/responsive.dart
import 'package:flutter/material.dart';

/// Брейкпоинты совместимые с Material 3
class Breakpoints {
  static const double compact = 600;   // телефоны
  static const double medium  = 1024;  // планшеты/малые ноуты
  static const double expanded = 1440; // десктоп
}

extension ResponsiveX on BuildContext {
  double get screenW => MediaQuery.sizeOf(this).width;
  double get screenH => MediaQuery.sizeOf(this).height;

  bool get isCompact  => screenW < Breakpoints.compact;
  bool get isMedium   => screenW >= Breakpoints.compact && screenW < Breakpoints.medium;
  bool get isExpanded => screenW >= Breakpoints.medium;

  /// Базовый горизонтальный паддинг (увеличивается на широких экранах)
  EdgeInsets get pagePadding {
    if (isCompact) return const EdgeInsets.all(16);
    if (isMedium)  return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
  }

  /// Удобный maxWidth для контента (центрирование на больших экранах)
  double get maxContentWidth {
    if (isCompact) return double.infinity;   // телефон — на всю ширину
    if (isMedium)  return 900;               // планшет/малые ноуты
    return 1200;                             // десктоп
  }

  /// Сколько колонок в сетке
  int responsiveColumns({int min = 2, int mid = 3, int max = 4}) {
    if (isCompact) return min;   // 2
    if (isMedium)  return mid;   // 3
    return max;                  // 4+
  }
}

/// Центрует дочерний виджет и ограничивает maxWidth (для десктопа/веба)
class CenteredConstrained extends StatelessWidget {
  final double maxWidth;
  final Widget child;
  const CenteredConstrained({super.key, required this.maxWidth, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
