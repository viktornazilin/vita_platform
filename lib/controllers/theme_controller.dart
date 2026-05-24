import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _kSeedKey = 'app_seed_color';
  static const _kModeKey = 'app_theme_mode';

  /// Core brand palette
  static const Color kBrandDeepBlue = Color(0xFF12335A);
  static const Color kBrandBlue = Color(0xFF2F7BFF);
  static const Color kBrandAccent = Color(0xFF4EB5FF);
  static const Color kWhite = Color(0xFFFFFFFF);

  /// Complementary premium accents.
  ///
  /// These colors are intentionally not used as dominant app colors.
  /// They are designed for highlights, badges, positive/negative states,
  /// wallet-style cards, progress bars and small visual accents.
  static const Color kAccentGold = Color(0xFFE7B63D);
  static const Color kAccentAqua = Color(0xFF2FC6BB);
  static const Color kAccentCoral = Color(0xFFFF6A3D);
  static const Color kAccentLavender = Color(0xFFB9A8D9);

  Color _seed = kBrandBlue;
  ThemeMode _mode = ThemeMode.system;

  Color get seedColor => _seed;
  ThemeMode get mode => _mode;

  ThemeData get lightTheme => _buildTheme(brightness: Brightness.light);
  ThemeData get darkTheme => _buildTheme(brightness: Brightness.dark);

  ThemeData _buildTheme({required Brightness brightness}) {
    var scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );

    if (brightness == Brightness.dark) {
      // Dark mode must not use saturated blue as the main surface.
      // The app keeps the blue brand identity through primary/accent colors,
      // while cards, backgrounds and fields use deep navy neutral layers.
      scheme = scheme.copyWith(
        primary: const Color(0xFF6BB6FF),
        onPrimary: const Color(0xFF001C36),
        primaryContainer: const Color(0xFF143A66),
        onPrimaryContainer: const Color(0xFFEAF4FF),

        secondary: kAccentGold,
        onSecondary: const Color(0xFF241700),
        secondaryContainer: const Color(0xFF5D4300),
        onSecondaryContainer: const Color(0xFFFFE8A8),

        tertiary: kAccentAqua,
        onTertiary: const Color(0xFF00201C),
        tertiaryContainer: const Color(0xFF005047),
        onTertiaryContainer: const Color(0xFFB6FFF4),

        error: kAccentCoral,
        onError: const Color(0xFF3B0500),
        errorContainer: const Color(0xFF742018),
        onErrorContainer: const Color(0xFFFFDAD5),

        surface: const Color(0xFF07111F),
        surfaceContainerLowest: const Color(0xFF040912),
        surfaceContainerLow: const Color(0xFF0B1627),
        surfaceContainer: const Color(0xFF102038),
        surfaceContainerHigh: const Color(0xFF162B48),
        surfaceContainerHighest: const Color(0xFF1F3A5F),

        background: const Color(0xFF07111F),
        onBackground: const Color(0xFFF5F8FF),

        onSurface: const Color(0xFFF5F8FF),
        onSurfaceVariant: const Color(0xFFB9C9DD),

        outline: const Color(0x668DB5E8),
        outlineVariant: const Color(0x2E8DB5E8),
        shadow: const Color(0xFF000813),
      );
    } else {
      scheme = scheme.copyWith(
        primary: kBrandBlue,
        onPrimary: kWhite,
        primaryContainer: const Color(0xFFCFE1FF),
        onPrimaryContainer: const Color(0xFF08254D),

        secondary: kAccentGold,
        onSecondary: const Color(0xFF2B1B00),
        secondaryContainer: const Color(0xFFF0C96B),
        onSecondaryContainer: const Color(0xFF2F2100),

        tertiary: kAccentAqua,
        onTertiary: const Color(0xFF00201C),
        tertiaryContainer: const Color(0xFF9FDCD6),
        onTertiaryContainer: const Color(0xFF00332E),

        error: const Color(0xFFE85C45),
        onError: kWhite,
        errorContainer: const Color(0xFFFFD7CE),
        onErrorContainer: const Color(0xFF3B0500),

        surface: const Color(0xFFF3F1E9),
        surfaceContainerLowest: const Color(0xFFFFFBF2),
        surfaceContainerLow: const Color(0xFFF5EFE0),
        surfaceContainer: const Color(0xFFE7E2D1),
        surfaceContainerHigh: const Color(0xFFD7DDDF),
        surfaceContainerHighest: const Color(0xFFC9D4DA),

        background: const Color(0xFFF3F1E9),
        onBackground: const Color(0xFF172333),

        onSurface: const Color(0xFF142238),
        onSurfaceVariant: const Color(0xFF475C73),

        outline: const Color(0xFF9CB4C9),
        outlineVariant: const Color(0xFFB7C6CF),
        shadow: const Color(0xFF12335A),
      );
    }

    const fieldRadius = 18.0;
    const cardRadius = 22.0;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
    );

    final textTheme = base.textTheme.copyWith(
      displayLarge: base.textTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.00,
        color: scheme.onSurface,
        letterSpacing: -1.2,
      ),
      displayMedium: base.textTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.02,
        color: scheme.onSurface,
        letterSpacing: -0.8,
      ),
      headlineLarge: base.textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.08,
        color: scheme.onSurface,
        letterSpacing: -0.4,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.10,
        color: scheme.onSurface,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.15,
        color: scheme.onSurface,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.20,
        color: scheme.onSurface,
      ),
      titleSmall: base.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: scheme.onSurface,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w400,
        height: 1.50,
        color: scheme.onSurface,
      ),
      bodySmall: base.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.15,
        color: scheme.onSurface,
      ),
      labelMedium: base.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: scheme.onSurfaceVariant,
      ),
      labelSmall: base.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
        color: scheme.onSurfaceVariant,
      ),
    );

    final filledBg = brightness == Brightness.dark
        ? scheme.surfaceContainerHigh
        : scheme.surfaceContainerHigh;

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant),

      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,

      cardTheme: CardThemeData(
        elevation: 0,
        color: brightness == Brightness.dark
            ? scheme.surfaceContainerLow
            : scheme.surfaceContainerLowest,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: filledBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant.withOpacity(0.82),
          fontWeight: FontWeight.w400,
        ),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(
            color: scheme.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(
            color: base.colorScheme.error,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(
            color: base.colorScheme.error,
            width: 1.5,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.surfaceContainerHigh,
          disabledForegroundColor: scheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brightness == Brightness.dark
              ? scheme.primary
              : scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brightness == Brightness.dark
              ? scheme.primary
              : scheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: brightness == Brightness.dark
            ? scheme.surfaceContainerLow
            : scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface,
        ),
      ),

      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(
            brightness == Brightness.dark
                ? scheme.surfaceContainerLow
                : scheme.surfaceContainerLowest,
          ),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: scheme.outlineVariant),
            ),
          ),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      sliderTheme: SliderThemeData(
        trackHeight: 3.5,
        activeTrackColor: scheme.secondary,
        inactiveTrackColor: scheme.outlineVariant,
        thumbColor: brightness == Brightness.dark
            ? scheme.onSurface
            : scheme.primary,
        overlayColor: scheme.secondary.withOpacity(0.14),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),

      chipTheme: base.chipTheme.copyWith(
        backgroundColor: brightness == Brightness.dark
            ? scheme.surfaceContainerLow
            : scheme.surfaceContainerHighest,
        selectedColor: brightness == Brightness.dark
            ? scheme.secondary.withOpacity(0.22)
            : scheme.secondaryContainer,
        disabledColor: scheme.surfaceContainerLow,
        labelStyle: textTheme.labelLarge?.copyWith(
          color: scheme.onSurface,
        ),
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.secondary,
        linearTrackColor: scheme.outlineVariant.withOpacity(0.55),
        circularTrackColor: scheme.outlineVariant.withOpacity(0.55),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();

    final hex = sp.getInt(_kSeedKey);
    if (hex != null) {
      _seed = Color(hex);
    }

    final modeIndex = sp.getInt(_kModeKey);
    if (modeIndex != null && modeIndex >= 0 && modeIndex <= 2) {
      _mode = ThemeMode.values[modeIndex];
    }

    notifyListeners();
  }

  Future<void> setSeedColor(Color c) async {
    _seed = c;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kSeedKey, c.value);
  }

  Future<void> setMode(ThemeMode m) async {
    _mode = m;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kModeKey, m.index);
  }
}
