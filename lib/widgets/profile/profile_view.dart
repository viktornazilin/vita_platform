// lib/screens/profile/profile_view.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/locale_controller.dart';
import '../../main.dart';
import '../../models/habits_model.dart';
import '../../models/home_model.dart';
import '../../models/profile_model.dart';
import '../../widgets/nest/nest_background.dart';
import '../../widgets/nest/nest_sheet.dart';
import 'profile_ui_helpers.dart';


bool _ladnaIsDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
Color _ladnaScreenSurface(BuildContext context) => _ladnaIsDark(context) ? const Color(0xFF100C1E) : _LadnaColors.surface;
Color _ladnaCardSurface(BuildContext context) => _ladnaIsDark(context) ? const Color(0xFF1C1630) : _LadnaColors.cardLight;
Color _ladnaSoftSurface(BuildContext context) => _ladnaIsDark(context) ? const Color(0x1F6B54C0) : _LadnaColors.primarySoft;
Color _ladnaText(BuildContext context) => _ladnaIsDark(context) ? const Color(0xFFF0EEFF) : _LadnaColors.darkText;
Color _ladnaBody(BuildContext context) => _ladnaIsDark(context) ? const Color(0xCCFFFFFF) : _LadnaColors.text;
Color _ladnaMuted(BuildContext context) => _ladnaIsDark(context) ? const Color(0x99FFFFFF) : _LadnaColors.muted;
Color _ladnaWeak(BuildContext context) => _ladnaIsDark(context) ? const Color(0x55FFFFFF) : _LadnaColors.muted;
Color _ladnaBorder(BuildContext context) => _ladnaIsDark(context) ? const Color(0x336B54C0) : _LadnaColors.primary.withOpacity(0.12);
Color _ladnaDivider(BuildContext context) => _ladnaIsDark(context) ? const Color(0x1FFFFFFF) : _LadnaColors.primary.withOpacity(0.08);
TextStyle _ladnaCardTitle(BuildContext context) => TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _ladnaText(context));
TextStyle _ladnaRowTitle(BuildContext context) => TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _ladnaText(context));
TextStyle _ladnaRowSubtitle(BuildContext context) => TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _ladnaMuted(context));
TextStyle _ladnaSmallMuted(BuildContext context) => TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _ladnaMuted(context));
TextStyle _ladnaBodyMuted(BuildContext context) => TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _ladnaBody(context));

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _settingsMode = false;
  String? _lastShownError;

  Future<void> _refreshAll() async {
    await context.read<ProfileModel>().load();
    await context.read<HabitsModel>().load();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ProfileModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final err = model.error;
      if (!mounted || err == null || err == _lastShownError) return;
      _lastShownError = err;
      _snack(context, err);
    });

    return Scaffold(
      body: NestBackground(
        child: SafeArea(
          bottom: false,
          child: model.loading
              ? const Center(child: CircularProgressIndicator.adaptive())
              : RefreshIndicator(
                  color: _LadnaColors.primary,
                  backgroundColor: _LadnaColors.surface,
                  onRefresh: _refreshAll,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _settingsMode
                        ? _SettingsPage(
                            key: const ValueKey('settings'),
                            onBack: () => setState(() => _settingsMode = false),
                          )
                        : _ProfilePage(
                            key: const ValueKey('profile'),
                            onOpenSettings: () => setState(() => _settingsMode = true),
                          ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({super.key, required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ProfileModel>();
    final t = _LadnaText.of(context);
    final name = (model.name?.trim().isNotEmpty == true) ? model.name!.trim() : t.profileFallbackName;
    final email = (model.email?.trim().isNotEmpty == true)
        ? model.email!.trim()
        : (Supabase.instance.client.auth.currentUser?.email ?? t.profileNoEmail);

    final blocks = model.lifeBlocks.isEmpty
        ? const ['career', 'finance', 'education', 'family']
        : model.lifeBlocks.take(6).toList();

    return _LadnaScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            title: t.profile,
            onBack: () => _goHome(context),
          ),
          const SizedBox(height: 12),
          _ProfileHero(
            name: name,
            email: email,
            onSettings: onOpenSettings,
          ),
          const SizedBox(height: 16),
          _SectionLabel(t.personalData),
          _InfoCard(
            children: [
              _EditableInfoRow(
                label: t.name,
                value: name,
                onTap: () => _editName(context, model),
              ),
              _EditableInfoRow(
                label: t.age,
                value: model.age?.toString() ?? t.notSpecified,
                muted: model.age == null,
                onTap: () => _editAge(context, model),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionLabel(t.lifeSpheres),
          _ChipsCard(
            title: t.mySpheres,
            action: t.edit,
            onAction: () => _editLifeBlocks(context, model),
            children: blocks.map((b) => ProfileUi.blockLabel(context, b)).toList(),
          ),
          const SizedBox(height: 16),
          _SectionLabel(t.habits),
          const _HabitsPreviewCard(),
          SizedBox(height: 120 + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _goHome(BuildContext context) {
    try {
      context.read<HomeModel>().select(0);
      return;
    } catch (_) {
      // The profile can also be opened as a standalone route.
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        return;
      }
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  Future<void> _editName(BuildContext context, ProfileModel model) async {
    final t = _LadnaText.of(context);
    final value = await ProfileUi.promptText(
      context,
      title: t.name,
      label: t.enterName,
      initial: model.name ?? '',
      maxLen: 40,
    );
    if (value == null) return;
    final err = await model.setName(value.trim().isEmpty ? null : value.trim());
    if (err != null && context.mounted) _snack(context, err);
  }

  Future<void> _editAge(BuildContext context, ProfileModel model) async {
    final t = _LadnaText.of(context);
    final value = await ProfileUi.promptInt(
      context,
      title: t.age,
      label: t.enterAge,
      initial: model.age,
      min: 10,
      max: 120,
    );
    final err = await model.setAge(value);
    if (err != null && context.mounted) _snack(context, err);
  }

  Future<void> _editLifeBlocks(BuildContext context, ProfileModel model) async {
    final t = _LadnaText.of(context);
    final value = await ProfileUi.selectLifeBlocksDialog(
      context,
      title: t.lifeSpheres,
      initial: model.lifeBlocks,
    );
    if (value == null) return;
    final err = await model.setLifeBlocks(value);
    if (err != null && context.mounted) _snack(context, err);
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ProfileModel>();
    final t = _LadnaText.of(context);

    return _LadnaScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(title: t.settings, onBack: onBack),
          const SizedBox(height: 16),
          _SectionLabel(t.focus),
          _SettingsCard(
            rows: [
              _SettingsRow(
                icon: Icons.timer_outlined,
                iconBg: _LadnaColors.primarySoft,
                title: t.targetHoursTitle,
                subtitle: t.targetHoursSubtitle,
                trailing: '${model.targetHours.toStringAsFixed(model.targetHours % 1 == 0 ? 0 : 1)} ${t.hoursShort}',
                onTap: () => _editTargetHours(context, model),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionLabel(t.notifications),
          const _NotificationSettingsCard(),
          const SizedBox(height: 16),
          _SectionLabel(t.app),
          _SettingsCard(
            rows: [
              _SettingsRow(
                icon: Icons.language_rounded,
                iconBg: const Color(0x1A825ABE),
                title: t.language,
                trailing: _languageLabel(context, model),
                onTap: () => _openLanguageSheet(context, model),
              ),
              _SettingsRow(
                icon: Icons.calendar_month_outlined,
                iconBg: const Color(0x1A3B6FD4),
                title: 'Google Calendar',
                subtitle: t.googleCalendarSubtitle,
                onTap: () => _snack(context, t.googleCalendarMovedHint),
              ),
              _SettingsRow(
                icon: Icons.download_rounded,
                iconBg: const Color(0x1A16B8A8),
                title: t.exportData,
                subtitle: t.exportDataSubtitle,
                onTap: () => _exportData(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionLabel(t.legalDocuments),
          _LegalDocumentsCard(),
          const SizedBox(height: 16),
          _LogoutButton(onTap: () => _confirmSignOut(context)),
          const SizedBox(height: 12),
          _DangerCard(
            deleting: model.deletingAccount,
            onTap: model.deletingAccount ? null : () => _confirmDeleteAccount(context, model),
          ),
          SizedBox(height: 120 + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Future<void> _editTargetHours(BuildContext context, ProfileModel model) async {
    final t = _LadnaText.of(context);
    final value = await ProfileUi.promptDouble(
      context,
      title: t.targetHoursTitle,
      label: t.targetHoursField,
      initial: model.targetHours,
      min: 1,
      max: 24,
      decimals: 1,
    );
    if (value == null) return;
    final err = await model.setTargetHours(value);
    if (err != null && context.mounted) _snack(context, err);
  }

  String _languageLabel(BuildContext context, ProfileModel model) {
    final t = _LadnaText.of(context);
    final code = model.preferredLanguage;
    if (code == null || code.isEmpty) return t.system;
    return switch (code) {
      'ru' => 'Русский',
      'de' => 'Deutsch',
      'fr' => 'Français',
      'es' => 'Español',
      'tr' => 'Türkçe',
      _ => 'English',
    };
  }

  Future<void> _openLanguageSheet(BuildContext context, ProfileModel model) async {
    final t = _LadnaText.of(context);
    final localeCtl = context.read<LocaleController>();
    final options = <({String label, Locale? locale})>[
      (label: t.system, locale: null),
      (label: 'Русский', locale: const Locale('ru')),
      (label: 'English', locale: const Locale('en')),
      (label: 'Deutsch', locale: const Locale('de')),
      (label: 'Français', locale: const Locale('fr')),
      (label: 'Español', locale: const Locale('es')),
      (label: 'Türkçe', locale: const Locale('tr')),
    ];

    final selected = await showModalBottomSheet<Locale?>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NestSheet(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + MediaQuery.of(ctx).padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.language,
                style: _LadnaTextStyle.serifTitle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 10),
              for (final opt in options)
                _SheetOption(
                  label: opt.label,
                  selected: (opt.locale?.languageCode ?? '') == (model.preferredLanguage ?? ''),
                  onTap: () => Navigator.pop(ctx, opt.locale),
                ),
            ],
          ),
        ),
      ),
    );

    if (!context.mounted) return;
    await localeCtl.setLocale(selected);
    final err = await model.setPreferredLanguage(selected?.languageCode);
    if (err != null && context.mounted) _snack(context, err);
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final t = _LadnaText.of(context);
    final ok = await _confirmSheet(
      context,
      title: t.signOut,
      body: t.signOutConfirm,
      confirmLabel: t.signOut,
      destructive: false,
    );
    if (ok != true) return;

    try {
      await Supabase.instance.client.auth.signOut();
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (context.mounted) _snack(context, e.toString());
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context, ProfileModel model) async {
    final t = _LadnaText.of(context);
    final ok = await _confirmSheet(
      context,
      title: t.deleteAccount,
      body: t.deleteAccountConfirm,
      confirmLabel: t.deleteAccount,
      destructive: true,
    );
    if (ok != true) return;

    final err = await model.deleteAccount();
    if (err != null && context.mounted) _snack(context, err);
  }
}

class _NotificationSettingsCard extends StatefulWidget {
  const _NotificationSettingsCard();

  @override
  State<_NotificationSettingsCard> createState() => _NotificationSettingsCardState();
}

class _NotificationSettingsCardState extends State<_NotificationSettingsCard> {
  static const _kPermissionAsked = 'ladna_webnotif_permission_asked';
  static const _kEveningEnabled = 'vita_webnotif_evening_enabled';
  static const _kHour = 'vita_webnotif_evening_hour';
  static const _kMinute = 'vita_webnotif_evening_minute';

  bool _loading = true;
  bool _permissionRequested = false;
  bool _eveningEnabled = false;
  int _hour = 21;
  int _minute = 30;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _permissionRequested = prefs.getBool(_kPermissionAsked) ?? false;
      _eveningEnabled = prefs.getBool(_kEveningEnabled) ?? false;
      _hour = prefs.getInt(_kHour) ?? 21;
      _minute = prefs.getInt(_kMinute) ?? 30;
      _loading = false;
    });
    await _apply();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPermissionAsked, _permissionRequested);
    await prefs.setBool(_kEveningEnabled, _eveningEnabled);
    await prefs.setInt(_kHour, _hour);
    await prefs.setInt(_kMinute, _minute);
  }

  String get _time => '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';

  Future<void> _apply() async {
    if (!_eveningEnabled || !webNotifs.isSupported) {
      webNotifs.cancel('evening_checkin');
      return;
    }

    final t = _LadnaText.of(context);
    webNotifs.scheduleDaily(
      key: 'evening_checkin',
      hour: _hour,
      minute: _minute,
      title: t.eveningCheckIn,
      body: t.eveningCheckInBody,
    );
  }

  Future<void> _requestPermission(bool value) async {
    final t = _LadnaText.of(context);
    if (!webNotifs.isSupported) {
      _snack(context, t.notificationsUnsupported);
      return;
    }

    if (value) {
      final ok = await webNotifs.requestPermission();
      if (!mounted) return;
      setState(() => _permissionRequested = ok);
      await _save();
      _snack(context, ok ? t.notificationsEnabled : t.notificationsDenied);
    } else {
      setState(() {
        _permissionRequested = false;
        _eveningEnabled = false;
      });
      await _save();
      await _apply();
    }
  }

  Future<void> _toggleEvening(bool value) async {
    if (value && !_permissionRequested) {
      await _requestPermission(true);
      if (!mounted || !_permissionRequested) return;
    }
    setState(() => _eveningEnabled = value);
    await _save();
    await _apply();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
    );
    if (picked == null) return;
    setState(() {
      _hour = picked.hour;
      _minute = picked.minute;
    });
    await _save();
    await _apply();
  }

  @override
  Widget build(BuildContext context) {
    final t = _LadnaText.of(context);

    if (_loading) {
      return const _SettingsCard(
        rows: [
          _LoadingSettingsRow(),
        ],
      );
    }

    return _SettingsCard(
      rows: [
        _SwitchSettingsRow(
          icon: Icons.notifications_none_rounded,
          iconBg: const Color(0x1A16B8A8),
          title: t.allowNotifications,
          subtitle: t.notificationsSubtitle,
          value: _permissionRequested,
          onChanged: _requestPermission,
        ),
        _SwitchSettingsRow(
          icon: Icons.nightlight_round,
          iconBg: _LadnaColors.primarySoft,
          title: t.eveningCheckIn,
          subtitle: t.everyDayAt(_time),
          value: _eveningEnabled,
          onChanged: _toggleEvening,
          onTap: _pickTime,
        ),
      ],
    );
  }
}

class _HabitsPreviewCard extends StatelessWidget {
  const _HabitsPreviewCard();

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitsModel>();
    final t = _LadnaText.of(context);

    return _BaseCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.myHabits,
                  style: _ladnaCardTitle(context),
                ),
              ),
              _SmallSquareButton(
                icon: Icons.add_rounded,
                onTap: () => _snack(context, t.addHabitHint),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (habits.loading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else if (habits.items.isEmpty)
            Text(
              t.noHabitsYet,
              style: _ladnaBodyMuted(context),
            )
          else
            ...habits.items.take(4).toList().asMap().entries.map((entry) {
              final idx = entry.key;
              final h = entry.value;
              return _HabitPreviewRow(
                title: '${h.title}',
                streak: t.daysCount(_safeStreak(h)),
                color: _habitColor(idx),
              );
            }),
        ],
      ),
    );
  }

  int _safeStreak(dynamic h) {
    try {
      final v = h.currentStreak;
      if (v is int) return v;
      if (v is num) return v.toInt();
    } catch (_) {}
    return 0;
  }

  Color _habitColor(int idx) => switch (idx % 3) {
        0 => _LadnaColors.teal,
        1 => _LadnaColors.primary,
        _ => _LadnaColors.lime,
      };
}

class _LadnaScreen extends StatelessWidget {
  const _LadnaScreen({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            isWide ? 24 : 16,
            12,
            isWide ? 24 : 16,
            0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 560 : 520),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _ladnaIsDark(context)
              ? const [Color(0x1F6B54C0), Color(0x221E1548)]
              : const [_LadnaColors.surface, Color(0xFFE2DDEF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _ladnaIsDark(context) ? const Color(0x406B54C0) : _LadnaColors.primary.withOpacity(0.15)),
        boxShadow: _ladnaIsDark(context) ? _LadnaShadows.darkSoft : _LadnaShadows.card,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _ladnaSoftSurface(context),
                shape: BoxShape.circle,
                border: Border.all(color: _ladnaIsDark(context) ? const Color(0x506B54C0) : _LadnaColors.primary.withOpacity(0.20)),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 24,
                color: _ladnaText(context),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              title,
              style: _LadnaTextStyle.serifTitle.copyWith(fontSize: 17, color: _ladnaText(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.name,
    required this.email,
    required this.onSettings,
  });

  final String name;
  final String email;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final t = _LadnaText.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_LadnaColors.darkCard, Color(0xFF1E1248)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: _LadnaShadows.dark,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -48,
            right: -44,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _LadnaColors.primary.withOpacity(0.20),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: _LadnaColors.primary.withOpacity(0.20),
                  shape: BoxShape.circle,
                  border: Border.all(color: _LadnaColors.primary.withOpacity(0.35), width: 2),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _LadnaTextStyle.serifTitle.copyWith(
                        fontSize: 20,
                        color: _LadnaColors.creamText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0x73FAF6EE),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: onSettings,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _LadnaColors.primary.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _LadnaColors.primary.withOpacity(0.30)),
                  ),
                  child: Text(
                    t.settings,
                    style: const TextStyle(
                      color: _LadnaColors.primaryLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 3, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: _ladnaMuted(context),
        ),
      ),
    );
  }
}

class _BaseCard extends StatelessWidget {
  const _BaseCard({required this.child, this.padding = EdgeInsets.zero, this.color});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? _ladnaCardSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ladnaBorder(context)),
        boxShadow: _ladnaIsDark(context) ? _LadnaShadows.darkSoft : _LadnaShadows.card,
      ),
      child: child,
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const _CardDivider(),
          ],
        ],
      ),
    );
  }
}

