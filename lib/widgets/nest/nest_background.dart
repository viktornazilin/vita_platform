import 'package:flutter/material.dart';

class NestBackground extends StatelessWidget {
  final Widget child;

  /// Если нужен более "маркетинговый" экран — можно оставить мягкий вертикальный
  /// градиент. Для большинства product screens лучше flat background.
  final bool useSoftGradient;

  const NestBackground({
    super.key,
    required this.child,
    this.useSoftGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final decoration = useSoftGradient
        ? BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scheme.surface,
                scheme.surfaceContainerLow,
              ],
            ),
          )
        : BoxDecoration(
            color: scheme.surface,
          );

    return Container(
      decoration: decoration,
      child: SafeArea(
        child: child,
      ),
    );
  }
}