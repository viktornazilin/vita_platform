import 'package:flutter/material.dart';

class ChipLike extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? accent;
  final bool isLifeBlock;

  const ChipLike({
    super.key,
    required this.label,
    this.icon,
    this.accent,
    this.isLifeBlock = false,
  });

  /// Специальный конструктор под “сферу”
  factory ChipLike.lifeBlock({
    Key? key,
    required String label,
    required IconData icon,
    required Color accent,
  }) {
    return ChipLike(
      key: key,
      label: label,
      icon: icon,
      accent: accent,
      isLifeBlock: true,
    );
  }

  static const _ink = Color(0xFF2E4B5A);
  static const _border = Color(0xFFD6E6F5);

  bool get _looksNumeric =>
      label.contains(RegExp(r'\d')) || label.contains('Часы') || label.contains('Важность');

  @override
  Widget build(BuildContext context) {
    final a = accent ?? const Color(0xFF3AA8E6);

    final bg = isLifeBlock
        ? a.withOpacity(0.12)
        : (_looksNumeric ? const Color(0xFF3AA8E6).withOpacity(0.12) : Colors.white.withOpacity(0.70));

    final stroke = isLifeBlock ? a.withOpacity(0.40) : (_looksNumeric ? a.withOpacity(0.35) : _border);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isLifeBlock ? 12 : 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: stroke, width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x102B5B7A),
            blurRadius: 14,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: a.withOpacity(0.95)),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: _ink.withOpacity(0.90),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.1,
                ),
          ),
        ],
      ),
    );
  }
}
