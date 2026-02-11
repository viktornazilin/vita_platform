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

    // Nest-like glass pill (без blur, чтобы не было артефактов на web)
    final bg = selected
        ? cs.primary.withOpacity(0.92)
        : cs.surface.withOpacity(0.55);

    final border = selected
        ? cs.primary.withOpacity(0.30)
        : cs.outlineVariant.withOpacity(0.45);

    final fg = selected ? Colors.white : cs.onSurface.withOpacity(0.92);

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(selected ? 0.10 : 0.06),
                  blurRadius: selected ? 16 : 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
    );
  }
}
