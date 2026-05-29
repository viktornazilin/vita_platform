import 'dart:async';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../models/login_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginModel(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  StreamSubscription<AuthState>? _authSub;
  bool _obscure = true;
  bool _busy = false;

  bool get _showAppleButton {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  void initState() {
    super.initState();

    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;

      if (data.event == AuthChangeEvent.passwordRecovery) {
        Navigator.of(context).pushNamedAndRemoveUntil('/password-reset', (_) => false);
        return;
      }

      if (data.event == AuthChangeEvent.signedIn && data.session != null) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  String? _validateEmail(BuildContext context, String? value) {
    final l = AppLocalizations.of(context)!;
    final s = (value ?? '').trim();
    if (s.isEmpty) return l.loginErrEmailRequired;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s)) {
      return l.loginErrEmailInvalid;
    }
    return null;
  }

  String? _validatePass(BuildContext context, String? value) {
    final l = AppLocalizations.of(context)!;
    final s = value ?? '';
    if (s.isEmpty) return l.loginErrPassRequired;
    if (s.length < 6) return l.loginErrPassMin6;
    return null;
  }

  Future<void> _login() async {
    if (_busy) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);
    final model = context.read<LoginModel>();
    final ok = await model.login(_emailCtrl.text.trim(), _passCtrl.text);

    if (!mounted) return;
    setState(() => _busy = false);

    if (!ok && model.errorText != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(model.errorText!)),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await context.read<LoginModel>().loginWithGoogle();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _loginWithApple() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await context.read<LoginModel>().loginWithApple();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startPasswordReset() async {
    if (_busy) return;
    final l = AppLocalizations.of(context)!;

    final emailController = TextEditingController(text: _emailCtrl.text.trim());
    final formKey = GlobalKey<FormState>();

    final email = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.loginResetTitle),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            validator: (v) => _validateEmail(context, v),
            decoration: InputDecoration(labelText: l.loginEmailLabel),
            onFieldSubmitted: (_) {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, emailController.text.trim());
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, emailController.text.trim());
              }
            },
            child: Text(l.loginResetSend),
          ),
        ],
      ),
    );

    if (email == null || email.isEmpty) return;

    setState(() => _busy = true);
    final client = Supabase.instance.client;
    final redirectTo =
        kIsWeb ? '${Uri.base.origin}/#/password-reset' : 'vitaplatform://auth-callback';

    try {
      await client.auth.resetPasswordForEmail(email, redirectTo: redirectTo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.loginResetSent)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.loginResetFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final model = context.watch<LoginModel>();
    final isLoading = model.isLoading || _busy;
    final c = _AuthColors.of(context);
    final tt = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final keyboardOpen = bottomInset > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: c.background,
      body: _AuthBackground(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedPadding(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.fromLTRB(18, 14, 18, keyboardOpen ? 14 : 22),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - 36),
                      child: Align(
                        alignment: keyboardOpen ? Alignment.topCenter : Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _AuthHeroCard(
                                title: 'Ladna',
                                subtitle: l.loginTitle,
                                trailing: Icons.login_rounded,
                              ),
                              const SizedBox(height: 14),
                              _AuthPanel(
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        l.loginBtnSignIn,
                                        style: tt.headlineSmall?.copyWith(
                                          color: c.text,
                                          fontWeight: FontWeight.w800,
                                          height: 1.05,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        l.loginEmailLabel,
                                        style: tt.bodyMedium?.copyWith(
                                          color: c.muted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      _AuthTextField(
                                        controller: _emailCtrl,
                                        focusNode: _emailFocus,
                                        keyboardType: TextInputType.emailAddress,
                                        autofillHints: const [AutofillHints.email],
                                        textInputAction: TextInputAction.next,
                                        validator: (v) => _validateEmail(context, v),
                                        labelText: l.loginEmailLabel,
                                        prefixIcon: Icons.alternate_email_rounded,
                                        onFieldSubmitted: (_) => _passFocus.requestFocus(),
                                      ),
                                      const SizedBox(height: 12),
                                      _AuthTextField(
                                        controller: _passCtrl,
                                        focusNode: _passFocus,
                                        obscureText: _obscure,
                                        textInputAction: TextInputAction.done,
                                        validator: (v) => _validatePass(context, v),
                                        labelText: l.loginPasswordLabel,
                                        prefixIcon: Icons.lock_outline_rounded,
                                        onFieldSubmitted: (_) => _login(),
                                        suffixIcon: IconButton(
                                          onPressed: () => setState(() => _obscure = !_obscure),
                                          icon: Icon(
                                            _obscure
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: c.muted,
                                          ),
                                          tooltip: _obscure
                                              ? l.loginShowPassword
                                              : l.loginHidePassword,
                                        ),
                                      ),
                                      if (model.errorText != null) ...[
                                        const SizedBox(height: 10),
                                        Text(
                                          model.errorText!,
                                          style: tt.bodySmall?.copyWith(
                                            color: c.error,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          TextButton(
                                            onPressed: isLoading ? null : _startPasswordReset,
                                            child: Text(l.loginForgotPassword),
                                          ),
                                          const Spacer(),
                                          TextButton(
                                            onPressed: isLoading
                                                ? null
                                                : () => Navigator.pushNamed(context, '/register'),
                                            child: Text(l.loginCreateAccount),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      _PrimaryAuthButton(
                                        busy: isLoading,
                                        icon: Icons.arrow_forward_rounded,
                                        label: l.loginBtnSignIn,
                                        onPressed: _login,
                                      ),
                                      const SizedBox(height: 16),
                                      _AuthDivider(text: l.loginOr),
                                      const SizedBox(height: 14),
                                      _SecondaryAuthButton(
                                        onPressed: isLoading ? null : _loginWithGoogle,
                                        icon: Icons.g_mobiledata_rounded,
                                        label: l.loginContinueGoogle,
                                      ),
                                      if (_showAppleButton) ...[
                                        const SizedBox(height: 10),
                                        _SecondaryAuthButton(
                                          onPressed: isLoading ? null : _loginWithApple,
                                          icon: Icons.apple,
                                          label: l.loginContinueApple,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthBackground extends StatelessWidget {
  final Widget child;

  const _AuthBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    final c = _AuthColors.of(context);
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
            child: _Glow(size: 240, color: c.primary.withOpacity(c.isDark ? 0.20 : 0.12)),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: _Glow(size: 260, color: c.accent.withOpacity(c.isDark ? 0.12 : 0.18)),
          ),
          child,
        ],
      ),
    );
  }
}

class _AuthHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData trailing;

  const _AuthHeroCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final c = _AuthColors.of(context);
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
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

class _AuthPanel extends StatelessWidget {
  final Widget child;

  const _AuthPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    final c = _AuthColors.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(26),
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

class _AuthTextField extends StatelessWidget {
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

  const _AuthTextField({
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
    final c = _AuthColors.of(context);
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
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: c.primary, width: 1.4),
        ),
      ),
    );
  }
}

class _PrimaryAuthButton extends StatelessWidget {
  final bool busy;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _PrimaryAuthButton({
    required this.busy,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final c = _AuthColors.of(context);
    if (busy) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(c.primary),
          ),
        ),
      );
    }
    return SizedBox(
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
    );
  }
}

class _SecondaryAuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

  const _SecondaryAuthButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final c = _AuthColors.of(context);
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: c.text,
          side: BorderSide(color: c.border, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
          backgroundColor: c.input,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _AuthDivider extends StatelessWidget {
  final String text;

  const _AuthDivider({required this.text});

  @override
  Widget build(BuildContext context) {
    final c = _AuthColors.of(context);
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

class _Glow extends StatelessWidget {
  final double size;
  final Color color;

  const _Glow({required this.size, required this.color});

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

class _AuthColors {
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

  const _AuthColors({
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

  static _AuthColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _AuthColors(
      isDark: isDark,
      background: isDark ? const Color(0xFF100C1E) : const Color(0xFFF5F3FA),
      card: isDark ? const Color(0xFF1C1630) : const Color(0xFFFAFAFE),
      input: isDark ? const Color(0x0DFFFFFF) : const Color(0xFFFFFFFF),
      border: isDark
          ? const Color(0x2E6B54C0)
          : const Color(0x1A6B54C0),
      text: isDark ? const Color(0xFFF0EEFF) : const Color(0xFF160E38),
      muted: isDark ? const Color(0x66FFFFFF) : const Color(0xFF9090A8),
      primary: const Color(0xFF6B54C0),
      accent: const Color(0xFFD4E040),
      error: const Color(0xFFEF6A6A),
    );
  }
}
