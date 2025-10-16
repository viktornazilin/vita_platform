import 'package:flutter/material.dart';

typedef PopupBuilder = List<PopupMenuEntry<void>> Function(BuildContext);

class ChipItem {
  final String label;
  final VoidCallback onTap;
  final PopupBuilder? menuBuilder;
  ChipItem({required this.label, required this.onTap, this.menuBuilder});
}

class ChipsWrap extends StatelessWidget {
  final Color color;
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
          Material(
            color: color.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: it.onTap,
              onLongPress: it.menuBuilder == null
                  ? null
                  : () {
                      final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
                      final box = context.findRenderObject() as RenderBox?;
                      final offset = box?.localToGlobal(Offset.zero) ?? Offset.zero;
                      final size = box?.size ?? const Size(0, 0);
                      showMenu<void>(
                        context: context,
                        position: RelativeRect.fromLTRB(
                          offset.dx, offset.dy + size.height, overlay?.size.width ?? 0, 0,
                        ),
                        items: it.menuBuilder!(context),
                      );
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.label_rounded, size: 16),
                  const SizedBox(width: 6),
                  Text(it.label, style: TextStyle(color: cs.onSurface)),
                ]),
              ),
            ),
          ),
        trailing,
      ],
    );
  }
}
