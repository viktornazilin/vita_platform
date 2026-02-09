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

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: cs.surfaceContainerHighest,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath!,
                height: 42, // можно настроить
                width: 42,
                fit: BoxFit.contain,
              )
            else
              Icon(icon, size: 26, color: cs.primary),

            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
