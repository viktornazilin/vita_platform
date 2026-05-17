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
import '../widgets/nest/nest_pill.dart';


enum _LegalDoc { terms, privacy, datenschutz, impressum }

const Map<_LegalDoc, String> _legalDocUrls = {
  _LegalDoc.terms: 'https://nest-landing-lemon.vercel.app/terms',
  _LegalDoc.privacy: 'https://nest-landing-lemon.vercel.app/privacy',
  _LegalDoc.datenschutz: 'https://nest-landing-lemon.vercel.app/datenschutz',
  _LegalDoc.impressum: 'https://nest-landing-lemon.vercel.app/impressum',
};

const Set<_LegalDoc> _requiredLegalDocs = {
  _LegalDoc.terms,
  _LegalDoc.privacy,
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

String _legalDocChipTitle(AppLocalizations l, _LegalDoc doc) {
  final title = _legalDocTitle(l, doc);
  if (_requiredLegalDocs.contains(doc)) return title;
  return l.registerLegalOptionalTitle(title);
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
  final Set<_LegalDoc> _openedLegalDocs = <_LegalDoc>{};

  bool get _requiredLegalDocsOpened =>
      _requiredLegalDocs.every(_openedLegalDocs.contains);

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

    final hasArchetype =
        userService.selectedArchetype != null && userService.selectedArchetype!.isNotEmpty;

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

    if (!_requiredLegalDocsOpened) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.registerErrOpenRequiredLegalDocs),
        ),
      );
      return false;
    }

    if (!model.termsAccepted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.registerErrAcceptTerms)));
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

    if (opened) {
      setState(() {
        _openedLegalDocs.add(doc);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.registerLegalOpenFailed(
              _legalDocTitle(AppLocalizations.of(context)!, doc),
            ),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(model.error!)));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(model.error!)));
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
    if (!_ensureLegalAccepted()) return;

    setState(() => _busy = true);
    final model = context.read<RegisterModel>();
    await model.registerWithApple();

    if (!mounted) return;
    setState(() => _busy = false);

    if (model.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(model.error!)));
    }
  }


  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final model = context.watch<RegisterModel>();
    final isLoading = model.loading || _busy;
    final canSubmitLegal = _requiredLegalDocsOpened && model.termsAccepted;
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
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                      child: Align(
                        alignment:
                            keyboardOpen ? Alignment.topCenter : Alignment.center,
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
                                  Center(
                                    child: NestPill(
                                      leading: const Icon(
                                        Icons.auto_awesome_outlined,
                                      ),
                                      text: 'Nest',
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  const _LogoPlate(),
                                  const SizedBox(height: 18),
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
                                        onPressed: () =>
                                            setState(() => _obscure1 = !_obscure1),
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
                                        onPressed: () =>
                                            setState(() => _obscure2 = !_obscure2),
                                        icon: Icon(
                                          _obscure2
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _LegalRow(
                                    value: model.termsAccepted,
                                    enabled: !isLoading,
                                    requiredDocsOpened: _requiredLegalDocsOpened,
                                    openedDocs: _openedLegalDocs,
                                    onChanged: (v) {
                                      if (!_requiredLegalDocsOpened) return;
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
                                              child:
                                                  CircularProgressIndicator.adaptive(),
                                            ),
                                          )
                                        : FilledButton.icon(
                                            onPressed: canSubmitLegal ? _onRegister : null,
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

class _LegalRow extends StatelessWidget {
  final bool value;
  final bool enabled;
  final bool requiredDocsOpened;
  final Set<_LegalDoc> openedDocs;
  final ValueChanged<bool> onChanged;
  final ValueChanged<_LegalDoc> onOpenDoc;

  const _LegalRow({
    required this.value,
    required this.enabled,
    required this.requiredDocsOpened,
    required this.openedDocs,
    required this.onChanged,
    required this.onOpenDoc,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Widget docLink(_LegalDoc doc) {
      final opened = openedDocs.contains(doc);
      final title = _legalDocChipTitle(l, doc);

      return InkWell(
        onTap: enabled ? () => onOpenDoc(doc) : null,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: opened
                ? const Color(0xFF22C55E).withOpacity(0.10)
                : scheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: opened
                  ? const Color(0xFF22C55E).withOpacity(0.28)
                  : scheme.primary.withOpacity(0.18),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                opened ? Icons.check_circle_rounded : Icons.open_in_new_rounded,
                size: 15,
                color: opened ? const Color(0xFF22C55E) : scheme.primary,
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: tt.labelMedium?.copyWith(
                  color: opened ? const Color(0xFF1E8E4D) : scheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.56),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: _LegalDoc.values.map(docLink).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Checkbox(
                  value: value,
                  onChanged: enabled && requiredDocsOpened
                      ? (v) => onChanged(v ?? false)
                      : null,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity:
                      const VisualDensity(horizontal: -2, vertical: -2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  requiredDocsOpened
                      ? l.registerLegalAcceptedText
                      : l.registerLegalOpenRequiredDocsText,
                  style: tt.bodyMedium?.copyWith(
                    color: requiredDocsOpened
                        ? scheme.onSurface
                        : scheme.onSurfaceVariant,
                    fontWeight: requiredDocsOpened ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
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
        height: 160,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
