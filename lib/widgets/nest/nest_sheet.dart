import 'dart:ui';
import 'package:flutter/material.dart';

class NestSheet extends StatelessWidget {
  final Widget child;
  const NestSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.78),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(color: const Color(0xFFD6E6F5)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A2B5B7A),
                  blurRadius: 28,
                  offset: Offset(0, -10),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
