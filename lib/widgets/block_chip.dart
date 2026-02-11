import 'dart:ui';
import 'package:flutter/material.dart';

class BlockChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const BlockChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bg = selected
        ? cs.primary.withOpacity(0.95)
        : cs.surface.withOpacity(0.72);

    final border = selected
        ? cs.primary.withOpacity(0.35)
        : cs.outlineVariant.withOpacity(0.55);

    final fg = selected ? Colors.white : cs.onSurface;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: bg,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: fg,
                    letterSpacing: 0.15,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
