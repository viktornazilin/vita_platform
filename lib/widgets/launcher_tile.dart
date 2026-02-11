import 'dart:ui';
import 'package:flutter/material.dart';

class LauncherTile extends StatelessWidget {
  final String? imagePath; // путь к логотипу
  final IconData? icon; // иконка по умолчанию (если нет картинки)
  final String label;
  final VoidCallback onTap;

  const LauncherTile({
    super.key,
    this.imagePath,
    this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return _NestTile(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // icon/logo bubble
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF7FF).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBBD9F7)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A2B5B7A),
                      blurRadius: 16,
                      offset: Offset(0, 9),
                    ),
                  ],
                ),
                child: Center(
                  child: (imagePath != null)
                      ? Image.asset(
                          imagePath!,
                          height: 28,
                          width: 28,
                          fit: BoxFit.contain,
                        )
                      : Icon(
                          icon ?? Icons.apps_rounded,
                          size: 22,
                          color: cs.primary,
                        ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E4B5A),
                ),
          ),
        ],
      ),
    );
  }
}

/// ---- Nest style tile: glass card + ink ----
class _NestTile extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _NestTile({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.70),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFD6E6F5)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A2B5B7A),
                    blurRadius: 22,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
