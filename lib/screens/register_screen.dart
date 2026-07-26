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
import '../widgets/auth/auth_ui_kit.dart';


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
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AuthHeroCard(
                                title: 'Ladna',
                                subtitle: l.registerTitle,
                                trailing: Icons.person_add_alt_1_rounded,
                              ),
                              const SizedBox(height: 14),
                              AuthPanel(
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
                                      AuthTextField(
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
                                      AuthTextField(
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
                                      AuthTextField(
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
                                      AuthTextField(
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
                                      PrimaryAuthButton(
                                        busy: isLoading,
                                        icon: Icons.arrow_forward_rounded,
                                        label: l.registerBtnSignUp,
                                        onPressed: canSubmitLegal ? _onRegister : null,
                                      ),
                                      const SizedBox(height: 16),
                                      AuthDivider(text: l.commonOr),
                                      const SizedBox(height: 14),
                                      SecondaryAuthButton(
                                        onPressed: isLoading || !canSubmitLegal
                                            ? null
                                            : _registerWithGoogle,
                                        icon: Icons.g_mobiledata_rounded,
                                        label: l.registerContinueGoogle,
                                      ),
                                      const SizedBox(height: 10),
                                      SecondaryAuthButton(
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
    final c = AuthColors.of(context);

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
    final c = AuthColors.of(context);
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
    final c = AuthColors.of(context);
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
