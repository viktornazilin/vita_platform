import 'dart:async';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../models/login_model.dart';
import '../widgets/nest/nest_background.dart';
import '../widgets/nest/nest_blur_card.dart';
import '../widgets/nest/nest_pill.dart';

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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final model = context.watch<LoginModel>();
    final isLoading = model.isLoading || _busy;
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      body: NestBackground(
        useSoftGradient: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                bottomInset > 0 ? bottomInset + 12 : 20,
              ),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: NestBlurCard(
                    radius: 28,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: NestPill(
                              leading: const Icon(Icons.wb_sunny_outlined),
                              text: 'Nest',
                            ),
                          ),
                          const SizedBox(height: 18),
                          const _LogoPlate(),
                          const SizedBox(height: 18),
                          Center(
                            child: Text(
                              l.loginTitle,
                              textAlign: TextAlign.center,
                              style: tt.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
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
                            ),
                            onFieldSubmitted: (_) => _passFocus.requestFocus(),
                          ),
                          const SizedBox(height: 12),
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
                                onPressed: () => setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                tooltip: _obscure
                                    ? l.loginShowPassword
                                    : l.loginHidePassword,
                              ),
                            ),
                          ),
                          if (model.errorText != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              model.errorText!,
                              style: tt.bodySmall?.copyWith(
                                color: scheme.error,
                                fontWeight: FontWeight.w600,
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
                          SizedBox(
                            width: double.infinity,
                            child: isLoading
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Center(
                                      child: CircularProgressIndicator.adaptive(),
                                    ),
                                  )
                                : FilledButton.icon(
                                    onPressed: _login,
                                    icon: const Icon(Icons.login_rounded),
                                    label: Text(l.loginBtnSignIn),
                                  ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(child: Divider(color: scheme.outlineVariant)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  l.loginOr,
                                  style: tt.labelMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: scheme.outlineVariant)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          OutlinedButton.icon(
                            onPressed: isLoading ? null : _loginWithGoogle,
                            icon: const Icon(Icons.g_mobiledata_rounded),
                            label: Text(l.loginContinueGoogle),
                          ),
                          if (_showAppleButton) ...[
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: isLoading ? null : _loginWithApple,
                              icon: const Icon(Icons.apple),
                              label: Text(l.loginContinueApple),
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
    );
  }
}

class _LogoPlate extends StatelessWidget {
  const _LogoPlate();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceContainer : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Image.asset(
        'assets/images/logo.png',
        height: 172,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
