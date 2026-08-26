import 'package:flutter/material.dart';
import 'package:nest_app/controllers/theme_controller.dart';

/// Единая "капсула"-шапка экрана: кнопка назад + заголовок (+ опциональный
/// подзаголовок). Раньше почти на каждом экране был свой, слегка отличающийся
/// вариант этого блока — разный радиус, разный градиент, разный размер
/// кнопки назад, а на одном экране («Задачи на день») подложки не было
/// вообще. Теперь это один виджет, используемый везде, поэтому шапка
/// выглядит и ведёт себя идентично на любом экране приложения.
class NestPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// Кнопка назад. Не нужна, если передан [leading] (например, для Home,
  /// у которого вместо "назад" — иконка дома, потому что это корневой экран).
  final VoidCallback? onBack;

  /// Заменяет стандартную круглую кнопку назад на произвольный виджет
  /// (например, иконку-домик в квадрате для Home). Капсула-подложка вокруг
  /// остаётся той же самой — меняется только содержимое слева.
  final Widget? leading;

  final Widget? trailing;

  const NestPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.leading,
    this.trailing,
  }) : assert(
          onBack != null || leading != null,
          'NestPageHeader needs either onBack (default back button) or a custom leading widget.',
        );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0x1F6B54C0), Color(0x1F6B54C0)]
              : const [Color(0xFFF0EEF8), Color(0xFFE6E2F4)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ThemeController.kLadnaPrimary.withOpacity(isDark ? .25 : .15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.30 : 0.07),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          leading ?? _BackButton(onTap: onBack!),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: isDark ? ThemeController.kLadnaTextDark : ThemeController.kLadnaTextLight,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0x4DFFFFFF) : ThemeController.kLadnaMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = ThemeController.kLadnaPrimary;
    final muted = isDark ? const Color(0x99FFFFFF) : ThemeController.kLadnaMuted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: primary.withOpacity(.12),
          shape: BoxShape.circle,
          border: Border.all(color: primary.withOpacity(.2)),
        ),
        child: Icon(Icons.chevron_left_rounded, size: 20, color: muted),
      ),
    );
  }
}