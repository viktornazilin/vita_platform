import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _kSeedKey = 'app_seed_color';
  static const _kModeKey = 'app_theme_mode';

  /// Core brand palette
  static const Color kBrandDeepBlue = Color(0xFF004A98);
  static const Color kBrandBlue = Color(0xFF005DBF);
  static const Color kBrandAccent = Color(0xFF42B8FD);
  static const Color kWhite = Color(0xFFFFFFFF);

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
      // New direction:
      // not "midnight glass app", but cleaner corporate blue interface.
      scheme = scheme.copyWith(
        primary: kBrandAccent,
        secondary: const Color(0xFF8ED8FF),
        tertiary: const Color(0xFFB9E7FF),

        surface: const Color(0xFF0057B8),
        surfaceContainerLowest: const Color(0xFF004585),
        surfaceContainerLow: const Color(0xFF004F9E),
        surfaceContainer: const Color(0xFF0057B8),
        surfaceContainerHigh: const Color(0xFF0C63C4),
        surfaceContainerHighest: const Color(0xFF1A6FD0),

        background: const Color(0xFF0057B8),
        onBackground: const Color(0xFFF7FAFF),

        onSurface: const Color(0xFFF7FAFF),
        onSurfaceVariant: const Color(0xFFD7E6FA),

        outline: const Color(0x66FFFFFF),
        outlineVariant: const Color(0x33FFFFFF),
      );
    } else {
      scheme = scheme.copyWith(
        primary: kBrandBlue,
        secondary: kBrandAccent,
        tertiary: kBrandDeepBlue,

        surface: const Color(0xFFF5F9FF),
        surfaceContainerLowest: const Color(0xFFFFFFFF),
        surfaceContainerLow: const Color(0xFFF0F6FF),
        surfaceContainer: const Color(0xFFE8F1FF),
        surfaceContainerHigh: const Color(0xFFDDEAFF),
        surfaceContainerHighest: const Color(0xFFD2E3FF),

        background: const Color(0xFFF5F9FF),
        onBackground: const Color(0xFF0D2342),

        onSurface: const Color(0xFF0D2342),
        onSurfaceVariant: const Color(0xFF49627F),

        outline: const Color(0xFFB8CCE9),
        outlineVariant: const Color(0xFFD3E0F3),
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
        : scheme.surfaceContainerHighest;

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
          backgroundColor: brightness == Brightness.dark
              ? scheme.surfaceContainerHighest
              : scheme.primary,
          foregroundColor: scheme.onSurface,
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
          foregroundColor: scheme.onSurface,
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
          foregroundColor: scheme.onSurface,
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
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.outlineVariant,
        thumbColor: scheme.onSurface,
        overlayColor: scheme.primary.withOpacity(0.12),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),

      chipTheme: base.chipTheme.copyWith(
        backgroundColor: brightness == Brightness.dark
            ? scheme.surfaceContainerLow
            : scheme.surfaceContainerHighest,
        selectedColor: scheme.surfaceContainerHighest,
        disabledColor: scheme.surfaceContainerLow,
        labelStyle: textTheme.labelLarge?.copyWith(
          color: scheme.onSurface,
        ),
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
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