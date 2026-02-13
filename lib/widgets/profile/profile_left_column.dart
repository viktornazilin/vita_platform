// lib/screens/profile/profile_left_column.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../../models/profile_model.dart';
import 'profile_ui_helpers.dart';

// ✅ доступ к глобальному webNotifs
import '../../main.dart';

// Nest UI
import '../../widgets/nest/nest_card.dart';
import '../../widgets/nest/nest_section_title.dart'; // если файла нет — скажи, дам версию без него

class ProfileLeftColumn extends StatelessWidget {
  const ProfileLeftColumn({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final model = context.watch<ProfileModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ====== HERO CARD ======
        NestCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const _Avatar(),
              const SizedBox(height: 14),

              ProfileUi.editableRow(
                context: context,
                label: l.profileNameLabel,
                value: model.name?.isNotEmpty == true ? model.name! : l.commonDash,
                onEdit: () async {
                  final v = await ProfileUi.promptText(
                    context,
                    title: l.profileNameTitle,
                    label: l.profileNamePrompt,
                    initial: model.name ?? '',
                    maxLen: 40,
                  );
                  if (v == null) return;
                  final err = await model.setName(
                    v.trim().isEmpty ? null : v.trim(),
                  );
                  if (err != null && context.mounted) {
                    ProfileUi.snack(context, err);
                  }
                },
              ),

              ProfileUi.editableRow(
                context: context,
                label: l.profileAgeLabel,
                value: model.age?.toString() ?? l.commonDash,
                onEdit: () async {
                  final v = await ProfileUi.promptInt(
                    context,
                    title: l.profileAgeTitle,
                    label: l.profileAgePrompt,
                    initial: model.age,
                    min: 10,
                    max: 120,
                  );
                  final err = await model.setAge(v);
                  if (err != null && context.mounted) {
                    ProfileUi.snack(context, err);
                  }
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ====== ACCOUNT ======
        NestSectionTitle(l.profileAccountSection),
        const SizedBox(height: 10),

        NestCard(
          padding: EdgeInsets.zero,
          child: SwitchListTile(
            dense: true,
            title: Text(l.profileSeenPrologueTitle),
            subtitle: Text(l.profileSeenPrologueSubtitle),
            value: model.hasSeenIntro,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(22)),
            ),
            onChanged: (v) async {
              final err = await model.setHasSeenIntro(v);
              if (err != null && context.mounted) {
                ProfileUi.snack(context, err);
              }
            },
          ),
        ),

        const SizedBox(height: 16),

        // ====== TARGET HOURS ======
        NestSectionTitle(l.profileFocusSection),
        const SizedBox(height: 10),

        ProfileUi.editableRow(
          context: context,
          label: l.profileTargetHoursLabel,
          value: l.profileTargetHoursValue(model.targetHours.toStringAsFixed(1)),
          onEdit: () async {
            final v = await ProfileUi.promptDouble(
              context,
              title: l.profileTargetHoursTitle,
              label: l.profileTargetHoursFieldLabel,
              initial: model.targetHours,
              min: 1,
              max: 24,
              decimals: 1,
            );
            if (v == null) return;
            final err = await model.setTargetHours(v);
            if (err != null && context.mounted) {
              ProfileUi.snack(context, err);
            }
          },
        ),

        const SizedBox(height: 16),

        // ====== WEB NOTIFICATIONS ======
        const _WebNotificationsSection(),
      ],
    );
  }
}

class _WebNotificationsSection extends StatelessWidget {
  const _WebNotificationsSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    // Если не web/не поддерживается — показываем аккуратную плашку
    if (!webNotifs.isSupported) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NestSectionTitle(l.profileWebNotificationsSection),
          const SizedBox(height: 10),
          NestCard(
            padding: const EdgeInsets.all(14),
            child: Text(
              l.profileWebNotificationsUnsupported,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NestSectionTitle(l.profileWebNotificationsSection),
        const SizedBox(height: 10),
        const _WebNotificationsCard(),
      ],
    );
  }
}

class _WebNotificationsCard extends StatefulWidget {
  const _WebNotificationsCard();

  @override
  State<_WebNotificationsCard> createState() => _WebNotificationsCardState();
}

class _WebNotificationsCardState extends State<_WebNotificationsCard> {
  // prefs keys
  static const _kEnabled = 'vita_webnotif_evening_enabled';
  static const _kHour = 'vita_webnotif_evening_hour';
  static const _kMinute = 'vita_webnotif_evening_minute';

  bool _loading = true;
  bool _enabled = false;
  int _hour = 21;
  int _minute = 30;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enabled = prefs.getBool(_kEnabled) ?? false;
      _hour = prefs.getInt(_kHour) ?? 21;
      _minute = prefs.getInt(_kMinute) ?? 30;
      _loading = false;
    });

    // На web: если включено — поднимем расписание (permission не спрашиваем)
    await _apply();
  }

  String _hhmm() =>
      '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, _enabled);
    await prefs.setInt(_kHour, _hour);
    await prefs.setInt(_kMinute, _minute);
  }

  Future<void> _apply() async {
    final l = AppLocalizations.of(context)!;

    if (!_enabled) {
      webNotifs.cancel('evening_checkin');
      return;
    }

    webNotifs.scheduleDaily(
      key: 'evening_checkin',
      hour: _hour,
      minute: _minute,
      title: l.profileWebNotificationsEveningTitle,
      // body пока не вынес в ключи (ты не просил) — оставляю как было
      body: 'Отметь привычки и подведи итоги дня 👌',
    );
  }

  Future<void> _requestPermission() async {
    final ok = await webNotifs.requestPermission();
    if (!mounted) return;

    if (!ok) {
      ProfileUi.snack(
        context,
        'Разрешение не выдано. Проверь настройки уведомлений в браузере.',
      );
      return;
    }

    ProfileUi.snack(context, 'Уведомления в браузере разрешены ✅');
    // если включено — сразу применим (теперь покажется, когда наступит время)
    await _apply();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
    );
    if (t == null) return;

    setState(() {
      _hour = t.hour;
      _minute = t.minute;
    });

    await _save();
    await _apply();

    if (!mounted) return;
    ProfileUi.snack(context, 'Время уведомления: ${_hhmm()}');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_loading) {
      return NestCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: const [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('Загрузка настроек...'),
          ],
        ),
      );
    }

    return NestCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            dense: true,
            leading: const Icon(Icons.notifications_outlined),
            title: Text(l.profileWebNotificationsPermissionTitle),
            subtitle: Text(l.profileWebNotificationsPermissionSubtitle),
            onTap: _requestPermission,
          ),
          const Divider(height: 1),

          SwitchListTile(
            dense: true,
            value: _enabled,
            title: Text(l.profileWebNotificationsEveningTitle),
            subtitle: Text(l.profileWebNotificationsEveningSubtitle(_hhmm())),
            onChanged: (v) async {
              setState(() => _enabled = v);
              await _save();
              await _apply();

              if (!mounted) return;
              if (v) {
                ProfileUi.snack(
                  context,
                  'Включено. Не забудь разрешить уведомления в браузере.',
                );
              } else {
                ProfileUi.snack(context, 'Выключено.');
              }
            },
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _enabled ? _pickTime : null,
                icon: const Icon(Icons.schedule),
                label: Text(l.profileWebNotificationsChangeTime),
                style: TextButton.styleFrom(
                  textStyle: theme.textTheme.labelLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFD6E6F5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x142B5B7A),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.person, size: 44, color: Color(0xFF2E4B5A)),
    );
  }
}