class _EditableInfoRow extends StatelessWidget {
  const _EditableInfoRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.muted = false,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        child: Row(
          children: [
            SizedBox(
              width: 82,
              child: Text(label, style: _ladnaSmallMuted(context)),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: muted ? _ladnaMuted(context) : _ladnaText(context),
                ),
              ),
            ),
            Icon(Icons.edit_outlined, size: 16, color: _ladnaMuted(context)),
          ],
        ),
      ),
    );
  }
}

class _ChipsCard extends StatelessWidget {
  const _ChipsCard({
    required this.title,
    required this.action,
    required this.children,
    required this.onAction,
  });

  final String title;
  final String action;
  final List<String> children;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: _ladnaCardTitle(context))),
              InkWell(
                onTap: onAction,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  child: Text(
                    action,
                    style: TextStyle(
                      color: _ladnaIsDark(context) ? _LadnaColors.lime : _LadnaColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: children
                .map(
                  (label) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _ladnaIsDark(context) ? const Color(0x2A6B54C0) : _LadnaColors.darkCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _ladnaIsDark(context) ? const Color(0x336B54C0) : Colors.transparent),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: _ladnaIsDark(context) ? const Color(0xFFF0EEFF) : _LadnaColors.creamText,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _HabitPreviewRow extends StatelessWidget {
  const _HabitPreviewRow({required this.title, required this.streak, required this.color});

  final String title;
  final String streak;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _ladnaDivider(context))),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: _ladnaText(context), fontWeight: FontWeight.w600),
            ),
          ),
          Text(streak, style: _ladnaSmallMuted(context)),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1) const _CardDivider(),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconBg,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        child: Row(
          children: [
            _IconBox(icon: icon, background: iconBg),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _ladnaRowTitle(context)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: _ladnaRowSubtitle(context)),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  trailing!,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ladnaBody(context)),
                ),
              ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, size: 18, color: _ladnaMuted(context)),
          ],
        ),
      ),
    );
  }
}

