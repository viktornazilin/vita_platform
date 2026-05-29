import 'dart:async';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../models/register_model.dart';
import '../services/user_service.dart';


String _registerErrNameMin2(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode.toLowerCase();
  switch (code) {
    case 'en':
      return 'Name must be at least 2 characters.';
    case 'de':
      return 'Der Name muss mindestens 2 Zeichen lang sein.';
    case 'fr':
      return 'Le nom doit contenir au moins 2 caractères.';
    case 'es':
      return 'El nombre debe tener al menos 2 caracteres.';
    case 'tr':
      return 'Ad en az 2 karakter olmalı.';
    case 'ru':
    default:
      return 'Имя должно содержать минимум 2 символа.';
  }
}

enum _LegalDoc { terms, privacy, datenschutz, impressum }

const Map<_LegalDoc, String> _legalDocUrls = {
  _LegalDoc.terms: 'https://nest-landing-lemon.vercel.app/terms',
  _LegalDoc.privacy: 'https://nest-landing-lemon.vercel.app/privacy',
  _LegalDoc.datenschutz: 'https://nest-landing-lemon.vercel.app/datenschutz',
  _LegalDoc.impressum: 'https://nest-landing-lemon.vercel.app/impressum',
};

String _legalDocTitle(AppLocalizations l, _LegalDoc doc) {
  switch (doc) {
    case _LegalDoc.terms:
      return l.registerLegalTermsTitle;
    case _LegalDoc.privacy:
      return l.registerLegalPrivacyTitle;
    case _LegalDoc.datenschutz:
      return l.registerLegalDatenschutzTitle;
    case _LegalDoc.impressum:
      return l.registerLegalImpressumTitle;
  }
}

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

  StreamSubscription<AuthState>? _authSub;
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _busy = false;
  bool _privacyAccepted = false;

  bool get _isApplePlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  void initState() {
    super.initState();
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
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

    final hasArchetype = userService.selectedArchetype != null &&
        userService.selectedArchetype!.isNotEmpty;

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

  String? _validateName(BuildContext context, String? value) {
    final l = AppLocalizations.of(context)!;
    final s = (value ?? '').trim();
    if (s.isEmpty) return l.registerErrNameRequired;
    if (s.length < 2) return _registerErrNameMin2(context);
    return null;
  }

  String? _validateEmail(BuildContext context, String? value) {
    final l = AppLocalizations.of(context)!;
    final s = (value ?? '').trim();
    if (s.isEmpty) return l.registerErrEmailRequired;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s)) {
      return l.registerErrEmailInvalid;
    }
    return null;
  }

  String? _validateStrongPassword(BuildContext context, String? value) {
    final l = AppLocalizations.of(context)!;
    final s = value ?? '';
    if (s.isEmpty) return l.registerErrPassRequired;
    if (s.length < 8) return l.registerErrPassMin8;
    if (!RegExp(r'[a-z]').hasMatch(s)) return l.registerErrPassNeedLower;
    if (!RegExp(r'[A-Z]').hasMatch(s)) return l.registerErrPassNeedUpper;
    if (!RegExp(r'\d').hasMatch(s)) return l.registerErrPassNeedDigit;
    return null;
  }

  String? _validateConfirm(BuildContext context, String? value) {
    final l = AppLocalizations.of(context)!;
    final s = value ?? '';
    if (s.isEmpty) return l.registerErrConfirmRequired;
    if (s != _passCtrl.text) return l.registerErrPasswordsMismatch;
    return null;
  }

  bool _ensureLegalAccepted() {
    final l = AppLocalizations.of(context)!;
    final model = context.read<RegisterModel>();

    if (!_privacyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l.registerLegalPrivacyPrefix} ${l.registerLegalPrivacyTitle}'),
        ),
      );
      return false;
    }

    if (!model.termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.registerErrAcceptTerms)),
      );
      return false;
    }

    return true;
  }

  Future<void> _openLegalDoc(_LegalDoc doc) async {
    if (_busy) return;

    final url = _legalDocUrls[doc];
    if (url == null) return;

    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.platformDefault);

    if (!mounted) return;

    if (!opened) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.registerLegalOpenFailed(_legalDocTitle(l, doc)))),
      );
    }
  }

  Future<void> _onRegister() async {
    if (_busy) return;
    if (!_formKey.currentState!.validate()) return;
    if (!_ensureLegalAccepted()) return;

    final model = context.read<RegisterModel>();

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(model.error!)),
      );
    }
  }

  Future<void> _registerWithGoogle() async {
    if (_busy) return;
    if (!_ensureLegalAccepted()) return;

    setState(() => _busy = true);
    final model = context.read<RegisterModel>();
    await model.registerWithGoogle();

    if (!mounted) return;
    setState(() => _busy = false);

    if (model.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(model.error!)),
      );
    }
  }

  Future<void> _registerWithApple() async {
    final l = AppLocalizations.of(context)!;

    if (!_isApplePlatform) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.registerAppleOnlyIos)),
      );
      return;
    }

    if (_busy) return;
    if (!_ensureLegalAccepted()) return;

    setState(() => _busy = true);
    final model = context.read<RegisterModel>();
    await model.registerWithApple();

    if (!mounted) return;
    setState(() => _busy = false);

    if (model.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(model.error!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final model = context.watch<RegisterModel>();
    final isLoading = model.loading || _busy;
    final canSubmitLegal = _privacyAccepted && model.termsAccepted;
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
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _AuthHeroCard(
                                title: 'Ladna',
                                subtitle: l.registerTitle,
                                trailing: Icons.person_add_alt_1_rounded,
                              ),
                              const SizedBox(height: 14),
                              _AuthPanel(
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        l.registerBtnSignUp,
                                        style: tt.headlineSmall?.copyWith(
                                          color: c.text,
                                          fontWeight: FontWeight.w800,
                                          height: 1.05,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        l.registerNameLabel,
                                        style: tt.bodyMedium?.copyWith(
                                          color: c.muted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      _AuthTextField(
                                        controller: _nameCtrl,
                                        focusNode: _nameFocus,
                                        validator: (v) => _validateName(context, v),
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [AutofillHints.name],
                                        onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                                        labelText: l.registerNameLabel,
                                        prefixIcon: Icons.person_outline_rounded,
                                      ),
                                      const SizedBox(height: 12),
                                      _AuthTextField(
                                        controller: _emailCtrl,
                                        focusNode: _emailFocus,
                                        validator: (v) => _validateEmail(context, v),
                                        keyboardType: TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [AutofillHints.email],
                                        onFieldSubmitted: (_) => _passFocus.requestFocus(),
                                        labelText: l.registerEmailLabel,
                                        prefixIcon: Icons.alternate_email_rounded,
                                      ),
                                      const SizedBox(height: 12),
                                      _AuthTextField(
                                        controller: _passCtrl,
                                        focusNode: _passFocus,
                                        validator: (v) => _validateStrongPassword(context, v),
                                        obscureText: _obscure1,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [AutofillHints.newPassword],
                                        onFieldSubmitted: (_) => _pass2Focus.requestFocus(),
                                        labelText: l.registerPasswordLabel,
                                        prefixIcon: Icons.lock_outline_rounded,
                                        suffixIcon: IconButton(
                                          onPressed: () => setState(() => _obscure1 = !_obscure1),
                                          icon: Icon(
                                            _obscure1
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: c.muted,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _AuthTextField(
                                        controller: _pass2Ctrl,
                                        focusNode: _pass2Focus,
                                        validator: (v) => _validateConfirm(context, v),
                                        obscureText: _obscure2,
                                        textInputAction: TextInputAction.done,
                                        autofillHints: const [AutofillHints.newPassword],
                                        onFieldSubmitted: (_) => _onRegister(),
                                        labelText: l.registerConfirmPasswordLabel,
                                        prefixIcon: Icons.verified_user_outlined,
                                        suffixIcon: IconButton(
                                          onPressed: () => setState(() => _obscure2 = !_obscure2),
                                          icon: Icon(
                                            _obscure2
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: c.muted,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      _LegalConsentSection(
                                        privacyAccepted: _privacyAccepted,
                                        termsAccepted: model.termsAccepted,
                                        enabled: !isLoading,
                                        onPrivacyChanged: (v) {
                                          setState(() => _privacyAccepted = v);
                                        },
                                        onTermsChanged: (v) {
                                          model.termsAccepted = v;
                                          model.notifyListeners();
                                        },
                                        onOpenDoc: _openLegalDoc,
                                      ),
                                      if (model.error != null) ...[
                                        const SizedBox(height: 10),
                                        Text(
                                          model.error!,
                                          style: tt.bodySmall?.copyWith(
                                            color: c.error,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 16),
                                      _PrimaryAuthButton(
                                        busy: isLoading,
                                        icon: Icons.arrow_forward_rounded,
                                        label: l.registerBtnSignUp,
                                        onPressed: canSubmitLegal ? _onRegister : null,
                                      ),
                                      const SizedBox(height: 16),
                                      _AuthDivider(text: l.commonOr),
                                      const SizedBox(height: 14),
                                      _SecondaryAuthButton(
                                        onPressed: isLoading || !canSubmitLegal
                                            ? null
                                            : _registerWithGoogle,
                                        icon: Icons.g_mobiledata_rounded,
                                        label: l.registerContinueGoogle,
                                      ),
                                      const SizedBox(height: 10),
                                      _SecondaryAuthButton(
                                        onPressed: isLoading || !canSubmitLegal
                                            ? null
                                            : _registerWithApple,
                                        icon: Icons.apple,
                                        label: _isApplePlatform
                                            ? l.registerContinueApple
                                            : l.registerContinueAppleIos,
                                      ),
                                      const SizedBox(height: 10),
                                      TextButton(
                                        onPressed: isLoading
                                            ? null
                                            : () => Navigator.pushReplacementNamed(context, '/login'),
                                        child: Text(l.registerHaveAccountCta),
                                      ),
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

class _LegalConsentSection extends StatelessWidget {
  final bool privacyAccepted;
  final bool termsAccepted;
  final bool enabled;
  final ValueChanged<bool> onPrivacyChanged;
  final ValueChanged<bool> onTermsChanged;
  final ValueChanged<_LegalDoc> onOpenDoc;

  const _LegalConsentSection({
    required this.privacyAccepted,
    required this.termsAccepted,
    required this.enabled,
    required this.onPrivacyChanged,
    required this.onTermsChanged,
    required this.onOpenDoc,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = _AuthColors.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.input,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LegalConsentLine(
            value: privacyAccepted,
            enabled: enabled,
            prefixText: l.registerLegalPrivacyPrefix,
            linkText: l.registerLegalPrivacyTitle,
            onChanged: onPrivacyChanged,
            onTapLink: () => onOpenDoc(_LegalDoc.privacy),
          ),
          const SizedBox(height: 12),
          _LegalConsentLine(
            value: termsAccepted,
            enabled: enabled,
            prefixText: l.registerLegalTermsPrefix,
            linkText: l.registerLegalTermsTitle,
            onChanged: onTermsChanged,
            onTapLink: () => onOpenDoc(_LegalDoc.terms),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l.registerLegalOptionalLinksPrefix,
                  style: TextStyle(
                    color: c.muted,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                _LegalInlineLink(
                  text: l.registerLegalDatenschutzTitle,
                  enabled: enabled,
                  onTap: () => onOpenDoc(_LegalDoc.datenschutz),
                ),
                Text(
                  '·',
                  style: TextStyle(
                    color: c.muted.withOpacity(0.75),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                _LegalInlineLink(
                  text: l.registerLegalImpressumTitle,
                  enabled: enabled,
                  onTap: () => onOpenDoc(_LegalDoc.impressum),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalConsentLine extends StatelessWidget {
  final bool value;
  final bool enabled;
  final String prefixText;
  final String linkText;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTapLink;

  const _LegalConsentLine({
    required this.value,
    required this.enabled,
    required this.prefixText,
    required this.linkText,
    required this.onChanged,
    required this.onTapLink,
  });

  @override
  Widget build(BuildContext context) {
    final c = _AuthColors.of(context);
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 26,
          height: 26,
          child: Checkbox(
            value: value,
            onChanged: enabled ? (v) => onChanged(v ?? false) : null,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            activeColor: c.primary,
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
            side: BorderSide(color: c.border, width: 1.6),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1.5),
            child: RichText(
              text: TextSpan(
                style: tt.bodyMedium?.copyWith(
                  color: c.muted,
                  height: 1.28,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(text: '$prefixText '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: _LegalInlineLink(
                      text: linkText,
                      enabled: enabled,
                      onTap: onTapLink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LegalInlineLink extends StatelessWidget {
  final String text;
  final bool enabled;
  final VoidCallback onTap;

  const _LegalInlineLink({
    required this.text,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = _AuthColors.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Text(
        text,
        style: TextStyle(
          color: enabled ? c.primary : c.muted.withOpacity(0.55),
          height: 1.28,
          fontWeight: FontWeight.w800,
          decoration: TextDecoration.underline,
          decorationColor: enabled ? c.primary : c.muted.withOpacity(0.55),
          decorationThickness: 1.15,
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
      border: isDark ? const Color(0x2E6B54C0) : const Color(0x1A6B54C0),
      text: isDark ? const Color(0xFFF0EEFF) : const Color(0xFF160E38),
      muted: isDark ? const Color(0x66FFFFFF) : const Color(0xFF9090A8),
      primary: const Color(0xFF6B54C0),
      accent: const Color(0xFFD4E040),
      error: const Color(0xFFEF6A6A),
    );
  }
}
