import 'dart:ui';
import 'package:flutter/material.dart';

class NestCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const NestCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.70),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFD6E6F5)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A2B5B7A),
                    blurRadius: 26,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
