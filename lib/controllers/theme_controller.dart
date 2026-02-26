import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _kSeedKey = 'app_seed_color';
  static const _kModeKey = 'app_theme_mode';

  /// Brand palette (from your reference)
  static const Color kBrandDeepBlue = Color(0xFF004A98); // background
  static const Color kBrandBlue = Color(0xFF005DBF); // primary
  static const Color kBrandAccent = Color(0xFF42B8FD); // cyan-blue accent
  static const Color kWhite = Color(0xFFFFFFFF);

  // Default seed = brand blue
  Color _seed = kBrandBlue;

  // Theme mode
  ThemeMode _mode = ThemeMode.system;

  Color get seedColor => _seed;
  ThemeMode get mode => _mode;

  ThemeData get lightTheme => _buildTheme(brightness: Brightness.light);
  ThemeData get darkTheme => _buildTheme(brightness: Brightness.dark);

  ThemeData _buildTheme({required Brightness brightness}) {
    // Base scheme from seed, then we "lock" premium surfaces for contrast
    var scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );

    if (brightness == Brightness.dark) {
      // ✅ Dense navy dark theme (high contrast, premium)
      scheme = scheme.copyWith(
        // Brand
        primary: kBrandAccent, // accent as primary highlight in dark
        secondary: kBrandAccent,
        tertiary: kBrandBlue,

        // Surfaces (deep navy, not gray)
        surface: const Color(0xFF06162D),
        surfaceContainerLowest: const Color(0xFF040F20),
        surfaceContainerLow: const Color(0xFF071E3E),
        surfaceContainer: const Color(0xFF082247),
        surfaceContainerHigh: const Color(0xFF0A2854),
        surfaceContainerHighest: const Color(0xFF0D2F60),

        // Text colors (readability)
        onSurface: const Color(0xFFEAF3FF),
        onSurfaceVariant: const Color(0xFFB7C8E6),

        // Outlines
        outline: const Color(0xFF1E3B6A),
        outlineVariant: const Color(0xFF152E55),

        // Background (scaffold uses surface anyway, but keep coherent)
        background: const Color(0xFF06162D),
        onBackground: const Color(0xFFEAF3FF),
      );
    } else {
      // ✅ Light theme with slightly blue-tinted surfaces (no pure white glare)
      scheme = scheme.copyWith(
        // Brand
        primary: kBrandBlue,
        secondary: kBrandAccent,
        tertiary: kBrandDeepBlue,

        // Surfaces (dense but light)
        surface: const Color(0xFFF2F7FF),
        surfaceContainerLowest: const Color(0xFFFFFFFF),
        surfaceContainerLow: const Color(0xFFF6FAFF),
        surfaceContainer: const Color(0xFFEAF2FF),
        surfaceContainerHigh: const Color(0xFFE2EEFF),
        surfaceContainerHighest: const Color(0xFFDCE9FF),

        // Text colors (high contrast)
        onSurface: const Color(0xFF0A1B33),
        onSurfaceVariant: const Color(0xFF3A5172),

        // Outlines
        outline: const Color(0xFFC4D7F5),
        outlineVariant: const Color(0xFFD7E5FA),

        background: const Color(0xFFF2F7FF),
        onBackground: const Color(0xFF0A1B33),
      );
    }

    final radius = 18.0;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
    );

    return base.copyWith(
      // ✅ Readability across the app
      textTheme: base.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant),

      // ✅ Web-fix: disable ink splash/hover highlight (clean premium look)
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,

      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: scheme.outline.withOpacity(0.22)),
        ),
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // subtle transparency but keep contrast
        fillColor: (brightness == Brightness.dark)
            ? scheme.surfaceContainerHigh.withOpacity(0.72)
            : scheme.surfaceContainerHighest.withOpacity(0.95),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: scheme.outline.withOpacity(0.22)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: scheme.outline.withOpacity(0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(
            color: scheme.primary.withOpacity(0.85),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        labelStyle: TextStyle(color: scheme.onSurface.withOpacity(0.76)),
        hintStyle: TextStyle(color: scheme.onSurface.withOpacity(0.50)),
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          textStyle: base.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          side: BorderSide(color: scheme.outline.withOpacity(0.28)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          textStyle: base.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: base.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // Bottom sheets
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titleTextStyle: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
        contentTextStyle: base.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface.withOpacity(0.92),
        ),
      ),

      // Menus
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: scheme.outline.withOpacity(0.22)),
          ),
        ),
      ),

      sliderTheme: const SliderThemeData(
        trackHeight: 3.5,
        overlayShape: RoundSliderOverlayShape(overlayRadius: 18),
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withOpacity(0.45),
        thickness: 1,
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