// lib/screens/profile/profile_view.dart
import 'dart:convert';
import 'dart:math' as math;

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
import '../../models/ladna_space.dart';
import '../../models/space_invite.dart';
import '../../models/space_member.dart';
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

String _formatLadnaDate(BuildContext context, DateTime date) {
  return MaterialLocalizations.of(context).formatMediumDate(date);
}

String _spaceValidityLabel(BuildContext context, LadnaSpace space) {
  final t = _LadnaText.of(context);
  final validUntil = space.validUntil;
  if (validUntil == null) return t.spaceNoDeadline;
  return t.spaceValidUntil(_formatLadnaDate(context, validUntil));
}

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
          const SizedBox(height: 12),
          _LifeBalanceCard(blocks: blocks),
          const SizedBox(height: 16),
          _SectionLabel(t.spaces),
          const _SpacesProfileCard(),
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


class _LifeBalanceCard extends StatefulWidget {
  const _LifeBalanceCard({required this.blocks});

  final List<String> blocks;

  @override
  State<_LifeBalanceCard> createState() => _LifeBalanceCardState();
}

class _LifeBalanceCardState extends State<_LifeBalanceCard> {
  bool _loading = true;
  bool _saving = false;
  Map<String, double> _values = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _LifeBalanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.blocks.join('|') != widget.blocks.join('|')) {
      _load();
    }
  }

  String _normalize(String key) {
    final k = key.trim().toLowerCase();
    switch (k) {
      case 'health':
      case 'здоровье':
        return 'health';
      case 'career':
      case 'work':
      case 'карьера':
        return 'career';
      case 'family':
      case 'семья':
        return 'family';
      case 'relations':
      case 'relationship':
      case 'relationships':
      case 'отношения':
        return 'relations';
      case 'education':
      case 'study':
      case 'образование':
      case 'обучение':
        return 'education';
      case 'finance':
      case 'finances':
      case 'финансы':
        return 'finance';
      case 'hobby':
      case 'hobbies':
      case 'хобби':
        return 'hobby';
      case 'spirituality':
      case 'spirit':
      case 'духовность':
        return 'spirituality';
      default:
        return k;
    }
  }

  double get _total => _values.values.fold<double>(0, (sum, v) => sum + v);

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      final normalizedBlocks = widget.blocks.map(_normalize).toList();
      final next = <String, double>{for (final b in normalizedBlocks) b: 0};

      if (userId != null && userId.trim().isNotEmpty) {
        final row = await client
            .from('users')
            .select('priorities, weights')
            .eq('id', userId)
            .maybeSingle();

        final priorities = (row?['priorities'] as List?) ?? const [];
        final weights = (row?['weights'] as List?) ?? const [];
        for (var i = 0; i < priorities.length && i < weights.length; i++) {
          final key = _normalize(priorities[i].toString());
          if (!next.containsKey(key)) continue;
          final raw = weights[i];
          final value = raw is num ? raw.toDouble() : double.tryParse(raw.toString()) ?? 0.0;
          next[key] = (value <= 1.0 ? value * 100 : value).clamp(0.0, 100.0).toDouble();
        }
      }

      if (next.values.every((v) => v <= 0) && next.isNotEmpty) {
        final equal = (100 / next.length).floorToDouble();
        var rest = 100.0;
        final keys = next.keys.toList();
        for (var i = 0; i < keys.length; i++) {
          final value = i == keys.length - 1 ? rest : equal;
          next[keys[i]] = value;
          rest -= value;
        }
      }

      if (!mounted) return;
      setState(() => _values = next);
    } catch (e) {
      if (mounted) _snack(context, 'Не удалось загрузить баланс сфер: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setBlockValue(String block, double value) {
    final current = _values[block] ?? 0;
    final otherTotal = _total - current;
    final maxAllowed = (100 - otherTotal).clamp(0.0, 100.0).toDouble();
    final safe = value.clamp(0.0, maxAllowed).roundToDouble();
    setState(() => _values = {..._values, block: safe});
  }

  Future<void> _save() async {
    if (_saving) return;
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null || userId.trim().isEmpty) {
      _snack(context, 'Пользователь не авторизован.');
      return;
    }

    setState(() => _saving = true);
    try {
      await client.from('users').update({
        'priorities': _values.keys.toList(),
        'weights': _values.values.map((v) => v.round()).toList(),
      }).eq('id', userId);
      if (!mounted) return;
      _snack(context, 'Баланс сфер сохранён.');
    } catch (e) {
      if (mounted) _snack(context, 'Не удалось сохранить баланс сфер: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }


  Future<void> _editBlockPercent(String block) async {
    final label = ProfileUi.blockLabel(context, block);
    final current = (_values[block] ?? 0).round();
    final otherTotal = _total - (_values[block] ?? 0);
    final maxAllowed = (100 - otherTotal).clamp(0.0, 100.0).round();
    final ctrl = TextEditingController(text: '$current');

    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final t = _LadnaText.of(ctx);
        return NestSheet(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16 + MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _lifeBlockAccent(block),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        style: _LadnaTextStyle.serifTitle.copyWith(fontSize: 21),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  t.lifeWheelPercentLimit(maxAllowed),
                  style: _ladnaBodyMuted(ctx),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(
                    color: _ladnaText(ctx),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                  decoration: InputDecoration(
                    labelText: t.percent,
                    suffixText: '%',
                    prefixIcon: const Icon(Icons.donut_large_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 46,
                  child: FilledButton.icon(
                    onPressed: () {
                      final parsed = int.tryParse(ctrl.text.trim());
                      if (parsed == null) return;
                      Navigator.pop(ctx, parsed.clamp(0, maxAllowed));
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: Text(t.save),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == null) return;
    _setBlockValue(block, result.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final t = _LadnaText.of(context);
    final entries = _values.entries.toList();

    return _BaseCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(t.desiredBalance, style: _ladnaCardTitle(context))),
              Text(
                '${_total.round()}%',
                style: TextStyle(
                  color: _total == 100 ? _LadnaColors.lime : _ladnaMuted(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(t.desiredBalanceHint, style: _ladnaSmallMuted(context)),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else if (entries.isEmpty)
            Text(t.noData, style: _ladnaBodyMuted(context))
          else ...[
            const SizedBox(height: 4),
            _LifeBalanceWheel(
              values: _values,
              onTapBlock: _editBlockPercent,
            ),
            const SizedBox(height: 14),
            Text(
              t.lifeWheelTapHint,
              style: _ladnaSmallMuted(context),
            ),
            const SizedBox(height: 10),
            for (final e in entries) ...[
              _LifeBalanceRow(
                block: e.key,
                value: e.value,
                label: ProfileUi.blockLabel(context, e.key),
                onTap: () => _editBlockPercent(e.key),
              ),
              if (e.key != entries.last.key) const SizedBox(height: 8),
            ],
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator.adaptive(strokeWidth: 2))
                    : const Icon(Icons.check_rounded, size: 18),
                label: Text(_saving ? t.saving : t.save),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


class _LifeBalanceWheel extends StatelessWidget {
  const _LifeBalanceWheel({
    required this.values,
    required this.onTapBlock,
  });

  final Map<String, double> values;
  final ValueChanged<String> onTapBlock;

  @override
  Widget build(BuildContext context) {
    final t = _LadnaText.of(context);
    final total = values.values.fold<double>(0, (sum, v) => sum + v);
    final entries = values.entries.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, 260.0);
        return Center(
          child: GestureDetector(
            onTapDown: (details) {
              final block = _hitTestWheel(
                details.localPosition,
                Size(size, size),
                entries,
                total,
              );
              if (block != null) onTapBlock(block);
            },
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(size, size),
                    painter: _LifeBalanceWheelPainter(
                      values: values,
                      background: _ladnaIsDark(context)
                          ? const Color(0xFF2A2142)
                          : const Color(0xFFEAE6F5),
                    ),
                  ),
                  Container(
                    width: size * 0.48,
                    height: size * 0.48,
                    decoration: BoxDecoration(
                      color: _ladnaCardSurface(context),
                      shape: BoxShape.circle,
                      border: Border.all(color: _ladnaBorder(context)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(_ladnaIsDark(context) ? 0.24 : 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${total.round()}%',
                          style: TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 32,
                            height: 1,
                            fontWeight: FontWeight.w700,
                            color: total.round() == 100 ? _LadnaColors.lime : _ladnaText(context),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          t.outOfHundredPercent,
                          style: TextStyle(
                            color: _ladnaMuted(context),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String? _hitTestWheel(
    Offset local,
    Size size,
    List<MapEntry<String, double>> entries,
    double total,
  ) {
    if (entries.isEmpty || total <= 0) return null;
    final center = Offset(size.width / 2, size.height / 2);
    final vector = local - center;
    final distance = vector.distance;
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.30;
    if (distance < innerRadius || distance > outerRadius) return null;

    var angle = math.atan2(vector.dy, vector.dx) + math.pi / 2;
    if (angle < 0) angle += math.pi * 2;

    var start = 0.0;
    for (final e in entries) {
      final sweep = (e.value <= 0 ? 0 : e.value / total) * math.pi * 2;
      if (angle >= start && angle <= start + sweep) return e.key;
      start += sweep;
    }
    return entries.last.key;
  }
}

class _LifeBalanceWheelPainter extends CustomPainter {
  const _LifeBalanceWheelPainter({
    required this.values,
    required this.background,
  });

  final Map<String, double> values;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.30;
    final total = values.values.fold<double>(0, (sum, v) => sum + v);
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final bgPaint = Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    if (values.isEmpty || total <= 0) return;

    var start = -math.pi / 2;
    for (final e in values.entries) {
      final value = e.value.clamp(0.0, 100.0).toDouble();
      if (value <= 0) continue;
      final sweep = (value / total) * math.pi * 2;
      final paint = Paint()
        ..color = _lifeBlockAccent(e.key)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, start, math.max(0.01, sweep - 0.035), false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _LifeBalanceWheelPainter oldDelegate) {
    return oldDelegate.values.toString() != values.toString() ||
        oldDelegate.background != background;
  }
}

class _LifeBalanceRow extends StatelessWidget {
  const _LifeBalanceRow({
    required this.block,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String block;
  final String label;
  final double value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: _ladnaSoftSurface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _ladnaBorder(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _lifeBlockAccent(block),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _lifeBlockAccent(block).withOpacity(0.28),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: _ladnaRowTitle(context))),
            Text(
              '${value.round()}%',
              style: TextStyle(
                color: _ladnaText(context),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.edit_rounded, size: 17, color: _ladnaMuted(context)),
          ],
        ),
      ),
    );
  }
}

Color _lifeBlockAccent(String key) {
  // Palette is intentionally limited to colors used in the Ladna mockups:
  // #6B54C0, #D4E040, #16B8A8, #555268, #9090A8, #EAE6F5, #160E38.
  const palette = <Color>[
    _LadnaColors.primary,
    _LadnaColors.lime,
    _LadnaColors.teal,
    _LadnaColors.muted,
    _LadnaColors.text,
    _LadnaColors.card,
  ];

  switch (key) {
    case 'career':
      return _LadnaColors.lime;
    case 'health':
      return _LadnaColors.teal;
    case 'hobby':
    case 'hobbies':
      return _LadnaColors.primary;
    case 'family':
      return _LadnaColors.muted;
    case 'education':
      return _LadnaColors.primary;
    case 'relations':
    case 'relationships':
      return _LadnaColors.teal;
    case 'finance':
    case 'finances':
      return _LadnaColors.lime;
    case 'spirituality':
      return _LadnaColors.text;
    default:
      final index = key.codeUnits.fold<int>(0, (sum, code) => sum + code) % palette.length;
      return palette[index];
  }
}

class _HabitsPreviewCard extends StatelessWidget {
  const _HabitsPreviewCard();

  Future<(String title, bool isNegative)?> _openHabitEditor(BuildContext context, {dynamic existing}) async {
    final t = _LadnaText.of(context);
    final titleCtrl = TextEditingController(text: existing == null ? '' : (existing.title ?? '').toString());
    var isNegative = existing == null ? false : ((existing.isNegative as bool?) ?? false);

    final result = await showModalBottomSheet<(String, bool)>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NestSheet(
        child: StatefulBuilder(
          builder: (ctx, setLocal) => Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 14,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  existing == null ? t.newHabit : t.editHabit,
                  style: _LadnaTextStyle.serifTitle.copyWith(fontSize: 20, color: _ladnaText(ctx)),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: titleCtrl,
                  maxLength: 60,
                  decoration: InputDecoration(labelText: t.habitName, counterText: ''),
                ),
                const SizedBox(height: 10),
                _BaseCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Icon(isNegative ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded, size: 18, color: _LadnaColors.primary),
                      const SizedBox(width: 10),
                      Expanded(child: Text(t.negativeHabit, style: _ladnaRowTitle(ctx))),
                      Switch(value: isNegative, onChanged: (v) => setLocal(() => isNegative = v)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          final value = titleCtrl.text.trim();
                          if (value.isEmpty) return;
                          Navigator.pop(ctx, (value, isNegative));
                        },
                        child: Text(t.save),
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
    titleCtrl.dispose();
    return result;
  }

  Future<bool> _confirmDelete(BuildContext context, dynamic habit) async {
    final t = _LadnaText.of(context);
    final ok = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NestSheet(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.deleteHabit, style: _LadnaTextStyle.serifTitle.copyWith(fontSize: 20, color: _ladnaText(ctx))),
              const SizedBox(height: 10),
              Text(t.deleteHabitQuestion((habit.title ?? '').toString()), style: _ladnaBodyMuted(ctx)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.cancel))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error, foregroundColor: Colors.white),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(t.delete),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return ok == true;
  }

  Future<void> _saveHabit(BuildContext context, {dynamic existing}) async {
    final result = await _openHabitEditor(context, existing: existing);
    if (result == null) return;

    final habits = context.read<HabitsModel>();
    String? err;
    if (existing == null) {
      err = await habits.create(title: result.$1, isNegative: result.$2);
    } else {
      err = await habits.update((existing.id ?? '').toString(), title: result.$1, isNegative: result.$2);
    }
    if (err != null && context.mounted) _snack(context, err);
  }

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
              Expanded(child: Text(t.myHabits, style: _ladnaCardTitle(context))),
              _SmallSquareButton(icon: Icons.add_rounded, onTap: () => _saveHabit(context)),
            ],
          ),
          const SizedBox(height: 10),
          if (habits.loading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else if (habits.items.isEmpty)
            Text(t.noHabitsYet, style: _ladnaBodyMuted(context))
          else
            ...habits.items.asMap().entries.map((entry) {
              final idx = entry.key;
              final h = entry.value;
              return _HabitManageRow(
                title: (h.title).toString(),
                streak: t.daysCount(_safeStreak(h)),
                color: _habitColor(idx),
                isNegative: (h.isNegative as bool?) ?? false,
                onEdit: () => _saveHabit(context, existing: h),
                onDelete: () async {
                  final ok = await _confirmDelete(context, h);
                  if (!ok || !context.mounted) return;
                  final err = await context.read<HabitsModel>().delete((h.id).toString());
                  if (err != null && context.mounted) _snack(context, err);
                },
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

class _SpacesProfileCard extends StatefulWidget {
  const _SpacesProfileCard();

  @override
  State<_SpacesProfileCard> createState() => _SpacesProfileCardState();
}

class _SpacesProfileCardState extends State<_SpacesProfileCard> {
  bool _loading = true;
  List<LadnaSpace> _spaces = const [];
  List<SpaceInvite> _invites = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final results = await Future.wait<dynamic>([
        dbRepo.listSpaces(),
        dbRepo.listIncomingSpaceInvites(),
      ]);
      if (!mounted) return;
      setState(() {
        _spaces = (results[0] as List<LadnaSpace>);
        _invites = (results[1] as List<SpaceInvite>);
      });
    } catch (e) {
      if (mounted) _snack(context, '${_LadnaText.of(context).spacesLoadFailed}: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createSpace() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _SpaceEditorSheet(),
    );
    if (changed == true) await _load();
  }

  Future<void> _openSpace(LadnaSpace space) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SpaceDetailsSheet(space: space),
    );
    if (changed == true) await _load();
  }

  Future<void> _acceptInvite(SpaceInvite invite) async {
    try {
      await dbRepo.acceptSpaceInvite(invite.id);
      await _load();
      if (mounted) _snack(context, _LadnaText.of(context).spaceInviteAccepted);
    } catch (e) {
      if (mounted) _snack(context, '${_LadnaText.of(context).spaceInviteAcceptFailed}: $e');
    }
  }

  Future<void> _declineInvite(SpaceInvite invite) async {
    try {
      await dbRepo.declineSpaceInvite(invite.id);
      await _load();
    } catch (e) {
      if (mounted) _snack(context, '${_LadnaText.of(context).spaceInviteDeclineFailed}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _LadnaText.of(context);

    return _BaseCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(t.mySpaces, style: _ladnaCardTitle(context))),
              _SmallSquareButton(icon: Icons.add_rounded, onTap: _createSpace),
            ],
          ),
          const SizedBox(height: 4),
          Text(t.spacesHint, style: _ladnaSmallMuted(context)),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else ...[
            if (_invites.isNotEmpty) ...[
              Text(t.incomingInvites, style: _ladnaRowTitle(context)),
              const SizedBox(height: 8),
              for (final invite in _invites) ...[
                _SpaceInviteRow(
                  invite: invite,
                  onAccept: () => _acceptInvite(invite),
                  onDecline: () => _declineInvite(invite),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 6),
              const _CardDivider(),
              const SizedBox(height: 10),
            ],
            if (_spaces.isEmpty)
              _SpacesEmptyState(onCreate: _createSpace)
            else
              for (var i = 0; i < _spaces.length; i++) ...[
                _SpaceRow(space: _spaces[i], onTap: () => _openSpace(_spaces[i])),
                if (i != _spaces.length - 1) const _CardDivider(),
              ],
          ],
        ],
      ),
    );
  }
}

class _SpacesEmptyState extends StatelessWidget {
  const _SpacesEmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final t = _LadnaText.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _ladnaSoftSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ladnaBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _IconBox(icon: Icons.group_work_outlined, background: _LadnaColors.primarySoft),
              const SizedBox(width: 10),
              Expanded(child: Text(t.noSpacesYet, style: _ladnaRowTitle(context))),
            ],
          ),
          const SizedBox(height: 6),
          Text(t.noSpacesHint, style: _ladnaSmallMuted(context)),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(t.createSpace),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpaceRow extends StatelessWidget {
  const _SpaceRow({required this.space, required this.onTap});

  final LadnaSpace space;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = _LadnaText.of(context);
    final description = (space.description ?? '').trim();
    final validity = _spaceValidityLabel(context, space);
    final subtitle = description.isEmpty ? validity : '$description · $validity';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            _SpaceAvatar(icon: space.icon, color: _spaceColorFromHex(space.color)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(space.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: _ladnaRowTitle(context)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _ladnaRowSubtitle(context),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: _ladnaMuted(context)),
          ],
        ),
      ),
    );
  }
}

class _SpaceInviteRow extends StatelessWidget {
  const _SpaceInviteRow({
    required this.invite,
    required this.onAccept,
    required this.onDecline,
  });

  final SpaceInvite invite;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final t = _LadnaText.of(context);
    final space = invite.space;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _ladnaSoftSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ladnaBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _SpaceAvatar(icon: space?.icon ?? '👥', color: _spaceColorFromHex(space?.color)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(space?.name ?? t.space, style: _ladnaRowTitle(context)),
                    const SizedBox(height: 2),
                    Text(t.spaceInviteSubtitle, style: _ladnaRowSubtitle(context)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  child: Text(t.declineInvite),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onAccept,
                  child: Text(t.acceptInvite),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpaceDetailsSheet extends StatefulWidget {
  const _SpaceDetailsSheet({required this.space});

  final LadnaSpace space;

  @override
  State<_SpaceDetailsSheet> createState() => _SpaceDetailsSheetState();
}

class _SpaceDetailsSheetState extends State<_SpaceDetailsSheet> {
  bool _loading = true;
  bool _busy = false;
  List<SpaceMember> _members = const [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  bool get _isOwner {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    return uid != null && uid == widget.space.ownerId;
  }

  Future<void> _loadMembers() async {
    if (mounted) setState(() => _loading = true);
    try {
      final members = await dbRepo.listSpaceMembers(widget.space.id);
      if (!mounted) return;
      setState(() => _members = members);
    } catch (e) {
      if (mounted) _snack(context, '${_LadnaText.of(context).spaceMembersLoadFailed}: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _invite() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SpaceInviteSheet(space: widget.space),
    );
    if (changed == true) await _loadMembers();
  }

  Future<void> _edit() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SpaceEditorSheet(space: widget.space),
    );
    if (changed == true && mounted) Navigator.pop(context, true);
  }

  Future<void> _deleteOrLeave() async {
    final t = _LadnaText.of(context);
    final ok = await _confirmSheet(
      context,
      title: _isOwner ? t.deleteSpace : t.leaveSpace,
      body: _isOwner ? t.deleteSpaceConfirm : t.leaveSpaceConfirm,
      confirmLabel: _isOwner ? t.delete : t.leaveSpace,
      destructive: _isOwner,
    );
    if (ok != true) return;

    setState(() => _busy = true);
    try {
      if (_isOwner) {
        await dbRepo.deleteSpace(widget.space.id);
      } else {
        await dbRepo.leaveSpace(widget.space.id);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _snack(context, '${t.spaceActionFailed}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _LadnaText.of(context);

    return NestSheet(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + MediaQuery.of(context).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _SpaceAvatar(icon: widget.space.icon, color: _spaceColorFromHex(widget.space.color), size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.space.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: _LadnaTextStyle.serifTitle.copyWith(fontSize: 21, color: _ladnaText(context))),
                      const SizedBox(height: 2),
                      Text('${t.spaceManageSubtitle} · ${_spaceValidityLabel(context, widget.space)}', style: _ladnaSmallMuted(context)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context, false),
                  icon: Icon(Icons.close_rounded, color: _ladnaMuted(context)),
                ),
              ],
            ),
            if ((widget.space.description ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(widget.space.description!.trim(), style: _ladnaBodyMuted(context).copyWith(height: 1.35)),
            ],
            const SizedBox(height: 16),
            Text(t.members, style: _ladnaRowTitle(context)),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator.adaptive()),
              )
            else if (_members.isEmpty)
              Text(t.noMembersYet, style: _ladnaBodyMuted(context))
            else
              _BaseCard(
                child: Column(
                  children: [
                    for (var i = 0; i < _members.length; i++) ...[
                      _SpaceMemberRow(member: _members[i]),
                      if (i != _members.length - 1) const _CardDivider(),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _edit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(t.edit),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _invite,
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    label: Text(t.inviteMember),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _busy ? null : _deleteOrLeave,
              icon: Icon(_isOwner ? Icons.delete_outline_rounded : Icons.logout_rounded, size: 18),
              label: Text(_isOwner ? t.deleteSpace : t.leaveSpace),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpaceMemberRow extends StatelessWidget {
  const _SpaceMemberRow({required this.member});

  final SpaceMember member;

  @override
  Widget build(BuildContext context) {
    final t = _LadnaText.of(context);
    final currentUid = Supabase.instance.client.auth.currentUser?.id;
    final isCurrentUser = currentUid != null && currentUid == member.userId;
    final title = isCurrentUser
        ? t.you
        : ((member.name ?? member.email)?.trim().isNotEmpty == true
            ? (member.name ?? member.email)!.trim()
            : _shortUserId(member.userId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          _IconBox(icon: Icons.person_outline_rounded, background: _LadnaColors.primarySoft),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: _ladnaRowTitle(context)),
                const SizedBox(height: 2),
                Text(_spaceRoleLabel(context, member.role), style: _ladnaRowSubtitle(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpaceEditorSheet extends StatefulWidget {
  const _SpaceEditorSheet({this.space});

  final LadnaSpace? space;

  @override
  State<_SpaceEditorSheet> createState() => _SpaceEditorSheetState();
}

class _SpaceEditorSheetState extends State<_SpaceEditorSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _iconCtrl;
  late final TextEditingController _colorCtrl;
  DateTime? _validUntil;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final space = widget.space;
    _nameCtrl = TextEditingController(text: space?.name ?? '');
    _descriptionCtrl = TextEditingController(text: space?.description ?? '');
    _iconCtrl = TextEditingController(text: space?.icon ?? '🏠');
    _colorCtrl = TextEditingController(text: space?.color ?? '#6B54C0');
    _validUntil = space?.validUntil == null ? null : DateUtils.dateOnly(space!.validUntil!);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _iconCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickValidUntil() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final initial = _validUntil == null || _validUntil!.isBefore(today)
        ? today.add(const Duration(days: 30))
        : _validUntil!;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: DateTime(today.year + 10, 12, 31),
    );

    if (picked == null || !mounted) return;
    setState(() => _validUntil = DateUtils.dateOnly(picked));
  }

  Future<void> _save() async {
    final t = _LadnaText.of(context);
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _snack(context, t.spaceNameRequired);
      return;
    }

    setState(() => _saving = true);
    try {
      final space = widget.space;
      if (space == null) {
        await dbRepo.createSpace(
          name: name,
          description: _descriptionCtrl.text.trim(),
          icon: _iconCtrl.text.trim().isEmpty ? '🏠' : _iconCtrl.text.trim(),
          color: _colorCtrl.text.trim(),
          validUntil: _validUntil,
        );
      } else {
        await dbRepo.updateSpace(
          spaceId: space.id,
          name: name,
          description: _descriptionCtrl.text.trim(),
          icon: _iconCtrl.text.trim().isEmpty ? '🏠' : _iconCtrl.text.trim(),
          color: _colorCtrl.text.trim(),
          validUntil: _validUntil,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _snack(context, '${t.spaceSaveFailed}: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _LadnaText.of(context);
    final isEdit = widget.space != null;
    final validUntil = _validUntil;
    final validityText = validUntil == null
        ? t.spaceNoDeadline
        : t.spaceValidUntil(_formatLadnaDate(context, validUntil));

    return NestSheet(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEdit ? t.editSpace : t.createSpace,
                style: _LadnaTextStyle.serifTitle.copyWith(fontSize: 21, color: _ladnaText(context)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _nameCtrl,
                maxLength: 40,
                decoration: InputDecoration(labelText: t.spaceName, counterText: ''),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionCtrl,
                maxLength: 120,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(labelText: t.spaceDescription, counterText: ''),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _iconCtrl,
                      maxLength: 2,
                      decoration: InputDecoration(labelText: t.spaceIcon, counterText: ''),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _colorCtrl,
                      decoration: InputDecoration(labelText: t.spaceColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _BaseCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _IconBox(
                          icon: Icons.event_available_rounded,
                          background: _LadnaColors.primarySoft,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.spaceValidity, style: _ladnaRowTitle(context)),
                              const SizedBox(height: 2),
                              Text(validityText, style: _ladnaRowSubtitle(context)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _saving ? null : _pickValidUntil,
                            icon: const Icon(Icons.calendar_month_rounded, size: 18),
                            label: Text(validUntil == null ? t.setDeadline : t.changeDeadline),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (validUntil != null)
                          Expanded(
                            child: TextButton.icon(
                              onPressed: _saving ? null : () => setState(() => _validUntil = null),
                              icon: const Icon(Icons.all_inclusive_rounded, size: 18),
                              label: Text(t.noDeadline),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(t.spaceValidityHint, style: _ladnaSmallMuted(context)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: _saving ? null : () => Navigator.pop(context, false), child: Text(t.cancel))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator.adaptive(strokeWidth: 2))
                          : const Icon(Icons.check_rounded, size: 18),
                      label: Text(_saving ? t.saving : t.save),
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
}

class _SpaceInviteSheet extends StatefulWidget {
  const _SpaceInviteSheet({required this.space});

  final LadnaSpace space;

  @override
  State<_SpaceInviteSheet> createState() => _SpaceInviteSheetState();
}

class _SpaceInviteSheetState extends State<_SpaceInviteSheet> {
  final _emailCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final t = _LadnaText.of(context);
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _snack(context, t.enterValidEmail);
      return;
    }

    setState(() => _sending = true);
    try {
      await dbRepo.inviteUserToSpace(spaceId: widget.space.id, email: email);
      if (mounted) {
        _snack(context, t.spaceInviteSent);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) _snack(context, '${t.spaceInviteSendFailed}: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _LadnaText.of(context);

    return NestSheet(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.inviteMember, style: _LadnaTextStyle.serifTitle.copyWith(fontSize: 21, color: _ladnaText(context))),
            const SizedBox(height: 6),
            Text(t.inviteMemberHint(widget.space.name), style: _ladnaBodyMuted(context)),
            const SizedBox(height: 14),
            TextField(
              controller: _emailCtrl,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: t.email),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: _sending ? null : () => Navigator.pop(context, false), child: Text(t.cancel))),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator.adaptive(strokeWidth: 2))
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(_sending ? t.saving : t.sendInvite),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpaceAvatar extends StatelessWidget {
  const _SpaceAvatar({required this.icon, required this.color, this.size = 36});

  final String icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(_ladnaIsDark(context) ? 0.26 : 0.14),
        borderRadius: BorderRadius.circular(size * 0.30),
        border: Border.all(color: color.withOpacity(_ladnaIsDark(context) ? 0.42 : 0.22)),
      ),
      child: Text(
        icon.trim().isEmpty ? '🏠' : icon.trim(),
        style: TextStyle(fontSize: size * 0.48),
      ),
    );
  }
}

Color _spaceColorFromHex(String? raw) {
  final value = (raw ?? '').trim();
  if (value.isEmpty) return _LadnaColors.primary;
  final normalized = value.replaceAll('#', '').toUpperCase();
  if (!RegExp(r'^[0-9A-F]{6}$').hasMatch(normalized)) return _LadnaColors.primary;
  return Color(int.parse('FF$normalized', radix: 16));
}

String _shortUserId(String id) {
  if (id.length <= 8) return id;
  return '${id.substring(0, 4)}…${id.substring(id.length - 4)}';
}

String _spaceRoleLabel(BuildContext context, String role) {
  final t = _LadnaText.of(context);
  switch (role) {
    case 'owner':
      return t.spaceRoleOwner;
    case 'admin':
      return t.spaceRoleAdmin;
    case 'viewer':
      return t.spaceRoleViewer;
    default:
      return t.spaceRoleMember;
  }
}

class _HabitManageRow extends StatelessWidget {
  const _HabitManageRow({
    required this.title,
    required this.streak,
    required this.color,
    required this.isNegative,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String streak;
  final Color color;
  final bool isNegative;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = _LadnaText.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _ladnaDivider(context)))),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: _ladnaText(context), fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(isNegative ? '${t.negativeHabit} · $streak' : streak, style: _ladnaSmallMuted(context)),
              ],
            ),
          ),
          IconButton(visualDensity: VisualDensity.compact, onPressed: onEdit, icon: Icon(Icons.edit_outlined, size: 18, color: _ladnaMuted(context))),
          IconButton(visualDensity: VisualDensity.compact, onPressed: onDelete, icon: Icon(Icons.delete_outline_rounded, size: 18, color: Theme.of(context).colorScheme.error)),
        ],
      ),
    );
  }
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
    final t = _LadnaText.of(context);

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
  String get desiredBalance => pick({'ru': 'Колесо жизни', 'en': 'Life wheel', 'de': 'Lebensrad', 'fr': 'Roue de vie', 'es': 'Rueda de vida', 'tr': 'Yaşam çarkı'});
  String get desiredBalanceHint => pick({
        'ru': 'Настрой колесо жизни по выбранным сферам. Общая сумма не может быть больше 100%.',
        'en': 'Set up your life wheel for the selected areas. Total cannot exceed 100%.',
        'de': 'Richte dein Lebensrad für die ausgewählten Bereiche ein. Die Summe darf 100 % nicht überschreiten.',
        'fr': 'Configure ta roue de vie selon les domaines choisis. Le total ne peut pas dépasser 100 %.',
        'es': 'Configura tu rueda de vida por áreas seleccionadas. El total no puede superar el 100 %.',
        'tr': 'Seçili alanlara göre yaşam çarkını ayarla. Toplam %100’ü geçemez.',
      });
  String get lifeWheelTapHint => pick({
        'ru': 'Нажми на сектор или сферу ниже, чтобы задать точный процент.',
        'en': 'Tap a segment or an area below to set an exact percentage.',
        'de': 'Tippe auf ein Segment oder einen Bereich unten, um den genauen Prozentwert festzulegen.',
        'fr': 'Touche un segment ou un domaine ci-dessous pour définir un pourcentage exact.',
        'es': 'Toca un segmento o un área abajo para definir un porcentaje exacto.',
        'tr': 'Kesin yüzdeyi belirlemek için bir segmente veya aşağıdaki alana dokun.',
      });
  String get outOfHundredPercent => pick({
        'ru': 'из 100%',
        'en': 'of 100%',
        'de': 'von 100 %',
        'fr': 'sur 100 %',
        'es': 'de 100 %',
        'tr': '%100 üzerinden',
      });
  String get percent => pick({
        'ru': 'Процент',
        'en': 'Percentage',
        'de': 'Prozent',
        'fr': 'Pourcentage',
        'es': 'Porcentaje',
        'tr': 'Yüzde',
      });
  String lifeWheelPercentLimit(int maxAllowed) => pick({
        'ru': 'Можно указать от 0 до $maxAllowed%. Общая сумма баланса не может превышать 100%.',
        'en': 'You can enter 0 to $maxAllowed%. The total balance cannot exceed 100%.',
        'de': 'Du kannst 0 bis $maxAllowed % eingeben. Die Gesamtsumme darf 100 % nicht überschreiten.',
        'fr': 'Tu peux saisir de 0 à $maxAllowed %. Le total ne peut pas dépasser 100 %.',
        'es': 'Puedes indicar de 0 a $maxAllowed %. El total no puede superar el 100 %.',
        'tr': '0 ile $maxAllowed% arasında değer girebilirsin. Toplam denge %100’ü geçemez.',
      });
  String get save => pick({'ru': 'Сохранить', 'en': 'Save', 'de': 'Speichern', 'fr': 'Enregistrer', 'es': 'Guardar', 'tr': 'Kaydet'});
  String get saving => pick({'ru': 'Сохранение…', 'en': 'Saving…', 'de': 'Speichern…', 'fr': 'Enregistrement…', 'es': 'Guardando…', 'tr': 'Kaydediliyor…'});
  String get newHabit => pick({'ru': 'Новая привычка', 'en': 'New habit', 'de': 'Neue Gewohnheit', 'fr': 'Nouvelle habitude', 'es': 'Nuevo hábito', 'tr': 'Yeni alışkanlık'});
  String get editHabit => pick({'ru': 'Редактировать привычку', 'en': 'Edit habit', 'de': 'Gewohnheit bearbeiten', 'fr': 'Modifier l’habitude', 'es': 'Editar hábito', 'tr': 'Alışkanlığı düzenle'});
  String get habitName => pick({'ru': 'Название привычки', 'en': 'Habit name', 'de': 'Name der Gewohnheit', 'fr': 'Nom de l’habitude', 'es': 'Nombre del hábito', 'tr': 'Alışkanlık adı'});
  String get negativeHabit => pick({'ru': 'Анти-привычка', 'en': 'Negative habit', 'de': 'Negative Gewohnheit', 'fr': 'Habitude négative', 'es': 'Hábito negativo', 'tr': 'Negatif alışkanlık'});
  String get deleteHabit => pick({'ru': 'Удалить привычку?', 'en': 'Delete habit?', 'de': 'Gewohnheit löschen?', 'fr': 'Supprimer l’habitude ?', 'es': '¿Eliminar hábito?', 'tr': 'Alışkanlık silinsin mi?'});
  String deleteHabitQuestion(String title) => pick({'ru': 'Привычка "$title" будет удалена.', 'en': 'Habit "$title" will be deleted.', 'de': 'Die Gewohnheit "$title" wird gelöscht.', 'fr': 'L’habitude "$title" sera supprimée.', 'es': 'El hábito "$title" se eliminará.', 'tr': '"$title" alışkanlığı silinecek.'});
  String get delete => pick({'ru': 'Удалить', 'en': 'Delete', 'de': 'Löschen', 'fr': 'Supprimer', 'es': 'Eliminar', 'tr': 'Sil'});
  String get spaces => pick({'ru': 'Пространства', 'en': 'Spaces', 'de': 'Bereiche', 'fr': 'Espaces', 'es': 'Espacios', 'tr': 'Alanlar'});
  String get space => pick({'ru': 'Пространство', 'en': 'Space', 'de': 'Bereich', 'fr': 'Espace', 'es': 'Espacio', 'tr': 'Alan'});
  String get mySpaces => pick({'ru': 'Мои пространства', 'en': 'My spaces', 'de': 'Meine Bereiche', 'fr': 'Mes espaces', 'es': 'Mis espacios', 'tr': 'Alanlarım'});
  String get spacesHint => pick({
        'ru': 'Создавай общие пространства для дома, семьи, поездок и проектов.',
        'en': 'Create shared spaces for home, family, trips, and projects.',
        'de': 'Erstelle gemeinsame Bereiche für Zuhause, Familie, Reisen und Projekte.',
        'fr': 'Crée des espaces partagés pour la maison, la famille, les voyages et les projets.',
        'es': 'Crea espacios compartidos para casa, familia, viajes y proyectos.',
        'tr': 'Ev, aile, seyahat ve projeler için ortak alanlar oluştur.',
      });
  String get noSpacesYet => pick({'ru': 'Пространств пока нет', 'en': 'No spaces yet', 'de': 'Noch keine Bereiche', 'fr': 'Aucun espace', 'es': 'Aún no hay espacios', 'tr': 'Henüz alan yok'});
  String get noSpacesHint => pick({
        'ru': 'Создай первое пространство и пригласи туда других пользователей.',
        'en': 'Create your first space and invite other users.',
        'de': 'Erstelle deinen ersten Bereich und lade andere Nutzer ein.',
        'fr': 'Crée ton premier espace et invite d’autres utilisateurs.',
        'es': 'Crea tu primer espacio e invita a otros usuarios.',
        'tr': 'İlk alanını oluştur ve diğer kullanıcıları davet et.',
      });
  String get createSpace => pick({'ru': 'Создать пространство', 'en': 'Create space', 'de': 'Bereich erstellen', 'fr': 'Créer un espace', 'es': 'Crear espacio', 'tr': 'Alan oluştur'});
  String get editSpace => pick({'ru': 'Редактировать пространство', 'en': 'Edit space', 'de': 'Bereich bearbeiten', 'fr': 'Modifier l’espace', 'es': 'Editar espacio', 'tr': 'Alanı düzenle'});
  String get deleteSpace => pick({'ru': 'Удалить пространство', 'en': 'Delete space', 'de': 'Bereich löschen', 'fr': 'Supprimer l’espace', 'es': 'Eliminar espacio', 'tr': 'Alanı sil'});
  String get leaveSpace => pick({'ru': 'Покинуть пространство', 'en': 'Leave space', 'de': 'Bereich verlassen', 'fr': 'Quitter l’espace', 'es': 'Salir del espacio', 'tr': 'Alandan ayrıl'});
  String get deleteSpaceConfirm => pick({
        'ru': 'Пространство и связанные с ним общие данные будут удалены. Это действие нельзя отменить.',
        'en': 'This space and its shared data will be deleted. This cannot be undone.',
        'de': 'Dieser Bereich und die gemeinsamen Daten werden gelöscht. Das kann nicht rückgängig gemacht werden.',
        'fr': 'Cet espace et ses données partagées seront supprimés. Cette action est irréversible.',
        'es': 'Este espacio y sus datos compartidos se eliminarán. Esta acción no se puede deshacer.',
        'tr': 'Bu alan ve paylaşılan verileri silinecek. Bu işlem geri alınamaz.',
      });
  String get leaveSpaceConfirm => pick({
        'ru': 'Ты больше не будешь видеть задачи и данные этого пространства.',
        'en': 'You will no longer see tasks and data from this space.',
        'de': 'Du wirst Aufgaben und Daten aus diesem Bereich nicht mehr sehen.',
        'fr': 'Tu ne verras plus les tâches et données de cet espace.',
        'es': 'Ya no verás tareas ni datos de este espacio.',
        'tr': 'Bu alandaki görevleri ve verileri artık görmeyeceksin.',
      });
  String get spaceName => pick({'ru': 'Название пространства', 'en': 'Space name', 'de': 'Name des Bereichs', 'fr': 'Nom de l’espace', 'es': 'Nombre del espacio', 'tr': 'Alan adı'});
  String get spaceNameRequired => pick({'ru': 'Введите название пространства', 'en': 'Enter a space name', 'de': 'Gib einen Namen ein', 'fr': 'Saisis un nom', 'es': 'Introduce un nombre', 'tr': 'Bir alan adı gir'});
  String get spaceDescription => pick({'ru': 'Описание', 'en': 'Description', 'de': 'Beschreibung', 'fr': 'Description', 'es': 'Descripción', 'tr': 'Açıklama'});
  String get spaceIcon => pick({'ru': 'Иконка', 'en': 'Icon', 'de': 'Icon', 'fr': 'Icône', 'es': 'Icono', 'tr': 'Simge'});
  String get spaceColor => pick({'ru': 'Цвет HEX', 'en': 'HEX color', 'de': 'HEX-Farbe', 'fr': 'Couleur HEX', 'es': 'Color HEX', 'tr': 'HEX renk'});
  String get spaceValidity => pick({'ru': 'Срок действия', 'en': 'Validity', 'de': 'Gültigkeit', 'fr': 'Validité', 'es': 'Validez', 'tr': 'Geçerlilik'});
  String get noDeadline => pick({'ru': 'Бессрочно', 'en': 'No deadline', 'de': 'Unbefristet', 'fr': 'Sans limite', 'es': 'Sin fecha límite', 'tr': 'Süresiz'});
  String get spaceNoDeadline => pick({'ru': 'Бессрочное пространство', 'en': 'No expiration date', 'de': 'Unbefristeter Bereich', 'fr': 'Espace sans expiration', 'es': 'Espacio sin vencimiento', 'tr': 'Süresiz alan'});
  String get setDeadline => pick({'ru': 'Задать срок', 'en': 'Set date', 'de': 'Datum setzen', 'fr': 'Définir la date', 'es': 'Fijar fecha', 'tr': 'Tarih belirle'});
  String get changeDeadline => pick({'ru': 'Изменить срок', 'en': 'Change date', 'de': 'Datum ändern', 'fr': 'Modifier la date', 'es': 'Cambiar fecha', 'tr': 'Tarihi değiştir'});
  String spaceValidUntil(String date) => pick({'ru': 'Действует до $date', 'en': 'Valid until $date', 'de': 'Gültig bis $date', 'fr': 'Valide jusqu’au $date', 'es': 'Válido hasta $date', 'tr': '$date tarihine kadar geçerli'});
  String get spaceValidityHint => pick({
        'ru': 'После этой даты пространство останется в базе, но исчезнет с экранов и из выбора задач.',
        'en': 'After this date, the space stays in the database but disappears from screens and task selection.',
        'de': 'Nach diesem Datum bleibt der Bereich in der Datenbank, wird aber auf den Screens und in der Aufgabenauswahl ausgeblendet.',
        'fr': 'Après cette date, l’espace reste en base mais disparaît des écrans et du choix des tâches.',
        'es': 'Después de esta fecha, el espacio queda en la base, pero desaparece de las pantallas y de la selección de tareas.',
        'tr': 'Bu tarihten sonra alan veritabanında kalır, ancak ekranlardan ve görev seçiminden kaybolur.',
      });
  String get spaceTapToManage => pick({'ru': 'Нажми, чтобы управлять участниками', 'en': 'Tap to manage members', 'de': 'Tippen, um Mitglieder zu verwalten', 'fr': 'Toucher pour gérer les membres', 'es': 'Toca para gestionar miembros', 'tr': 'Üyeleri yönetmek için dokun'});
  String get spaceManageSubtitle => pick({'ru': 'Участники и приглашения', 'en': 'Members and invites', 'de': 'Mitglieder und Einladungen', 'fr': 'Membres et invitations', 'es': 'Miembros e invitaciones', 'tr': 'Üyeler ve davetler'});
  String get members => pick({'ru': 'Участники', 'en': 'Members', 'de': 'Mitglieder', 'fr': 'Membres', 'es': 'Miembros', 'tr': 'Üyeler'});
  String get noMembersYet => pick({'ru': 'Участников пока нет', 'en': 'No members yet', 'de': 'Noch keine Mitglieder', 'fr': 'Aucun membre', 'es': 'Aún no hay miembros', 'tr': 'Henüz üye yok'});
  String get inviteMember => pick({'ru': 'Пригласить', 'en': 'Invite', 'de': 'Einladen', 'fr': 'Inviter', 'es': 'Invitar', 'tr': 'Davet et'});
  String inviteMemberHint(String spaceName) => pick({
        'ru': 'Приглашение будет отправлено в пространство «$spaceName».',
        'en': 'The invite will be sent for “$spaceName”.',
        'de': 'Die Einladung wird für „$spaceName“ gesendet.',
        'fr': 'L’invitation sera envoyée pour « $spaceName ».',
        'es': 'La invitación se enviará para “$spaceName”.',
        'tr': 'Davet “$spaceName” alanı için gönderilecek.',
      });
  String get email => pick({'ru': 'Email', 'en': 'Email', 'de': 'E-Mail', 'fr': 'E-mail', 'es': 'Email', 'tr': 'E-posta'});
  String get sendInvite => pick({'ru': 'Отправить', 'en': 'Send', 'de': 'Senden', 'fr': 'Envoyer', 'es': 'Enviar', 'tr': 'Gönder'});
  String get enterValidEmail => pick({'ru': 'Введите корректный email', 'en': 'Enter a valid email', 'de': 'Gib eine gültige E-Mail ein', 'fr': 'Saisis un e-mail valide', 'es': 'Introduce un email válido', 'tr': 'Geçerli bir e-posta gir'});
  String get incomingInvites => pick({'ru': 'Входящие приглашения', 'en': 'Incoming invites', 'de': 'Eingehende Einladungen', 'fr': 'Invitations reçues', 'es': 'Invitaciones recibidas', 'tr': 'Gelen davetler'});
  String get spaceInviteSubtitle => pick({'ru': 'Вас пригласили в общее пространство', 'en': 'You were invited to a shared space', 'de': 'Du wurdest in einen gemeinsamen Bereich eingeladen', 'fr': 'Tu as été invité dans un espace partagé', 'es': 'Te invitaron a un espacio compartido', 'tr': 'Ortak bir alana davet edildin'});
  String get acceptInvite => pick({'ru': 'Принять', 'en': 'Accept', 'de': 'Annehmen', 'fr': 'Accepter', 'es': 'Aceptar', 'tr': 'Kabul et'});
  String get declineInvite => pick({'ru': 'Отклонить', 'en': 'Decline', 'de': 'Ablehnen', 'fr': 'Refuser', 'es': 'Rechazar', 'tr': 'Reddet'});
  String get spaceInviteAccepted => pick({'ru': 'Приглашение принято.', 'en': 'Invite accepted.', 'de': 'Einladung angenommen.', 'fr': 'Invitation acceptée.', 'es': 'Invitación aceptada.', 'tr': 'Davet kabul edildi.'});
  String get spaceInviteSent => pick({'ru': 'Приглашение отправлено.', 'en': 'Invite sent.', 'de': 'Einladung gesendet.', 'fr': 'Invitation envoyée.', 'es': 'Invitación enviada.', 'tr': 'Davet gönderildi.'});
  String get you => pick({'ru': 'Вы', 'en': 'You', 'de': 'Du', 'fr': 'Toi', 'es': 'Tú', 'tr': 'Sen'});
  String get spaceRoleOwner => pick({'ru': 'Владелец', 'en': 'Owner', 'de': 'Eigentümer', 'fr': 'Propriétaire', 'es': 'Propietario', 'tr': 'Sahip'});
  String get spaceRoleAdmin => pick({'ru': 'Администратор', 'en': 'Admin', 'de': 'Admin', 'fr': 'Admin', 'es': 'Admin', 'tr': 'Yönetici'});
  String get spaceRoleMember => pick({'ru': 'Участник', 'en': 'Member', 'de': 'Mitglied', 'fr': 'Membre', 'es': 'Miembro', 'tr': 'Üye'});
  String get spaceRoleViewer => pick({'ru': 'Только просмотр', 'en': 'Viewer', 'de': 'Nur Ansicht', 'fr': 'Lecture seule', 'es': 'Solo lectura', 'tr': 'Sadece görüntüleme'});
  String get spacesLoadFailed => pick({'ru': 'Не удалось загрузить пространства', 'en': 'Could not load spaces'});
  String get spaceMembersLoadFailed => pick({'ru': 'Не удалось загрузить участников', 'en': 'Could not load members'});
  String get spaceSaveFailed => pick({'ru': 'Не удалось сохранить пространство', 'en': 'Could not save space'});
  String get spaceActionFailed => pick({'ru': 'Не удалось выполнить действие', 'en': 'Could not complete the action'});
  String get spaceInviteSendFailed => pick({'ru': 'Не удалось отправить приглашение', 'en': 'Could not send invite'});
  String get spaceInviteAcceptFailed => pick({'ru': 'Не удалось принять приглашение', 'en': 'Could not accept invite'});
  String get spaceInviteDeclineFailed => pick({'ru': 'Не удалось отклонить приглашение', 'en': 'Could not decline invite'});
  String get noData => pick({'ru': 'Нет данных', 'en': 'No data', 'de': 'Keine Daten', 'fr': 'Aucune donnée', 'es': 'Sin datos', 'tr': 'Veri yok'});
}
