import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _kSeedKey = 'app_seed_color';
  static const _kModeKey = 'app_theme_mode';

  Color _seed = const Color(0x83DDF9);
  ThemeMode _mode = ThemeMode.system;

  Color get seedColor => _seed;
  ThemeMode get mode => _mode;

  ThemeData get lightTheme => _buildTheme(brightness: Brightness.light);
  ThemeData get darkTheme => _buildTheme(brightness: Brightness.dark);

  ThemeData _buildTheme({required Brightness brightness}) {
    // базовая схема от seed
    var scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);

    // premium dark surfaces
    if (brightness == Brightness.dark) {
      scheme = scheme.copyWith(
        surface: const Color(0xFF0F111A),
        surfaceContainerHighest: const Color(0xFF141827),
        surfaceContainerHigh: const Color(0xFF121526),
        surfaceContainer: const Color(0xFF101324),
        surfaceContainerLow: const Color(0xFF0E1120),
        surfaceContainerLowest: const Color(0xFF0B0D14),
        outline: const Color(0xFF2A2F45),
        outlineVariant: const Color(0xFF1F2436),
      );
    }

    final radius = 18.0;

    // ⚠️ ВАЖНО:
    // НЕ используем Typography.material2021().black.apply(...)
    // иначе на Web будут TextStyle inherit conflicts при lerp()
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
    );

    return base.copyWith(
      // ✅ Web-fix: полностью отключаем Ink (splash/highlight/hover/focus),
      // чтобы не создавать _InkFeatures и избежать GlobalKey ink renderer бага.
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,

      // Карточки
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: scheme.outline.withOpacity(0.18)),
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
      ),

      // Инпуты
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: (brightness == Brightness.dark)
            ? const Color(0x6611121A)
            : scheme.primary.withOpacity(0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: scheme.outline.withOpacity(0.18)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: scheme.outline.withOpacity(0.14)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(
            color: scheme.primary.withOpacity(0.60),
            width: 1.4,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        labelStyle: TextStyle(color: scheme.onSurface.withOpacity(0.70)),
        hintStyle: TextStyle(color: scheme.onSurface.withOpacity(0.45)),
      ),

      // Buttons (без Ink)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          textStyle: base.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          side: BorderSide(color: scheme.outline.withOpacity(0.22)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          textStyle: base.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: base.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),

      // BottomSheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),

      // Menu / Dropdown (без Ink)
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: scheme.outline.withOpacity(0.18)),
          ),
        ),
      ),

      // Slider
      sliderTheme: const SliderThemeData(
        trackHeight: 3.5,
        overlayShape: RoundSliderOverlayShape(overlayRadius: 18),
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withOpacity(0.35),
        thickness: 1,
      ),
    );
  }

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final hex = sp.getInt(_kSeedKey);
    if (hex != null) _seed = Color(hex);

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
