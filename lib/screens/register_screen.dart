// lib/screens/register_screen.dart
import 'dart:async';

import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../models/register_model.dart';
import '../services/user_service.dart';

/// ─── Палитра Nest (как в LoginScreen) ─────────────────────────────────────────
const _kOffWhite = Color(0xFFFAF8F5);
const _kCloud = Color(0xFFEFF6FB);
const _kSky = Color(0xFF3FA7D6);
const _kSkyDeep = Color(0xFF2C7FB2);
const _kInk = Color(0xFF163043);
const _kInkSoft = Color(0x99163043);
// ──────────────────────────────────────────────────────────────────────────────

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterModel(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _pass2Focus = FocusNode();

  bool _obscure1 = true;
  bool _obscure2 = true;

  StreamSubscription<AuthState>? _authSub;
  bool _busy = false;

  bool get _isApplePlatform {
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
      if (data.event == AuthChangeEvent.signedIn && data.session != null) {
        await _routeAfterAuth();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _pass2Focus.dispose();
    super.dispose();
  }

  Future<void> _routeAfterAuth() async {
    final userService = UserService();
    await userService.refreshCurrentUser();
    if (!mounted) return;

    if (!userService.hasSeenEpicIntro) {
      Navigator.pushNamedAndRemoveUntil(context, '/intro', (_) => false);
      return;
    }

    final hasArchetype =
        (userService.selectedArchetype != null &&
        userService.selectedArchetype!.isNotEmpty);
    if (!hasArchetype) {
      Navigator.pushNamedAndRemoveUntil(context, '/archetype', (_) => false);
      return;
    }

    if (userService.hasCompletedQuestionnaire) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (_) => false);
    }
  }

  // ───────────── Validators (localized) ─────────────

  String? _validateName(BuildContext context, String? v) {
    final l = AppLocalizations.of(context)!;
    final s = (v ?? '').trim();
    if (s.isEmpty) return l.registerErrNameRequired;
    return null;
  }

  String? _validateEmail(BuildContext context, String? v) {
    final l = AppLocalizations.of(context)!;
    final s = (v ?? '').trim();
    if (s.isEmpty) return l.registerErrEmailRequired;
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
    if (!ok) return l.registerErrEmailInvalid;
    return null;
  }

  /// ✅ Strong password:
  /// - min 8 chars
  /// - 1 lower
  /// - 1 upper
  /// - 1 digit
  String? _validateStrongPassword(BuildContext context, String? v) {
    final l = AppLocalizations.of(context)!;
    final s = v ?? '';
    if (s.isEmpty) return l.registerErrPassRequired;
    if (s.length < 8) return l.registerErrPassMin8;
    if (!RegExp(r'[a-z]').hasMatch(s)) return l.registerErrPassNeedLower;
    if (!RegExp(r'[A-Z]').hasMatch(s)) return l.registerErrPassNeedUpper;
    if (!RegExp(r'\d').hasMatch(s)) return l.registerErrPassNeedDigit;
    return null;
  }

  String? _validateConfirm(BuildContext context, String? v) {
    final l = AppLocalizations.of(context)!;
    final s = v ?? '';
    if (s.isEmpty) return l.registerErrConfirmRequired;
    if (s != _passCtrl.text) return l.registerErrPasswordsMismatch;
    return null;
  }

  // ───────────── Actions ─────────────

  Future<void> _onRegister() async {
    if (_busy) return;
    if (!_formKey.currentState!.validate()) return;

    final l = AppLocalizations.of(context)!;
    final model = context.read<RegisterModel>();

    if (!model.termsAccepted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.registerErrAcceptTerms)));
      return;
    }

    setState(() => _busy = true);

    final ok = await model.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      confirmPassword: _pass2Ctrl.text,
    );

    if (!mounted) return;
    setState(() => _busy = false);

    if (ok) {
      await _routeAfterAuth();
    } else if (model.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(model.error!)));
    }
  }

  Future<void> _registerWithGoogle() async {
    if (_busy) return;
    setState(() => _busy = true);

    final model = context.read<RegisterModel>();
    await model.registerWithGoogle();

    if (!mounted) return;
    setState(() => _busy = false);

    if (model.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(model.error!)));
    }
  }

  Future<void> _registerWithApple() async {
    final l = AppLocalizations.of(context)!;

    if (!_isApplePlatform) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.registerAppleOnlyIos)));
      return;
    }

    if (_busy) return;
    setState(() => _busy = true);

    final model = context.read<RegisterModel>();
    await model.registerWithApple();

    if (!mounted) return;
    setState(() => _busy = false);

    if (model.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(model.error!)));
    }
  }

  void _openTerms() => Navigator.pushNamed(context, '/terms');
  void _openPrivacy() => Navigator.pushNamed(context, '/privacy');

  InputDecoration _dec(BuildContext context, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _kSky.withOpacity(0.24)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _kSkyDeep, width: 1.4),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final model = context.watch<RegisterModel>();
    final isLoading = model.loading || _busy;
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
                                height: 120,
                                borderRadius: 22,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                              ),
                              const SizedBox(height: 18),

                              Text(
                                l.registerTitle,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: _kInk,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 18),

                              TextFormField(
                                controller: _nameCtrl,
                                focusNode: _nameFocus,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.name],
                                decoration: _dec(
                                  context,
                                  l.registerNameLabel,
                                  Icons.person_outline,
                                ),
                                validator: (v) => _validateName(context, v),
                                onFieldSubmitted: (_) =>
                                    _emailFocus.requestFocus(),
                              ),
                              const SizedBox(height: 12),

                              TextFormField(
                                controller: _emailCtrl,
                                focusNode: _emailFocus,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                textInputAction: TextInputAction.next,
                                validator: (v) => _validateEmail(context, v),
                                decoration: _dec(
                                  context,
                                  l.registerEmailLabel,
                                  Icons.alternate_email,
                                ),
                                onFieldSubmitted: (_) =>
                                    _passFocus.requestFocus(),
                              ),
                              const SizedBox(height: 12),

                              TextFormField(
                                controller: _passCtrl,
                                focusNode: _passFocus,
                                obscureText: _obscure1,
                                textInputAction: TextInputAction.next,
                                validator: (v) =>
                                    _validateStrongPassword(context, v),
                                onFieldSubmitted: (_) =>
                                    _pass2Focus.requestFocus(),
                                decoration:
                                    _dec(
                                      context,
                                      l.registerPasswordLabel,
                                      Icons.lock_outline,
                                    ).copyWith(
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(
                                          () => _obscure1 = !_obscure1,
                                        ),
                                        icon: Icon(
                                          _obscure1
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        tooltip: _obscure1
                                            ? l.registerShowPassword
                                            : l.registerHidePassword,
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 12),

                              TextFormField(
                                controller: _pass2Ctrl,
                                focusNode: _pass2Focus,
                                obscureText: _obscure2,
                                textInputAction: TextInputAction.done,
                                validator: (v) => _validateConfirm(context, v),
                                onFieldSubmitted: (_) => _onRegister(),
                                decoration:
                                    _dec(
                                      context,
                                      l.registerConfirmPasswordLabel,
                                      Icons.lock,
                                    ).copyWith(
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(
                                          () => _obscure2 = !_obscure2,
                                        ),
                                        icon: Icon(
                                          _obscure2
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        tooltip: _obscure2
                                            ? l.registerShowPassword
                                            : l.registerHidePassword,
                                      ),
                                    ),
                              ),

                              const SizedBox(height: 14),

                              _LegalRow(
                                value: model.termsAccepted,
                                enabled: !isLoading,
                                onChanged: (v) => model.setTerms(v),
                                onOpenTerms: _openTerms,
                                onOpenPrivacy: _openPrivacy,
                              ),

                              if (model.error != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  model.error!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],

                              const SizedBox(height: 16),

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
                                        onPressed: _onRegister,
                                        icon: const Icon(
                                          Icons.person_add_alt_1_outlined,
                                        ),
                                        label: Text(l.registerBtnSignUp),
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
                                      l.commonOr,
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

                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: isLoading
                                      ? null
                                      : _registerWithGoogle,
                                  icon: const Icon(Icons.g_mobiledata),
                                  label: Text(l.registerContinueGoogle),
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

                              const SizedBox(height: 10),

                              // Apple: видна всегда, но на Web/Android покажет подсказку
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: isLoading
                                      ? null
                                      : _registerWithApple,
                                  icon: const Icon(Icons.apple),
                                  label: Text(
                                    _isApplePlatform
                                        ? l.registerContinueApple
                                        : l.registerContinueAppleIos,
                                  ),
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

                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () => Navigator.pushReplacementNamed(
                                        context,
                                        '/login',
                                      ),
                                child: Text(l.registerHaveAccountCta),
                              ),
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

class _LegalRow extends StatelessWidget {
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;

  const _LegalRow({
    required this.value,
    required this.enabled,
    required this.onChanged,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final textStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: _kInk);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Checkbox(
            value: value,
            onChanged: enabled ? (v) => onChanged(v ?? false) : null,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              children: [
                Text(l.registerLegalPrefix, style: textStyle),
                InkWell(
                  onTap: enabled ? onOpenTerms : null,
                  child: Text(
                    l.registerLegalTerms,
                    style: textStyle?.copyWith(
                      color: _kSkyDeep,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(l.registerLegalMiddle, style: textStyle),
                InkWell(
                  onTap: enabled ? onOpenPrivacy : null,
                  child: Text(
                    l.registerLegalPrivacy,
                    style: textStyle?.copyWith(
                      color: _kSkyDeep,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(l.registerLegalSuffix, style: textStyle),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

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
