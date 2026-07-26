import 'dart:async';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../models/login_model.dart';
import '../widgets/auth/auth_ui_kit.dart';

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
    final c = AuthColors.of(context);
    final tt = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final keyboardOpen = bottomInset > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: c.background,
      body: AuthBackground(
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
                              AuthHeroCard(
                                title: 'Ladna',
                                subtitle: l.loginTitle,
                                trailing: Icons.login_rounded,
                              ),
                              const SizedBox(height: 14),
                              AuthPanel(
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
                                      AuthTextField(
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
                                      AuthTextField(
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
                                      PrimaryAuthButton(
                                        busy: isLoading,
                                        icon: Icons.arrow_forward_rounded,
                                        label: l.loginBtnSignIn,
                                        onPressed: _login,
                                      ),
                                      const SizedBox(height: 16),
                                      AuthDivider(text: l.loginOr),
                                      const SizedBox(height: 14),
                                      SecondaryAuthButton(
                                        onPressed: isLoading ? null : _loginWithGoogle,
                                        icon: Icons.g_mobiledata_rounded,
                                        label: l.loginContinueGoogle,
                                      ),
                                      if (_showAppleButton) ...[
                                        const SizedBox(height: 10),
                                        SecondaryAuthButton(
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
