import 'package:flutter/material.dart';
import 'package:nest_app/controllers/theme_controller.dart';

/// Раньше эта группа виджетов (AI-инсайты, импорт целей, синхронизация с
/// календарём, инфо-чипы, ячейки целей) жила в отдельной "стеклянной синей"
/// палитре (#3AA8E6 / #2E4B5A / #D6E6F5 / #F4FAFF), никак не связанной с
/// фирменным фиолетовым стилем Ladna, и вообще не поддерживала тёмную тему —
/// цвета были захардкожены под светлый фон всегда.
///
/// NestGlassColors — единая точка входа для этой группы виджетов: резолвит
/// цвета из ThemeController (как и весь остальной app) и корректно
/// адаптируется под Theme.of(context).brightness.
class NestGlassColors {
  final bool isDark;

  final Color accent;
  final Color text;
  final Color muted;
  final Color cardFill;
  final Color border;
  final Color tint;
  final Color shadow;

  const NestGlassColors({
    required this.isDark,
    required this.accent,
    required this.text,
    required this.muted,
    required this.cardFill,
    required this.border,
    required this.tint,
    required this.shadow,
  });

  factory NestGlassColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NestGlassColors(
      isDark: isDark,
      // Тот же принцип, что уже используется в NestCard/NestPill/NestSectionTitle
      // по всему приложению: акцент — лайм в тёмной теме, фирменный фиолетовый в светлой.
      accent: isDark ? ThemeController.kLadnaLime : ThemeController.kLadnaPrimary,
      text: isDark ? ThemeController.kLadnaTextDark : ThemeController.kLadnaTextLight,
      muted: isDark ? const Color(0x99FFFFFF) : ThemeController.kLadnaMuted,
      cardFill: isDark
          ? ThemeController.kLadnaCardDark.withOpacity(0.86)
          : ThemeController.kLadnaCardLight.withOpacity(0.86),
      border: isDark ? ThemeController.kLadnaBorderDark : ThemeController.kLadnaBorderLight,
      tint: isDark ? ThemeController.kLadnaCardDark : ThemeController.kLadnaTintLight,
      shadow: isDark ? Colors.black.withOpacity(0.30) : const Color(0x1A6B54C0),
    );
  }
}
