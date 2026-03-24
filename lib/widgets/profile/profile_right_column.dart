// lib/screens/profile/profile_right_column.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../../models/profile_model.dart';
import '../../controllers/locale_controller.dart';

import 'profile_ui_helpers.dart';
import 'habits_card.dart';

import '../../widgets/nest/nest_card.dart';
import '../../widgets/nest/nest_section_title.dart';
import '../../widgets/nest/nest_sheet.dart';

class ProfileRightColumn extends StatelessWidget {
  const ProfileRightColumn({super.key});

  Future<bool> _confirmDeleteAccount(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final res = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NestSheet(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            14,
            16,
            16 + MediaQuery.of(ctx).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SheetHeader(title: l.profileDeleteAccountTitle),
              const SizedBox(height: 10),
              Text(
                l.profileDeleteAccountBody,
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF2E4B5A).withOpacity(0.85),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(l.commonCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.error,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(l.profileDeleteAccountConfirm),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return res == true;
  }

  Future<void> _handleDeleteAccount(BuildContext context, ProfileModel model) async {
    final l = AppLocalizations.of(context)!;

    final ok = await _confirmDeleteAccount(context);
    if (!ok) return;

    final err = await model.deleteAccount();
    if (!context.mounted) return;

    if (err != null) {
      ProfileUi.snack(context, err);
      return;
    }

    Navigator.of(context, rootNavigator: true)
        .pushNamedAndRemoveUntil('/login', (r) => false);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.profileAccountDeletedToast)));
  }

  Future<void> _changeLanguage(
    BuildContext context, {
    required ProfileModel model,
    required LocaleController localeCtl,
    required Locale? locale,
  }) async {
    await localeCtl.setLocale(locale);
    if (!context.mounted) return;

    final err = await model.setPreferredLanguage(locale?.languageCode);
    if (!context.mounted) return;

    if (err != null) {
      ProfileUi.snack(context, err);
      return;
    }

    await model.load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final model = context.watch<ProfileModel>();
    final localeCtl = context.watch<LocaleController>();

    final selectedLocale = model.preferredLanguage == null || model.preferredLanguage!.isEmpty
        ? localeCtl.locale
        : Locale(model.preferredLanguage!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: NestSectionTitle(l.profileQuestionnaireSection)),
            if (model.hasCompletedQuestionnaire)
              _NestLinkButton(
                icon: Icons.edit_outlined,
                label: l.commonEdit,
                onTap: () => Navigator.pushNamed(context, '/onboarding'),
              ),
          ],
        ),
        const SizedBox(height: 10),

        if (!model.hasCompletedQuestionnaire) ...[
          NestCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.profileQuestionnaireNotDoneTitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF2E4B5A).withOpacity(0.75),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _NestPrimaryButton(
                    label: l.profileQuestionnaireCta,
                    onTap: () => Navigator.pushNamed(context, '/onboarding'),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          NestCard(
            padding: const EdgeInsets.all(12),
            child: ProfileUi.chipsCard(
              context,
              title: l.profileLifeBlocksTitle,
              items: model.lifeBlocks,
              onEdit: () async {
                final v = await ProfileUi.selectLifeBlocksDialog(
                  context,
                  title: l.profileLifeBlocksTitle,
                  initial: model.lifeBlocks,
                );
                if (v == null) return;
                final err = await model.setLifeBlocks(v);
                if (err != null && context.mounted) {
                  ProfileUi.snack(context, err);
                }
              },
            ),
          ),
          const SizedBox(height: 10),

          NestCard(
            padding: const EdgeInsets.all(12),
            child: ProfileUi.chipsCard(
              context,
              title: l.profilePrioritiesTitle,
              items: model.priorities,
              onEdit: () async {
                final v = await ProfileUi.editChipsDialog(
                  context,
                  title: l.profilePrioritiesTitle,
                  initial: model.priorities,
                  hint: l.profilePrioritiesHint,
                );
                if (v == null) return;
                final err = await model.setPriorities(v);
                if (err != null && context.mounted) {
                  ProfileUi.snack(context, err);
                }
              },
            ),
          ),
          const SizedBox(height: 10),

          const HabitsCard(),
          const SizedBox(height: 12),

          NestCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.settingsLanguageTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2E4B5A),
                      ),
                ),
                const SizedBox(height: 10),
                _LanguageDropdown(
                  value: selectedLocale,
                  onChanged: (loc) => _changeLanguage(
                    context,
                    model: model,
                    localeCtl: localeCtl,
                    locale: loc,
                  ),
                ),
                const SizedBox(height: 6),
                Opacity(
                  opacity: 0.75,
                  child: Text(
                    l.settingsLanguageSubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: NestCard(
              padding: EdgeInsets.zero,
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                leading: Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  l.profileDangerZoneTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2E4B5A),
                      ),
                ),
                subtitle: Text(
                  'Удаление аккаунта',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E4B5A).withOpacity(0.65),
                      ),
                ),
                children: [
                  FilledButton.icon(
                    onPressed: model.deletingAccount
                        ? null
                        : () => _handleDeleteAccount(context, model),
                    icon: model.deletingAccount
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_forever_rounded),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        model.deletingAccount
                            ? l.profileDeletingAccount
                            : l.profileDeleteAccountCta,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Opacity(
                    opacity: 0.75,
                    child: Text(
                      l.profileDeleteAccountFootnote,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  final Locale? value;
  final ValueChanged<Locale?> onChanged;

  const _LanguageDropdown({required this.value, required this.onChanged});

  String _label(Locale? l) {
    if (l == null) return 'Системный';
    switch (l.languageCode) {
      case 'ru':
        return 'Русский';
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      case 'tr':
        return 'Türkçe';
      default:
        return l.languageCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final items = <Locale?>[
      null,
      const Locale('ru'),
      const Locale('en'),
      const Locale('de'),
      const Locale('fr'),
      const Locale('es'),
      const Locale('tr'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD6E6F5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x142B5B7A),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Locale?>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: cs.primary),
          items: items
              .map(
                (loc) => DropdownMenuItem<Locale?>(
                  value: loc,
                  child: Text(
                    _label(loc),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2E4B5A),
                        ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _NestLinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NestLinkButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF2E4B5A)),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E4B5A),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NestPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NestPrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3AA8E6), Color(0xFF6C8CFF)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A2B5B7A),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final String title;
  const _SheetHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }
}