class _SwitchSettingsRow extends StatelessWidget {
  const _SwitchSettingsRow({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        child: Row(
          children: [
            _IconBox(icon: icon, background: iconBg),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _ladnaRowTitle(context)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: _ladnaRowSubtitle(context)),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              activeColor: _LadnaColors.primary,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingSettingsRow extends StatelessWidget {
  const _LoadingSettingsRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.background});

  final IconData icon;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: _ladnaIsDark(context) ? background.withOpacity(0.24) : background, borderRadius: BorderRadius.circular(9)),
      child: Icon(icon, size: 17, color: _ladnaIsDark(context) ? const Color(0xCCFFFFFF) : _LadnaColors.text),
    );
  }
}

class _LegalDocumentsCard extends StatelessWidget {
  const _LegalDocumentsCard();

  @override
  Widget build(BuildContext context) {
    final t = _LadnaText.of(context);
    final items = <({String title, String url})>[
      (title: 'Privacy Policy', url: 'https://nest-landing-lemon.vercel.app/privacy'),
      (title: 'Datenschutzerklärung', url: 'https://nest-landing-lemon.vercel.app/privacy'),
      (title: 'Terms of Use', url: 'https://nest-landing-lemon.vercel.app/terms'),
      (title: 'Impressum', url: 'https://nest-landing-lemon.vercel.app/impressum'),
    ];

    return _BaseCard(
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            InkWell(
              onTap: () => _openUrl(context, items[i].url),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                child: Row(
                  children: [
                    Expanded(child: Text(items[i].title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ladnaBody(context)))),
                    Icon(Icons.open_in_new_rounded, size: 15, color: _ladnaMuted(context)),
                  ],
                ),
              ),
            ),
            if (i != items.length - 1) const _CardDivider(),
          ],
          if (items.isEmpty) Padding(padding: const EdgeInsets.all(14), child: Text(t.noData, style: _ladnaBodyMuted(context))),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = _LadnaText.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _LadnaColors.primary.withOpacity(0.25), width: 1.5),
        ),
        child: Center(
          child: Text(
            t.signOut,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _ladnaText(context)),
          ),
        ),
      ),
    );
  }
}

