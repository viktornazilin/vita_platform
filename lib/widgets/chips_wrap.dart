import 'dart:ui';
import 'package:flutter/material.dart';

typedef PopupBuilder = List<PopupMenuEntry<void>> Function(BuildContext);

class ChipItem {
  final String label;
  final VoidCallback onTap;
  final PopupBuilder? menuBuilder;
  ChipItem({required this.label, required this.onTap, this.menuBuilder});
}

class ChipsWrap extends StatelessWidget {
  final Color color; // базовый оттенок “чипов” (как у тебя было)
  final List<ChipItem> items;
  final Widget trailing;

  const ChipsWrap({
    super.key,
    required this.color,
    required this.items,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final it in items)
          _NestChip(
            tint: color,
            label: it.label,
            onTap: it.onTap,
            onLongPressMenu: it.menuBuilder == null
                ? null
                : () => _showChipMenu(context, it.menuBuilder!),
          ),
        trailing,
      ],
    );
  }

  void _showChipMenu(BuildContext context, PopupBuilder builder) {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    final box = context.findRenderObject() as RenderBox?;
    final offset = box?.localToGlobal(Offset.zero) ?? Offset.zero;
    final size = box?.size ?? const Size(0, 0);

    showMenu<void>(
      context: context,
      // позиционирование оставил как у тебя, чтобы логика не потерялась
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        overlay?.size.width ?? 0,
        0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: builder(context),
    );
  }
}

class _NestChip extends StatelessWidget {
  const _NestChip({
    required this.tint,
    required this.label,
    required this.onTap,
    required this.onLongPressMenu,
  });

  final Color tint;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPressMenu;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // адаптивный “премиум” чип: мягкий tint + тонкая рамка + лёгкий blur
    final bg = Color.lerp(tint, cs.surface, 0.68)!.withOpacity(0.78);
    final border = cs.outlineVariant.withOpacity(0.55);
    final iconColor = cs.onSurfaceVariant;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: bg,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPressMenu,
            splashColor: cs.primary.withOpacity(0.10),
            highlightColor: cs.primary.withOpacity(0.06),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.label_rounded, size: 16, color: iconColor),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                      ),
                    ),
                    if (onLongPressMenu != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.more_horiz_rounded,
                        size: 16,
                        color: cs.onSurfaceVariant.withOpacity(0.9),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
