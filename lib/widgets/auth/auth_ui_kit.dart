import 'package:flutter/material.dart';

import '../../controllers/theme_controller.dart';

/// Единый набор цветов для auth-экранов (Login/Register/PasswordReset и т.д.).
///
/// Раньше этот класс был приватным и продублирован один в один в
/// login_screen.dart и register_screen.dart с захардкоженными хексами.
/// Теперь это один файл, и цвета берутся из [ThemeController], поэтому
/// смена палитры в одном месте автоматически применяется везде.
class AuthColors {
  final bool isDark;
  final Color background;
  final Color card;
  final Color input;
  final Color border;
  final Color text;
  final Color muted;
  final Color primary;
  final Color accent;
  final Color error;

  const AuthColors({
    required this.isDark,
    required this.background,
    required this.card,
    required this.input,
    required this.border,
    required this.text,
    required this.muted,
    required this.primary,
    required this.accent,
    required this.error,
  });

  factory AuthColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return AuthColors(
      isDark: isDark,
      background:
          isDark ? ThemeController.kLadnaSurfaceDark : ThemeController.kLadnaSurfaceLight,
      card: isDark ? ThemeController.kLadnaCardDark : ThemeController.kLadnaCardLight,
      input: isDark ? const Color(0x0DFFFFFF) : Colors.white,
      // Раньше border у auth-экранов был другого цвета (0x1A6B54C0), чем у
      // остального приложения (kLadnaBorderLight/Dark). Приводим к общему.
      border: isDark ? ThemeController.kLadnaBorderDark : ThemeController.kLadnaBorderLight,
      text: isDark ? ThemeController.kLadnaTextDark : ThemeController.kLadnaTextLight,
      muted: isDark ? const Color(0x66FFFFFF) : ThemeController.kLadnaMuted,
      primary: ThemeController.kLadnaPrimary,
      accent: ThemeController.kLadnaLime,
      error: scheme.error,
    );
  }
}

/// Единый радиус и высота для auth-контролов — совпадают со значениями,
/// которые ThemeController задаёт для кнопок/карточек по всему приложению.
class AuthDims {
  static const double controlRadius = 16; // как filledButtonTheme/outlinedButtonTheme
  static const double panelRadius = 24; // как dialogTheme
  static const double heroRadius = 26;
  static const double buttonHeight = 52; // единая высота и для primary, и для secondary
}

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final c = AuthColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.background,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: c.isDark
              ? const [Color(0xFF100C1E), Color(0xFF0A0614)]
              : const [Color(0xFFF5F3FA), Color(0xFFEEF7F5), Color(0xFFF6F0DF)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: Glow(size: 240, color: c.primary.withOpacity(c.isDark ? 0.20 : 0.12)),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Glow(size: 260, color: c.accent.withOpacity(c.isDark ? 0.12 : 0.18)),
          ),
          child,
        ],
      ),
    );
  }
}

class AuthHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData trailing;

  const AuthHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final c = AuthColors.of(context);
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AuthDims.heroRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: c.isDark
              ? const [Color(0xFF1E1548), Color(0xFF2A1C60)]
              : const [Color(0xFF160E38), Color(0xFF2A1C5A)],
        ),
        border: Border.all(color: c.primary.withOpacity(c.isDark ? 0.30 : 0.16)),
        boxShadow: [
          BoxShadow(
            color: c.isDark
                ? c.primary.withOpacity(0.26)
                : const Color(0xFF160E38).withOpacity(0.20),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: c.primary.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.primary.withOpacity(0.32)),
            ),
            child: const Center(
              child: Text('✦', style: TextStyle(fontSize: 28, color: Colors.black)),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.displaySmall?.copyWith(
                    color: const Color(0xFFFAF6EE),
                    fontWeight: FontWeight.w700,
                    height: 0.95,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: tt.bodyLarge?.copyWith(
                    color: const Color(0xFFFAF6EE).withOpacity(0.45),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(trailing, color: const Color(0xFFFAF6EE).withOpacity(0.45)),
        ],
      ),
    );
  }
}

class AuthPanel extends StatelessWidget {
  final Widget child;

  const AuthPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final c = AuthColors.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AuthDims.panelRadius),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: c.isDark ? Colors.black.withOpacity(0.30) : c.primary.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final String labelText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final void Function(String)? onFieldSubmitted;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.focusNode,
    this.keyboardType,
    this.autofillHints,
    this.textInputAction,
    this.validator,
    this.suffixIcon,
    this.obscureText = false,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final c = AuthColors.of(context);
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      validator: validator,
      obscureText: obscureText,
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyle(color: c.text, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: c.muted),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: c.input,
        labelStyle: TextStyle(color: c.muted, fontWeight: FontWeight.w600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuthDims.controlRadius),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuthDims.controlRadius),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuthDims.controlRadius),
          borderSide: BorderSide(color: c.primary, width: 1.4),
        ),
      ),
    );
  }
}

class PrimaryAuthButton extends StatelessWidget {
  final bool busy;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const PrimaryAuthButton({
    super.key,
    required this.busy,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final c = AuthColors.of(context);
    if (busy) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    return SizedBox(
      height: AuthDims.buttonHeight,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AuthDims.controlRadius)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
    );
  }
}

class SecondaryAuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

  const SecondaryAuthButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final c = AuthColors.of(context);
    return SizedBox(
      // Раньше здесь была высота 50, а у PrimaryAuthButton — 52.
      // Теперь обе кнопки на одном экране одинаковой высоты.
      height: AuthDims.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: c.text,
          side: BorderSide(color: c.border, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AuthDims.controlRadius)),
          backgroundColor: c.input,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class AuthDivider extends StatelessWidget {
  final String text;

  const AuthDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final c = AuthColors.of(context);
    return Row(
      children: [
        Expanded(child: Divider(color: c.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            text,
            style: TextStyle(color: c.muted, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(child: Divider(color: c.border)),
      ],
    );
  }
}

class Glow extends StatelessWidget {
  final double size;
  final Color color;

  const Glow({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
        ),
      ),
    );
  }
}