class _DangerCard extends StatelessWidget {
  const _DangerCard({required this.deleting, required this.onTap});

  final bool deleting;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = _LadnaText.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _LadnaColors.danger.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _LadnaColors.danger.withOpacity(0.30)),
          boxShadow: _LadnaShadows.card,
        ),
        child: Row(
          children: [
            deleting
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator.adaptive(strokeWidth: 2))
                : const Icon(Icons.warning_amber_rounded, color: _LadnaColors.danger, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.deleteAccount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _LadnaColors.danger)),
                  const SizedBox(height: 2),
                  Text(t.deleteAccountSubtitle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _LadnaColors.danger.withOpacity(0.75))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _LadnaColors.danger.withOpacity(0.55)),
          ],
        ),
      ),
    );
  }
}

class _SmallSquareButton extends StatelessWidget {
  const _SmallSquareButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: _ladnaSoftSurface(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _LadnaColors.primary.withOpacity(0.20)),
        ),
        child: Icon(icon, size: 18, color: _LadnaColors.primary),
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: _ladnaDivider(context));
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _ladnaText(context)))),
            if (selected) const Icon(Icons.check_rounded, color: _LadnaColors.primary),
          ],
        ),
      ),
    );
  }
}

Future<bool?> _confirmSheet(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool destructive = false,
}) {
  final t = _LadnaText.of(context);
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => NestSheet(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + MediaQuery.of(ctx).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: _LadnaTextStyle.serifTitle.copyWith(fontSize: 20, color: _ladnaText(ctx))),
            const SizedBox(height: 8),
            Text(body, style: _ladnaBodyMuted(ctx).copyWith(height: 1.45)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(t.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: destructive
                        ? FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error, foregroundColor: Colors.white)
                        : null,
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _exportData(BuildContext context) async {
  final t = _LadnaText.of(context);
  final client = Supabase.instance.client;
  final user = client.auth.currentUser;
  if (user == null) {
    _snack(context, t.notSignedIn);
    return;
  }

  try {
    Map<String, dynamic>? userProfile;
    try {
      userProfile = await client.from('users').select().eq('id', user.id).maybeSingle();
    } catch (e) {
      userProfile = {'_warning': 'Profile export failed', '_error': e.toString()};
    }

    final tables = ['goals', 'user_goals', 'moods', 'expenses', 'ai_insights_runs', 'ai_plans', 'ai_plan_items'];
    final data = <String, dynamic>{};
    for (final table in tables) {
      try {
        data[table] = await client.from(table).select().eq('user_id', user.id);
      } catch (e) {
        data[table] = [{'_warning': 'Table export failed', '_error': e.toString()}];
      }
    }

    final export = {
      'export': {
        'type': 'gdpr_data_export',
        'app': 'Ladna',
        'created_at': DateTime.now().toUtc().toIso8601String(),
      },
      'account': {
        'auth_user': {
          'id': user.id,
          'email': user.email,
          'created_at': user.createdAt,
          'last_sign_in_at': user.lastSignInAt,
        },
        'profile': userProfile,
      },
      'data': data,
    };

    const encoder = JsonEncoder.withIndent('  ');
    final json = encoder.convert(export);
    await Clipboard.setData(ClipboardData(text: json));
    if (context.mounted) _snack(context, t.exportCopied);
  } catch (e) {
    if (context.mounted) _snack(context, '${t.exportFailed}: $e');
  }
}

Future<void> _openUrl(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  try {
    final ok = await launchUrl(uri, mode: LaunchMode.platformDefault, webOnlyWindowName: '_blank');
    if (!ok && context.mounted) _snack(context, _LadnaText.of(context).openLinkFailed);
  } catch (_) {
    if (context.mounted) _snack(context, _LadnaText.of(context).openLinkFailed);
  }
}

void _snack(BuildContext context, String text) {
  final sm = ScaffoldMessenger.maybeOf(context);
  if (sm == null) return;
  sm.showSnackBar(
    SnackBar(
      content: Text(text, style: TextStyle(fontWeight: FontWeight.w700, color: _ladnaText(context))),
      behavior: SnackBarBehavior.floating,
      backgroundColor: _ladnaCardSurface(context),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

class _LadnaColors {
  static const background = Color(0xFFD6D0EC);
  static const surface = Color(0xFFF5F3FA);
  static const card = Color(0xFFEAE6F5);
  static const cardLight = Color(0xFFFAFAFE);
  static const primary = Color(0xFF6B54C0);
  static const primaryLight = Color(0xFFB9A9F3);
  static const primarySoft = Color(0x1F7260B8);
  static const darkCard = Color(0xFF160E38);
  static const darkText = Color(0xFF160E38);
  static const text = Color(0xFF555268);
  static const muted = Color(0xFF9090A8);
  static const teal = Color(0xFF16B8A8);
  static const lime = Color(0xFFD4E040);
  static const danger = Color(0xFFE05252);
  static const creamText = Color(0xFFFAF6EE);
}

class _LadnaShadows {
  static final card = [
    BoxShadow(color: const Color(0xFF1C1812).withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 2)),
  ];
  static final dark = [
    BoxShadow(color: const Color(0xFF1C1812).withOpacity(0.28), blurRadius: 18, offset: const Offset(0, 4)),
  ];
  static final darkSoft = [
    BoxShadow(color: Colors.black.withOpacity(0.28), blurRadius: 16, offset: const Offset(0, 4)),
  ];
}

class _LadnaTextStyle {
  static const serifTitle = TextStyle(
    fontFamily: 'Playfair Display',
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: _LadnaColors.darkText,
  );
  static const cardTitle = TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _LadnaColors.darkText);
  static const rowTitle = TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _LadnaColors.darkText);
  static const rowSubtitle = TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _LadnaColors.muted);
  static const smallMuted = TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _LadnaColors.muted);
  static const bodyMuted = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _LadnaColors.text);
}

