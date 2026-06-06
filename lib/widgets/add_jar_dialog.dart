// lib/widgets/add_jar_dialog.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nest_app/l10n/app_localizations.dart';

class NewJarData {
  final String title;
  final double? target;
  final double percent;
  const NewJarData(this.title, this.target, this.percent);
}

class AddJarDialog extends StatefulWidget {
  final String? initialTitle;
  final double? initialTarget;
  final double? initialPercent;

  const AddJarDialog({
    super.key,
    this.initialTitle,
    this.initialTarget,
    this.initialPercent,
  });

  @override
  State<AddJarDialog> createState() => _AddJarDialogState();
}

class _AddJarDialogState extends State<AddJarDialog> {
  late final TextEditingController _title;
  late final TextEditingController _target;
  late final TextEditingController _percent;

  String? _error;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initialTitle ?? '');
    _target = TextEditingController(
      text: widget.initialTarget != null ? widget.initialTarget!.toString() : '',
    );
    _percent = TextEditingController(
      text: (widget.initialPercent ?? 0).toString(),
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _target.dispose();
    _percent.dispose();
    super.dispose();
  }

  double? _parseDouble(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t.replaceAll(',', '.'));
  }

  void _setErr(String msg) => setState(() => _error = msg);

  void _clearErr() {
    if (_error != null) setState(() => _error = null);
  }

  void _submit() {
    final l = AppLocalizations.of(context)!;

    final title = _title.text.trim();
    if (title.isEmpty) {
      _setErr(l.addJarNameRequired);
      return;
    }

    final percent = _parseDouble(_percent.text) ?? 0;
    if (percent < 0 || percent > 100) {
      _setErr(l.addJarPercentRange);
      return;
    }

    final target = _parseDouble(_target.text);
    if (target == null || target <= 0) {
      _setErr(l.addJarTargetRequired);
      return;
    }

    Navigator.pop(context, NewJarData(title, target, percent));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final media = MediaQuery.of(context);

    final isEdit =
        widget.initialTitle != null ||
        widget.initialTarget != null ||
        widget.initialPercent != null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: media.size.height * 0.84,
        ),
        child: _LadnaDialogShell(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              18,
              16,
              18,
              18 + media.viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DialogHeader(
                  icon: Icons.savings_rounded,
                  title: isEdit ? l.addJarEditTitle : l.addJarNewTitle,
                  subtitle: l.addJarSubtitle,
                  onClose: () => Navigator.pop(context),
                  closeTooltip: l.commonCloseTooltip,
                ),
                const SizedBox(height: 18),
                _LadnaTextField(
                  controller: _title,
                  label: l.addJarNameLabel,
                  hint: l.addJarNameHint,
                  icon: Icons.title_rounded,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => _clearErr(),
                ),
                const SizedBox(height: 10),
                _LadnaTextField(
                  controller: _percent,
                  label: l.addJarPercentLabel,
                  hint: l.addJarPercentHint,
                  icon: Icons.percent_rounded,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => _clearErr(),
                ),
                const SizedBox(height: 10),
                _LadnaTextField(
                  controller: _target,
                  label: l.addJarTargetLabel,
                  hint: l.addJarTargetHint,
                  helperText: l.addJarTargetHelper,
                  icon: Icons.account_balance_wallet_rounded,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  onChanged: (_) => _clearErr(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  _ErrorPill(text: _error!),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        label: Text(l.commonCancel),
                        style: _secondaryButtonStyle(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _submit,
                        icon: Icon(isEdit ? Icons.save_rounded : Icons.add_rounded),
                        label: Text(isEdit ? l.commonSave : l.commonCreate),
                        style: _primaryButtonStyle(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LadnaColors {
  static bool get _dark =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;

  static Color get surface => _dark ? const Color(0xF21D1732) : const Color(0xF8F4F0FF);
  static Color get field => _dark ? const Color(0xFF211A38) : const Color(0xFFEDE7FF);
  static Color get border => _dark ? const Color(0x666B54C0) : const Color(0xFFDAD2F1);
  static Color get borderSoft => _dark ? const Color(0x446B54C0) : const Color(0xFFE7DFFC);
  static Color get text => _dark ? const Color(0xFFF4F0FF) : const Color(0xFF160E38);
  static Color get muted => _dark ? const Color(0xB8D7CEF5) : const Color(0xFF7F7A9E);
  static const Color primary = Color(0xFF6B54C0);
  static const Color lime = Color(0xFFD4E040);
  static const Color danger = Color(0xFFFF8A98);

  static List<BoxShadow> get shadow => [
        BoxShadow(
          color: Colors.black.withOpacity(_dark ? 0.34 : 0.16),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
      ];
}

class _LadnaDialogShell extends StatelessWidget {
  final Widget child;
  const _LadnaDialogShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: _LadnaColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _LadnaColors.border, width: 1.4),
            boxShadow: _LadnaColors.shadow,
          ),
          child: Stack(
            children: [
              Positioned(
                top: -90,
                right: -100,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _LadnaColors.primary.withOpacity(0.24),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -80,
                bottom: -90,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _LadnaColors.lime.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String closeTooltip;
  final VoidCallback onClose;

  const _DialogHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.closeTooltip,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _LadnaColors.primary.withOpacity(0.24),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: _LadnaColors.border),
          ),
          child: Icon(icon, color: _LadnaColors.lime, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontFamilyFallback: const ['PlayfairDisplay', 'Georgia'],
                  fontSize: 24,
                  height: 1.02,
                  fontWeight: FontWeight.w800,
                  color: _LadnaColors.text,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: _LadnaColors.muted,
                ),
              ),
            ],
          ),
        ),
        Tooltip(
          message: closeTooltip,
          child: _RoundIconButton(icon: Icons.close_rounded, onTap: onClose),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _LadnaColors.field,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _LadnaColors.borderSoft),
          ),
          child: Icon(icon, color: _LadnaColors.muted, size: 21),
        ),
      ),
    );
  }
}

class _LadnaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final IconData? icon;

  const _LadnaTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.helperText,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      cursorColor: _LadnaColors.lime,
      style: TextStyle(
        fontFamily: 'Geologica',
        fontSize: 16,
        height: 1.15,
        fontWeight: FontWeight.w800,
        color: _LadnaColors.text,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        isDense: true,
        prefixIcon: icon == null ? null : Icon(icon, color: _LadnaColors.muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(
          fontFamily: 'Geologica',
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: _LadnaColors.muted,
        ),
        hintStyle: TextStyle(
          color: _LadnaColors.muted.withOpacity(0.65),
          fontWeight: FontWeight.w700,
        ),
        helperStyle: TextStyle(
          color: _LadnaColors.muted.withOpacity(0.75),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: _LadnaColors.field,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: _LadnaColors.borderSoft, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: _LadnaColors.borderSoft, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _LadnaColors.primary, width: 1.6),
        ),
      ),
    );
  }
}

class _ErrorPill extends StatelessWidget {
  final String text;
  const _ErrorPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _LadnaColors.danger.withOpacity(0.13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _LadnaColors.danger.withOpacity(0.34)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: _LadnaColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: _LadnaColors.text,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

ButtonStyle _primaryButtonStyle() {
  return FilledButton.styleFrom(
    backgroundColor: _LadnaColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 14),
    textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  );
}

ButtonStyle _secondaryButtonStyle() {
  return OutlinedButton.styleFrom(
    foregroundColor: _LadnaColors.text,
    padding: const EdgeInsets.symmetric(vertical: 14),
    textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
    side: BorderSide(color: _LadnaColors.border),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  );
}
