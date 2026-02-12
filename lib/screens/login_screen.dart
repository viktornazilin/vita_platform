// lib/screens/login_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

import 'package:nest_app/l10n/app_localizations.dart';

import '../models/login_model.dart';

/// ─── Палитра Nest ─────────────────────────────────────────────────────────────
const _kOffWhite = Color(0xFFFAF8F5); // мягкий фон
const _kCloud = Color(0xFFEFF6FB); // лёгкий облачный слой
const _kSky = Color(0xFF3FA7D6); // основной акцент (как в логотипе)
const _kSkyDeep = Color(0xFF2C7FB2); // тёмный акцент
const _kInk = Color(0xFF163043); // основной текст
const _kInkSoft = Color(0x99163043); // подписи/вторичный
// ──────────────────────────────────────────────────────────────────────────────

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
  bool _obscure = true;

  StreamSubscription<AuthState>? _authSub;
  bool _busy = false; // локальная блокировка для reset/login/oauth

  bool get _showAppleButton {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  void initState() {
    super.initState();

    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) async {
      if (!mounted) return;

      if (data.event == AuthChangeEvent.passwordRecovery) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/password-reset', (_) => false);
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

  // ───────────── Helpers ─────────────

  String? _validateEmail(BuildContext context, String? v) {
    final l = AppLocalizations.of(context)!;
    final s = (v ?? '').trim();
    if (s.isEmpty) return l.loginErrEmailRequired;
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
    if (!ok) return l.loginErrEmailInvalid;
    return null;
  }

  String? _validatePass(BuildContext context, String? v) {
    final l = AppLocalizations.of(context)!;
    final s = v ?? '';
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

    // ✅ ВАЖНО: навигацию НЕ делаем здесь.
    // Переход в /home выполнит onAuthStateChange (signedIn),
    // иначе (ошибка) покажем snackbar.
    if (!ok && model.errorText != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(model.errorText!)));
    }
  }

  Future<void> _loginWithGoogle() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await context.read<LoginModel>().loginWithGoogle();
      // ✅ навигация — через onAuthStateChange
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Apple ID (на этом экране это и логин, и регистрация — один OAuth поток)
  /// Важно: в LoginModel должен быть метод loginWithApple().
  Future<void> _loginWithApple() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await context.read<LoginModel>().loginWithApple();
      // ✅ навигация — через onAuthStateChange
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
            decoration: InputDecoration(
              labelText: l.loginEmailLabel,
              border: const OutlineInputBorder(),
            ),
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

    final String redirectTo = kIsWeb
        ? '${Uri.base.origin}/#/password-reset'
        : 'vitaplatform://auth-callback';

    try {
      await client.auth.resetPasswordForEmail(email, redirectTo: redirectTo);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.loginResetSent)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.loginResetFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ───────────── UI ─────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final model = context.watch<LoginModel>();
    final isLoading = model.isLoading || _busy;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: _kOffWhite,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_kOffWhite, _kCloud],
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Center(
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                  bottom: bottomInset > 0 ? bottomInset + 12 : 20,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.80),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _kSky.withOpacity(0.18)),
                        boxShadow: [
                          BoxShadow(
                            color: _kSkyDeep.withOpacity(0.08),
                            blurRadius: 26,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 28,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const _LogoPlate(
                                assetPath: 'assets/images/logo.png',
                                height: 196,
                                borderRadius: 26,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 18,
                                ),
                              ),
                              const SizedBox(height: 22),

                              Text(
                                l.loginTitle,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: _kInk,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 22),

                              // Email
                              TextFormField(
                                controller: _emailCtrl,
                                focusNode: _emailFocus,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                textInputAction: TextInputAction.next,
                                validator: (v) => _validateEmail(context, v),
                                decoration: InputDecoration(
                                  labelText: l.loginEmailLabel,
                                  prefixIcon: const Icon(Icons.alternate_email),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: _kSky.withOpacity(0.24),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: _kSkyDeep,
                                      width: 1.4,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onFieldSubmitted: (_) =>
                                    _passFocus.requestFocus(),
                              ),
                              const SizedBox(height: 12),

                              // Пароль
                              TextFormField(
                                controller: _passCtrl,
                                focusNode: _passFocus,
                                obscureText: _obscure,
                                textInputAction: TextInputAction.done,
                                validator: (v) => _validatePass(context, v),
                                onFieldSubmitted: (_) => _login(),
                                decoration: InputDecoration(
                                  labelText: l.loginPasswordLabel,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    tooltip: _obscure
                                        ? l.loginShowPassword
                                        : l.loginHidePassword,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: _kSky.withOpacity(0.24),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: _kSkyDeep,
                                      width: 1.4,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),

                              if (model.errorText != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  model.errorText!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],

                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : _startPasswordReset,
                                    child: Text(l.loginForgotPassword),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : () => Navigator.pushNamed(
                                            context,
                                            '/register',
                                          ),
                                    child: Text(l.loginCreateAccount),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Email/Password login
                              SizedBox(
                                width: double.infinity,
                                child: isLoading
                                    ? const Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          child:
                                              CircularProgressIndicator.adaptive(),
                                        ),
                                      )
                                    : FilledButton.icon(
                                        onPressed: _login,
                                        icon: const Icon(Icons.login),
                                        label: Text(l.loginBtnSignIn),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: _kSky,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          shadowColor: _kSky.withOpacity(0.25),
                                          elevation: 2,
                                        ),
                                      ),
                              ),

                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      l.loginOr,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(color: _kInkSoft),
                                    ),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Google login
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: isLoading
                                      ? null
                                      : _loginWithGoogle,
                                  icon: const Icon(Icons.g_mobiledata),
                                  label: Text(l.loginContinueGoogle),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: _kSkyDeep.withOpacity(0.35),
                                    ),
                                    foregroundColor: _kSkyDeep,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),

                              if (_showAppleButton) ...[
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: isLoading
                                        ? null
                                        : _loginWithApple,
                                    icon: const Icon(Icons.apple),
                                    label: Text(l.loginContinueApple),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: _kSkyDeep.withOpacity(0.35),
                                      ),
                                      foregroundColor: _kSkyDeep,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Плашка для логотипа с тем же градиентом, что и фон,
/// чтобы ассет не выбивался даже с белой подложкой.
class _LogoPlate extends StatelessWidget {
  final String assetPath;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const _LogoPlate({
    required this.assetPath,
    required this.height,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kOffWhite, _kCloud],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: _kSky.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: _kSkyDeep.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 6),
        child: Image.asset(
          assetPath,
          height: height,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
