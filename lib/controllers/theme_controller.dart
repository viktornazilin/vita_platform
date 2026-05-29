import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _kSeedKey = 'app_seed_color';
  static const _kModeKey = 'app_theme_mode';

  // Ladna light palette.
  static const Color kLadnaSurfaceLight = Color(0xFFF5F3FA);
  static const Color kLadnaCardLight = Color(0xFFFAFAFE);
  static const Color kLadnaTintLight = Color(0xFFEAE6F5);
  static const Color kLadnaBorderLight = Color(0xFFE0DCF0);

  // Ladna dark palette from ladna dark home.html.
  static const Color kLadnaBodyDark = Color(0xFF0A0614);
  static const Color kLadnaSurfaceDark = Color(0xFF100C1E);
  static const Color kLadnaCardDark = Color(0xFF1C1630);
  static const Color kLadnaCardDarkHigh = Color(0xFF241B3F);
  static const Color kLadnaHeaderDark = Color(0x1F6B54C0); // rgba(107,84,192,0.12)
  static const Color kLadnaBorderDark = Color(0x2E6B54C0); // rgba(107,84,192,0.18)
  static const Color kLadnaBorderDarkStrong = Color(0x406B54C0); // rgba(107,84,192,0.25)

  static const Color kLadnaPrimary = Color(0xFF6B54C0);
  static const Color kLadnaHeroDark = Color(0xFF160E38);
  static const Color kLadnaNightHero = Color(0xFF1E1548);
  static const Color kLadnaNightHero2 = Color(0xFF2A1C60);
  static const Color kLadnaLime = Color(0xFFD4E040);
  static const Color kLadnaTeal = Color(0xFF16B8A8);
  static const Color kLadnaCoral = Color(0xFFF28B8C);
  static const Color kLadnaTextLight = Color(0xFF160E38);
  static const Color kLadnaText = Color(0xFF555268);
  static const Color kLadnaTextDark = Color(0xFFF0EEFF);
  static const Color kLadnaMuted = Color(0xFF9090A8);

  // Backward-compatible aliases used by older screens.
  static const Color kBrandDeepBlue = kLadnaHeroDark;
  static const Color kBrandBlue = kLadnaPrimary;
  static const Color kBrandAccent = kLadnaTeal;
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kAccentGold = kLadnaLime;
  static const Color kAccentAqua = kLadnaTeal;
  static const Color kAccentCoral = kLadnaCoral;
  static const Color kAccentLavender = kLadnaTintLight;

  Color _seed = kLadnaPrimary;
  ThemeMode _mode = ThemeMode.system;

  Color get seedColor => _seed;
  ThemeMode get mode => _mode;
  ThemeMode get themeMode => _mode;

  ThemeData get lightTheme => _buildTheme(brightness: Brightness.light);
  ThemeData get darkTheme => _buildTheme(brightness: Brightness.dark);

  ThemeData _buildTheme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;

    final scheme = isDark
        ? const ColorScheme.dark(
            primary: kLadnaPrimary,
            onPrimary: Colors.white,
            primaryContainer: kLadnaNightHero2,
            onPrimaryContainer: kLadnaTextDark,
            secondary: kLadnaLime,
            onSecondary: Color(0xFF303300),
            secondaryContainer: Color(0x26D4E040),
            onSecondaryContainer: kLadnaLime,
            tertiary: kLadnaTeal,
            onTertiary: Color(0xFF001F1C),
            tertiaryContainer: Color(0x2616B8A8),
            onTertiaryContainer: Color(0xFFBFFFF8),
            error: Color(0xFFFF8D8D),
            onError: Color(0xFF3D0000),
            errorContainer: Color(0xFF5F1719),
            onErrorContainer: Color(0xFFFFDADA),
            surface: kLadnaSurfaceDark,
            surfaceContainerLowest: kLadnaBodyDark,
            surfaceContainerLow: kLadnaCardDark,
            surfaceContainer: Color(0xFF211934),
            surfaceContainerHigh: kLadnaCardDarkHigh,
            surfaceContainerHighest: Color(0xFF2A2040),
            background: kLadnaSurfaceDark,
            onBackground: kLadnaTextDark,
            onSurface: kLadnaTextDark,
            onSurfaceVariant: Color(0x99FFFFFF),
            outline: kLadnaBorderDarkStrong,
            outlineVariant: kLadnaBorderDark,
            shadow: Color(0xFF000000),
          )
        : const ColorScheme.light(
            primary: kLadnaPrimary,
            onPrimary: Colors.white,
            primaryContainer: kLadnaTintLight,
            onPrimaryContainer: kLadnaHeroDark,
            secondary: kLadnaLime,
            onSecondary: Color(0xFF303300),
            secondaryContainer: Color(0xFFECEF9B),
            onSecondaryContainer: Color(0xFF303300),
            tertiary: kLadnaTeal,
            onTertiary: Colors.white,
            tertiaryContainer: Color(0xFFD9F5F2),
            onTertiaryContainer: Color(0xFF003D38),
            error: Color(0xFFE65F65),
            onError: Colors.white,
            errorContainer: Color(0xFFFFE3E5),
            onErrorContainer: Color(0xFF4A0005),
            surface: kLadnaSurfaceLight,
            surfaceContainerLowest: Colors.white,
            surfaceContainerLow: kLadnaCardLight,
            surfaceContainer: kLadnaTintLight,
            surfaceContainerHigh: Color(0xFFE2DDEF),
            surfaceContainerHighest: Color(0xFFD8D1EC),
            background: kLadnaSurfaceLight,
            onBackground: kLadnaTextLight,
            onSurface: kLadnaTextLight,
            onSurfaceVariant: kLadnaMuted,
            outline: Color(0x336B54C0),
            outlineVariant: kLadnaBorderLight,
            shadow: Color(0xFF6B54C0),
          );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? kLadnaSurfaceDark : kLadnaSurfaceLight,
      canvasColor: isDark ? kLadnaSurfaceDark : kLadnaSurfaceLight,
      cardColor: isDark ? kLadnaCardDark : kLadnaCardLight,
      dividerColor: scheme.outlineVariant,
      disabledColor: scheme.onSurfaceVariant.withOpacity(isDark ? 0.22 : 0.44),
      fontFamily: 'Geologica',
    );

    final textTheme = base.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
      decorationColor: scheme.onSurface,
    ).copyWith(
      displayLarge: base.textTheme.displayLarge?.copyWith(
        fontFamily: 'Playfair Display',
        fontWeight: FontWeight.w600,
        height: 1.02,
        letterSpacing: -1,
        color: scheme.onSurface,
      ),
      displayMedium: base.textTheme.displayMedium?.copyWith(
        fontFamily: 'Playfair Display',
        fontWeight: FontWeight.w600,
        height: 1.02,
        letterSpacing: -0.8,
        color: scheme.onSurface,
      ),
      headlineLarge: base.textTheme.headlineLarge?.copyWith(
        fontFamily: 'Playfair Display',
        fontWeight: FontWeight.w600,
        height: 1.08,
        color: scheme.onSurface,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontFamily: 'Playfair Display',
        fontWeight: FontWeight.w600,
        height: 1.10,
        color: scheme.onSurface,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
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
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      labelMedium: base.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: scheme.onSurfaceVariant,
      ),
      labelSmall: base.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: scheme.onSurfaceVariant,
      ),
    );

    final fieldFill = isDark ? kLadnaCardDark : kLadnaCardLight;
    final cardSide = BorderSide(
      color: isDark ? kLadnaBorderDark : kLadnaBorderLight,
      width: isDark ? 1.1 : 1.0,
    );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(
        color: isDark ? Colors.white.withOpacity(0.60) : scheme.onSurfaceVariant,
      ),
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      scaffoldBackgroundColor: isDark ? kLadnaSurfaceDark : kLadnaSurfaceLight,
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? kLadnaCardDark : kLadnaCardLight,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shadowColor: isDark ? Colors.black.withOpacity(0.30) : scheme.primary.withOpacity(0.07),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: cardSide,
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
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: isDark ? kLadnaCardDark : kLadnaCardLight,
        selectedTileColor: isDark ? const Color(0x336B54C0) : kLadnaTintLight,
        iconColor: isDark ? Colors.white.withOpacity(0.55) : scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: cardSide,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant.withOpacity(isDark ? 0.54 : 0.82),
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: isDark ? kLadnaLime : scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return isDark ? Colors.white.withOpacity(0.08) : Colors.white;
            return isDark ? Colors.white.withOpacity(0.04) : kLadnaTintLight;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return isDark ? kLadnaTextDark : kLadnaTextLight;
            return scheme.onSurfaceVariant;
          }),
          side: WidgetStatePropertyAll(BorderSide(color: isDark ? Colors.transparent : Colors.transparent)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: isDark ? kLadnaTextDark : kLadnaTextLight,
        unselectedLabelColor: scheme.onSurfaceVariant,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        indicator: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.surfaceContainerHigh,
          disabledForegroundColor: scheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          surfaceTintColor: Colors.transparent,
          shadowColor: isDark ? scheme.primary.withOpacity(0.38) : scheme.primary.withOpacity(0.25),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? kLadnaLime : scheme.primary,
          side: BorderSide(color: isDark ? const Color(0x40D4E040) : scheme.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? kLadnaLime : scheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xF2100C1E) : const Color(0xF5F5F3FA),
        selectedItemColor: isDark ? kLadnaLime : kLadnaPrimary,
        unselectedItemColor: isDark ? Colors.white.withOpacity(0.25) : kLadnaMuted,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
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
        backgroundColor: isDark ? kLadnaCardDark : kLadnaCardLight,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(isDark ? 0.45 : 0.14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: fieldFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: scheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: scheme.outlineVariant),
          ),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(isDark ? kLadnaCardDark : kLadnaCardLight),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: scheme.outlineVariant),
            ),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: isDark ? kLadnaCardDark : kLadnaCardLight,
        surfaceTintColor: Colors.transparent,
        textStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 3.5,
        activeTrackColor: isDark ? kLadnaLime : scheme.primary,
        inactiveTrackColor: scheme.outlineVariant.withOpacity(0.55),
        thumbColor: isDark ? kLadnaLime : scheme.primary,
        overlayColor: (isDark ? kLadnaLime : scheme.primary).withOpacity(0.14),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: isDark ? const Color(0x1AD4E040) : scheme.surfaceContainer,
        selectedColor: isDark ? const Color(0x33D4E040) : scheme.primaryContainer,
        disabledColor: scheme.surfaceContainerLow,
        labelStyle: textTheme.labelLarge?.copyWith(color: scheme.onSurface),
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(color: scheme.onSurface),
        side: BorderSide(color: isDark ? const Color(0x33D4E040) : scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: isDark ? kLadnaLime : scheme.primary,
        linearTrackColor: scheme.outlineVariant.withOpacity(0.55),
        circularTrackColor: scheme.outlineVariant.withOpacity(0.55),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return isDark ? kLadnaLime : scheme.primary;
          return isDark ? Colors.white.withOpacity(0.65) : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return isDark ? kLadnaLime.withOpacity(0.30) : scheme.primary.withOpacity(0.35);
          }
          return isDark ? Colors.white.withOpacity(0.12) : scheme.surfaceContainerHighest;
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