class _LadnaText {
  _LadnaText(this.lang);
  final String lang;

  static _LadnaText of(BuildContext context) => _LadnaText(Localizations.localeOf(context).languageCode.toLowerCase());

  String pick(Map<String, String> values) => values[lang] ?? values['en'] ?? values['ru'] ?? values.values.first;

  String get profile => pick({'ru': 'Профиль', 'en': 'Profile', 'de': 'Profil', 'fr': 'Profil', 'es': 'Perfil', 'tr': 'Profil'});
  String get settings => pick({'ru': 'Настройки', 'en': 'Settings', 'de': 'Einstellungen', 'fr': 'Réglages', 'es': 'Ajustes', 'tr': 'Ayarlar'});
  String get profileFallbackName => pick({'ru': 'Пользователь', 'en': 'User', 'de': 'Nutzer', 'fr': 'Utilisateur', 'es': 'Usuario', 'tr': 'Kullanıcı'});
  String get profileNoEmail => pick({'ru': 'Email не указан', 'en': 'No email', 'de': 'Keine E-Mail', 'fr': 'Aucun e-mail', 'es': 'Sin email', 'tr': 'E-posta yok'});
  String get personalData => pick({'ru': 'Личные данные', 'en': 'Personal data', 'de': 'Persönliche Daten', 'fr': 'Données personnelles', 'es': 'Datos personales', 'tr': 'Kişisel bilgiler'});
  String get name => pick({'ru': 'Имя', 'en': 'Name', 'de': 'Name', 'fr': 'Nom', 'es': 'Nombre', 'tr': 'Ad'});
  String get enterName => pick({'ru': 'Введите имя', 'en': 'Enter name', 'de': 'Name eingeben', 'fr': 'Saisir le nom', 'es': 'Introduce el nombre', 'tr': 'Ad gir'});
  String get age => pick({'ru': 'Возраст', 'en': 'Age', 'de': 'Alter', 'fr': 'Âge', 'es': 'Edad', 'tr': 'Yaş'});
  String get enterAge => pick({'ru': 'Введите возраст', 'en': 'Enter age', 'de': 'Alter eingeben', 'fr': 'Saisir l’âge', 'es': 'Introduce la edad', 'tr': 'Yaş gir'});
  String get notSpecified => pick({'ru': 'Не указан', 'en': 'Not specified', 'de': 'Nicht angegeben', 'fr': 'Non indiqué', 'es': 'No indicado', 'tr': 'Belirtilmedi'});
  String get lifeSpheres => pick({'ru': 'Сферы жизни', 'en': 'Life spheres', 'de': 'Lebensbereiche', 'fr': 'Domaines de vie', 'es': 'Áreas de vida', 'tr': 'Yaşam alanları'});
  String get mySpheres => pick({'ru': 'Мои сферы', 'en': 'My spheres', 'de': 'Meine Bereiche', 'fr': 'Mes domaines', 'es': 'Mis áreas', 'tr': 'Alanlarım'});
  String get edit => pick({'ru': 'Редактировать', 'en': 'Edit', 'de': 'Bearbeiten', 'fr': 'Modifier', 'es': 'Editar', 'tr': 'Düzenle'});
  String get habits => pick({'ru': 'Привычки', 'en': 'Habits', 'de': 'Gewohnheiten', 'fr': 'Habitudes', 'es': 'Hábitos', 'tr': 'Alışkanlıklar'});
  String get myHabits => pick({'ru': 'Мои привычки', 'en': 'My habits', 'de': 'Meine Gewohnheiten', 'fr': 'Mes habitudes', 'es': 'Mis hábitos', 'tr': 'Alışkanlıklarım'});
  String get noHabitsYet => pick({'ru': 'Привычек пока нет', 'en': 'No habits yet', 'de': 'Noch keine Gewohnheiten', 'fr': 'Aucune habitude', 'es': 'Aún no hay hábitos', 'tr': 'Henüz alışkanlık yok'});
  String get addHabitHint => pick({'ru': 'Добавление привычек оставлено в текущем редакторе привычек.', 'en': 'Habit creation remains in the current habit editor.'});
  String daysCount(int n) => pick({'ru': '$n дней', 'en': '$n days', 'de': '$n Tage', 'fr': '$n jours', 'es': '$n días', 'tr': '$n gün'});
  String get focus => pick({'ru': 'Фокус', 'en': 'Focus', 'de': 'Fokus', 'fr': 'Focus', 'es': 'Foco', 'tr': 'Odak'});
  String get targetHoursTitle => pick({'ru': 'Норма часов в день', 'en': 'Daily target hours', 'de': 'Tägliche Zielstunden', 'fr': 'Heures cibles par jour', 'es': 'Horas objetivo al día', 'tr': 'Günlük hedef saat'});
  String get targetHoursSubtitle => pick({'ru': 'Используется для расчёта прогресса', 'en': 'Used to calculate progress', 'de': 'Wird zur Fortschrittsberechnung genutzt', 'fr': 'Utilisé pour calculer le progrès', 'es': 'Se usa para calcular el progreso', 'tr': 'İlerleme hesabında kullanılır'});
  String get targetHoursField => pick({'ru': 'Часы в день', 'en': 'Hours per day', 'de': 'Stunden pro Tag', 'fr': 'Heures par jour', 'es': 'Horas por día', 'tr': 'Günde saat'});
  String get hoursShort => pick({'ru': 'ч', 'en': 'h', 'de': 'Std.', 'fr': 'h', 'es': 'h', 'tr': 'sa'});
  String get notifications => pick({'ru': 'Уведомления', 'en': 'Notifications', 'de': 'Benachrichtigungen', 'fr': 'Notifications', 'es': 'Notificaciones', 'tr': 'Bildirimler'});
  String get allowNotifications => pick({'ru': 'Разрешить уведомления', 'en': 'Allow notifications', 'de': 'Benachrichtigungen erlauben', 'fr': 'Autoriser les notifications', 'es': 'Permitir notificaciones', 'tr': 'Bildirimlere izin ver'});
  String get notificationsSubtitle => pick({'ru': 'Работает только пока вкладка открыта', 'en': 'Works while the tab is open', 'de': 'Funktioniert solange der Tab geöffnet ist', 'fr': 'Fonctionne tant que l’onglet est ouvert', 'es': 'Funciona mientras la pestaña está abierta', 'tr': 'Sekme açıkken çalışır'});
  String get eveningCheckIn => pick({'ru': 'Вечерний чек-ин', 'en': 'Evening check-in', 'de': 'Abend-Check-in', 'fr': 'Check-in du soir', 'es': 'Check-in nocturno', 'tr': 'Akşam kontrolü'});
  String get eveningCheckInBody => pick({'ru': 'Отметь настроение и заверши день спокойно.', 'en': 'Log your mood and close the day calmly.'});
  String everyDayAt(String time) => pick({'ru': 'Каждый день в $time', 'en': 'Every day at $time', 'de': 'Jeden Tag um $time', 'fr': 'Tous les jours à $time', 'es': 'Cada día a las $time', 'tr': 'Her gün $time'});
  String get notificationsUnsupported => pick({'ru': 'Уведомления в этой среде не поддерживаются.', 'en': 'Notifications are not supported here.'});
  String get notificationsEnabled => pick({'ru': 'Уведомления разрешены.', 'en': 'Notifications enabled.'});
  String get notificationsDenied => pick({'ru': 'Разрешение на уведомления не получено.', 'en': 'Notification permission was not granted.'});
  String get app => pick({'ru': 'Приложение', 'en': 'App', 'de': 'App', 'fr': 'Application', 'es': 'Aplicación', 'tr': 'Uygulama'});
  String get language => pick({'ru': 'Язык', 'en': 'Language', 'de': 'Sprache', 'fr': 'Langue', 'es': 'Idioma', 'tr': 'Dil'});
  String get system => pick({'ru': 'Системный', 'en': 'System', 'de': 'System', 'fr': 'Système', 'es': 'Sistema', 'tr': 'Sistem'});
  String get googleCalendarSubtitle => pick({'ru': 'Экспорт целей в календарь', 'en': 'Export goals to calendar', 'de': 'Ziele in den Kalender exportieren', 'fr': 'Exporter les objectifs vers le calendrier', 'es': 'Exportar objetivos al calendario', 'tr': 'Hedefleri takvime aktar'});
  String get googleCalendarMovedHint => pick({'ru': 'Google Calendar теперь находится в настройках профиля.', 'en': 'Google Calendar is now in profile settings.'});
  String get exportData => pick({'ru': 'Экспортировать данные', 'en': 'Export data', 'de': 'Daten exportieren', 'fr': 'Exporter les données', 'es': 'Exportar datos', 'tr': 'Verileri dışa aktar'});
  String get exportDataSubtitle => pick({'ru': 'JSON-экспорт всего аккаунта', 'en': 'JSON export of your account', 'de': 'JSON-Export deines Kontos', 'fr': 'Export JSON du compte', 'es': 'Exportación JSON de la cuenta', 'tr': 'Hesabın JSON çıktısı'});
  String get exportCopied => pick({'ru': 'Экспорт скопирован в буфер обмена.', 'en': 'Export copied to clipboard.'});
  String get exportFailed => pick({'ru': 'Не удалось экспортировать данные', 'en': 'Could not export data'});
  String get notSignedIn => pick({'ru': 'Пользователь не авторизован.', 'en': 'User is not signed in.'});
  String get legalDocuments => pick({'ru': 'Правовые документы', 'en': 'Legal documents', 'de': 'Rechtliche Dokumente', 'fr': 'Documents juridiques', 'es': 'Documentos legales', 'tr': 'Yasal belgeler'});
  String get openLinkFailed => pick({'ru': 'Не удалось открыть ссылку.', 'en': 'Could not open the link.'});
  String get signOut => pick({'ru': 'Выйти из аккаунта', 'en': 'Sign out', 'de': 'Abmelden', 'fr': 'Se déconnecter', 'es': 'Cerrar sesión', 'tr': 'Çıkış yap'});
  String get signOutConfirm => pick({'ru': 'Ты точно хочешь выйти из аккаунта?', 'en': 'Are you sure you want to sign out?'});
  String get deleteAccount => pick({'ru': 'Удалить аккаунт', 'en': 'Delete account', 'de': 'Konto löschen', 'fr': 'Supprimer le compte', 'es': 'Eliminar cuenta', 'tr': 'Hesabı sil'});
  String get deleteAccountSubtitle => pick({'ru': 'Все данные будут удалены безвозвратно', 'en': 'All data will be permanently deleted'});
  String get deleteAccountConfirm => pick({'ru': 'Это действие нельзя отменить. Все данные аккаунта будут удалены безвозвратно.', 'en': 'This cannot be undone. All account data will be permanently deleted.'});
  String get cancel => pick({'ru': 'Отмена', 'en': 'Cancel', 'de': 'Abbrechen', 'fr': 'Annuler', 'es': 'Cancelar', 'tr': 'İptal'});
  String get noData => pick({'ru': 'Нет данных', 'en': 'No data'});
}
