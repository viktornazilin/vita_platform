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
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2EEFF).withOpacity(0.90),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFDCD2FF)),
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
                          height: 42,
                          width: 42,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          icon ?? Icons.apps_rounded,
                          size: 20,
                          color: cs.primary,
                        ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 7),

          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 12,
              height: 1.05,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF17123A),
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
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.78),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE4DDF6)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A2B5B7A),
                    blurRadius: 22,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(padding: const EdgeInsets.all(10), child: child),
            ),
          ),
        ),
      ),
    );
  }
}
