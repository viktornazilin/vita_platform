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
import '../widgets/nest/nest_background.dart';
import '../widgets/nest/nest_blur_card.dart';

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
          content: Text(
            '${l.registerLegalPrivacyPrefix} ${l.registerLegalPrivacyTitle}',
          ),
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
        SnackBar(
          content: Text(
            l.registerLegalOpenFailed(_legalDocTitle(l, doc)),
          ),
        ),
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
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: NestBackground(
        useSoftGradient: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final keyboardOpen = bottomInset > 0;

                return AnimatedPadding(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    keyboardOpen ? 12 : 20,
                  ),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 32,
                      ),
                      child: Align(
                        alignment: keyboardOpen
                            ? Alignment.topCenter
                            : Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: NestBlurCard(
                            radius: 28,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 24,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const _LogoPlate(),
                                  const SizedBox(height: 20),
                                  Text(
                                    l.registerTitle,
                                    textAlign: TextAlign.center,
                                    style: tt.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  TextFormField(
                                    controller: _nameCtrl,
                                    focusNode: _nameFocus,
                                    validator: (v) => _validateName(context, v),
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.name],
                                    onFieldSubmitted: (_) =>
                                        _emailFocus.requestFocus(),
                                    decoration: InputDecoration(
                                      labelText: l.registerNameLabel,
                                      prefixIcon: const Icon(
                                        Icons.person_outline_rounded,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _emailCtrl,
                                    focusNode: _emailFocus,
                                    validator: (v) => _validateEmail(context, v),
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.email],
                                    onFieldSubmitted: (_) =>
                                        _passFocus.requestFocus(),
                                    decoration: InputDecoration(
                                      labelText: l.registerEmailLabel,
                                      prefixIcon: const Icon(
                                        Icons.alternate_email_rounded,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _passCtrl,
                                    focusNode: _passFocus,
                                    validator: (v) =>
                                        _validateStrongPassword(context, v),
                                    obscureText: _obscure1,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [
                                      AutofillHints.newPassword,
                                    ],
                                    onFieldSubmitted: (_) =>
                                        _pass2Focus.requestFocus(),
                                    decoration: InputDecoration(
                                      labelText: l.registerPasswordLabel,
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(
                                          () => _obscure1 = !_obscure1,
                                        ),
                                        icon: Icon(
                                          _obscure1
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _pass2Ctrl,
                                    focusNode: _pass2Focus,
                                    validator: (v) => _validateConfirm(context, v),
                                    obscureText: _obscure2,
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [
                                      AutofillHints.newPassword,
                                    ],
                                    onFieldSubmitted: (_) => _onRegister(),
                                    decoration: InputDecoration(
                                      labelText: l.registerConfirmPasswordLabel,
                                      prefixIcon: const Icon(
                                        Icons.verified_user_outlined,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(
                                          () => _obscure2 = !_obscure2,
                                        ),
                                        icon: Icon(
                                          _obscure2
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
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
                                        color: scheme.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: isLoading
                                        ? const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            child: Center(
                                              child: CircularProgressIndicator.adaptive(),
                                            ),
                                          )
                                        : FilledButton.icon(
                                            onPressed:
                                                canSubmitLegal ? _onRegister : null,
                                            icon: const Icon(
                                              Icons.person_add_alt_1_rounded,
                                            ),
                                            label: Text(l.registerBtnSignUp),
                                          ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(color: scheme.outlineVariant),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: Text(
                                          l.commonOr,
                                          style: tt.labelMedium?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(color: scheme.outlineVariant),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  OutlinedButton.icon(
                                    onPressed: isLoading || !canSubmitLegal
                                        ? null
                                        : _registerWithGoogle,
                                    icon: const Icon(Icons.g_mobiledata_rounded),
                                    label: Text(l.registerContinueGoogle),
                                  ),
                                  const SizedBox(height: 10),
                                  OutlinedButton.icon(
                                    onPressed: isLoading || !canSubmitLegal
                                        ? null
                                        : _registerWithApple,
                                    icon: const Icon(Icons.apple),
                                    label: Text(
                                      _isApplePlatform
                                          ? l.registerContinueApple
                                          : l.registerContinueAppleIos,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
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
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
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
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l.registerLegalOptionalLinksPrefix,
                style: tt.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _LegalInlineLink(
                text: l.registerLegalDatenschutzTitle,
                enabled: enabled,
                onTap: () => onOpenDoc(_LegalDoc.datenschutz),
              ),
              Text(
                '·',
                style: tt.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant.withOpacity(0.7),
                  fontWeight: FontWeight.w700,
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
    final scheme = Theme.of(context).colorScheme;
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            side: BorderSide(
              color: scheme.outlineVariant,
              width: 1.6,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1.5),
            child: RichText(
              text: TextSpan(
                style: tt.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.28,
                  fontWeight: FontWeight.w500,
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
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Text(
        text,
        style: tt.bodyMedium?.copyWith(
          color: enabled ? scheme.primary : scheme.onSurfaceVariant.withOpacity(0.55),
          height: 1.28,
          fontWeight: FontWeight.w800,
          decoration: TextDecoration.underline,
          decorationColor:
              enabled ? scheme.primary : scheme.onSurfaceVariant.withOpacity(0.55),
          decorationThickness: 1.15,
        ),
      ),
    );
  }
}

class _LogoPlate extends StatelessWidget {
  const _LogoPlate();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/logo.png',
        height: 112,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
