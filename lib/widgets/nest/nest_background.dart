import 'dart:ui';
import 'package:flutter/material.dart';

class NestBackground extends StatelessWidget {
  final Widget child;
  const NestBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _Bg(),
        SafeArea(child: child),
      ],
    );
  }
}

class _Bg extends StatelessWidget {
  const _Bg();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF7FCFF),
            Color(0xFFEAF6FF),
            Color(0xFFD7EEFF),
            Color(0xFFF2FAFF),
          ],
        ),
      ),
      child: Stack(
        children: const [
          Positioned(top: -140, left: -120, child: _SoftBlob(size: 360)),
          Positioned(bottom: -180, right: -140, child: _SoftBlob(size: 420)),
          Positioned(top: 120, right: -90, child: _SoftBlob(size: 240)),
        ],
      ),
    );
  }
}

class _SoftBlob extends StatelessWidget {
  final double size;
  const _SoftBlob({required this.size});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Color(0x663AA8E6),
              Color(0x0058B9FF),
            ],
          ),
        ),
      ),
    );
  }
}
