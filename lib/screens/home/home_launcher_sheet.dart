import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/home_model.dart';
import '../../models/profile_model.dart';
import '../../models/goals_calendar_model.dart';
import '../../services/habits_repo_mixin.dart' show HabitEntryUpsert;
import '../../services/mental_repo_mixin.dart';
import '../../widgets/ai_insights_sheet.dart';
import '../../widgets/ai_plan_sheet.dart';
import '../../widgets/mass_daily_entry_sheet.dart';
import '../../main.dart';


bool get _ladnaDarkMode =>
    WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;

Color _ladnaAdaptive(Color light, Color dark) => _ladnaDarkMode ? dark : light;

String _ladnaText(BuildContext context, Map<String, String> values) {
  final code = Localizations.localeOf(context).languageCode.toLowerCase();
  return values[code] ?? values['en'] ?? values.values.first;
}

void showHomeLauncherSheet({
  required BuildContext context,
  required HomeModel model,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(_ladnaDarkMode ? 0.55 : 0.25),
    builder: (ctx) => _LauncherSheet(model: model),
  );
}

class _LauncherSheet extends StatelessWidget {
  const _LauncherSheet({required this.model});

  final HomeModel model;

  static Color get _surface => _ladnaAdaptive(const Color(0xFFF5F3FA), const Color(0xFF100C1E));
  static Color get _card => _ladnaAdaptive(const Color(0xFFFAFAFE), const Color(0xFF1C1630));
  static Color get _primary => const Color(0xFF6B54C0);
  static Color get _dark => _ladnaAdaptive(const Color(0xFF160E38), const Color(0xFFF0EEFF));
  static Color get _muted => _ladnaAdaptive(const Color(0xFF9090A8), const Color(0x4DFFFFFF));

  Future<void> _openMassAdd(BuildContext context) async {
    final goalsModel = GoalsCalendarModel();
    await goalsModel.loadBlocks();

    if (!context.mounted) return;

    final result = await showModalBottomSheet<MassDailyEntryResult>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => MassDailyEntrySheet(availableBlocks: goalsModel.lifeBlocks),
    );

    if (result == null) return;

    try {
      if (result.mood != null) {
        await dbRepo.upsertMood(
          date: DateUtils.dateOnly(result.date),
          emoji: result.mood!.emoji,
          note: result.mood!.note,
        );
      }

      for (final e in result.expenses) {
        final ts = DateTime(result.date.year, result.date.month, result.date.day, 12);
        await dbRepo.addTransaction(
          ts: ts,
          kind: 'expense',
          categoryId: e.categoryId,
          amount: e.amount,
          note: e.note.isEmpty ? null : e.note,
        );
      }

      for (final i in result.incomes) {
        final ts = DateTime(result.date.year, result.date.month, result.date.day, 12);
        await dbRepo.addTransaction(
          ts: ts,
          kind: 'income',
          categoryId: i.categoryId,
          amount: i.amount,
          note: i.note.isEmpty ? null : i.note,
        );
      }

      if (result.habits.isNotEmpty) {
        await dbRepo.upsertHabitEntries(
          result.habits
              .map(
                (h) => HabitEntryUpsert(
                  habitId: h.habitId,
                  day: DateUtils.dateOnly(result.date),
                  done: h.done,
                  value: h.value,
                ),
              )
              .toList(),
        );
      }

      if (result.mental.isNotEmpty) {
        await dbRepo.upsertMentalAnswers(
          result.mental.map((a) {
            if (a.valueBool != null) {
              return MentalAnswerUpsert.yesNo(
                questionId: a.questionId,
                day: DateUtils.dateOnly(result.date),
                value: a.valueBool!,
              );
            }
            if (a.valueInt != null) {
              return MentalAnswerUpsert.scale(
                questionId: a.questionId,
                day: DateUtils.dateOnly(result.date),
                value: a.valueInt!,
              );
            }
            return MentalAnswerUpsert.text(
              questionId: a.questionId,
              day: DateUtils.dateOnly(result.date),
              value: (a.valueText ?? '').trim(),
            );
          }).toList(),
        );
      }

      DateTime combine(DateTime day, TimeOfDay t) => DateTime(day.year, day.month, day.day, t.hour, t.minute);

      for (final g in result.goals) {
        final start = combine(result.date, g.startTime ?? const TimeOfDay(hour: 9, minute: 0));
        final deadline = DateTime(result.date.year, result.date.month, result.date.day, 23, 59);
        final hoursText = g.hours.toStringAsFixed(
          g.hours.truncateToDouble() == g.hours ? 0 : 1,
        );
        final desc = g.hours > 0
            ? _ladnaText(context, const {
                'ru': 'План: {hours} ч',
                'en': 'Plan: {hours} h',
                'de': 'Plan: {hours} Std.',
                'fr': 'Plan : {hours} h',
                'es': 'Plan: {hours} h',
                'tr': 'Plan: {hours} sa',
              }).replaceAll('{hours}', hoursText)
            : '';
        await dbRepo.createGoal(
          title: g.title,
          description: desc,
          deadline: deadline,
          startTime: start,
          lifeBlock: g.lifeBlock,
          importance: g.importance,
          emotion: g.emotion ?? '',
          spentHours: g.hours,
        );
      }
    } catch (_) {
      // keep launcher resilient; detailed errors are handled in the underlying sheets/screens
    }
  }

  void _select(BuildContext context, int index) {
    Navigator.of(context).pop();
    model.select(index);
  }

  void _openProfile(BuildContext context) => _select(context, 3);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _ladnaAdaptive(const Color(0xFFF5F3FA), const Color(0xFF100C1E)),
                _ladnaAdaptive(const Color(0xFFEFE8D8), const Color(0xFF0A0614)),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border(top: BorderSide(color: _ladnaAdaptive(const Color(0xFFE0DCF0), const Color(0x336B54C0)))),
          ),
          child: ListView(
            controller: controller,
            padding: EdgeInsets.fromLTRB(16, 12, 16, 18 + bottom),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _ladnaAdaptive(const Color(0xFF1C1812).withOpacity(0.15), const Color(0x4DFFFFFF)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _HeroLogoCard(onProfileTap: () => _openProfile(context)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 118,
                      child: _MenuCard(
                        emoji: '🏠',
                        label: _ladnaText(context, const {'ru': 'Главная', 'en': 'Home', 'de': 'Home', 'fr': 'Accueil', 'es': 'Inicio', 'tr': 'Ana sayfa'}),
                        tint: _primary.withOpacity(0.12),
                        onTap: () => _select(context, 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: SizedBox(
                      height: 118,
                      child: _MenuCard(
                        emoji: '🎯',
                        label: _ladnaText(context, const {'ru': 'Цели и задачи', 'en': 'Goals & tasks', 'de': 'Ziele & Aufgaben', 'fr': 'Objectifs & tâches', 'es': 'Metas y tareas', 'tr': 'Hedefler ve görevler'}),
                        tint: const Color(0xFFEBDADA),
                        onTap: () => _select(context, 1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 106,
                      child: _MenuCard(
                        emoji: '💛',
                        label: _ladnaText(context, const {'ru': 'Личное', 'en': 'Personal', 'de': 'Persönlich', 'fr': 'Personnel', 'es': 'Personal', 'tr': 'Kişisel'}),
                        tint: const Color(0xFFDDEEEB),
                        onTap: () => _select(context, 2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: SizedBox(
                      height: 106,
                      child: _MenuCard(
                        emoji: '📊',
                        label: _ladnaText(context, const {'ru': 'Отчёты', 'en': 'Reports', 'de': 'Berichte', 'fr': 'Rapports', 'es': 'Informes', 'tr': 'Raporlar'}),
                        tint: const Color(0xFFE8EDF8),
                        onTap: () => _select(context, 4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: SizedBox(
                      height: 106,
                      child: _MenuCard(
                        emoji: '💰',
                        label: _ladnaText(context, const {'ru': 'Бюджет', 'en': 'Budget', 'de': 'Budget', 'fr': 'Budget', 'es': 'Presupuesto', 'tr': 'Bütçe'}),
                        tint: const Color(0xFFEDE7F7),
                        onTap: () => _select(context, 5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SectionTitle(_ladnaText(context, const {
                'ru': 'Быстрые действия',
                'en': 'Quick actions',
                'de': 'Schnellaktionen',
                'fr': 'Actions rapides',
                'es': 'Acciones rápidas',
                'tr': 'Hızlı işlemler',
              })),
              const SizedBox(height: 10),
              _QuickAction(
                emoji: '⚡',
                tint: _primary.withOpacity(0.12),
                title: _ladnaText(context, const {'ru': 'Массовое добавление', 'en': 'Bulk add', 'de': 'Schnellerfassung', 'fr': 'Ajout groupé', 'es': 'Añadir en bloque', 'tr': 'Toplu ekleme'}),
                subtitle: _ladnaText(context, const {'ru': 'Расходы + Задачи + Настроение', 'en': 'Expenses + Tasks + Mood', 'de': 'Ausgaben + Aufgaben + Stimmung', 'fr': 'Dépenses + tâches + humeur', 'es': 'Gastos + tareas + ánimo', 'tr': 'Gider + görev + ruh hali'}),
                onTap: () => _openMassAdd(context),
              ),
              const SizedBox(height: 8),
              _QuickAction(
                emoji: '✦',
                tint: const Color(0xFFE8EDF8),
                title: _ladnaText(context, const {'ru': 'AI-план на неделю', 'en': 'AI weekly plan', 'de': 'AI-Wochenplan', 'fr': 'Plan IA hebdo', 'es': 'Plan semanal IA', 'tr': 'AI haftalık plan'}),
                subtitle: _ladnaText(context, const {'ru': 'Анализ целей и прогресса', 'en': 'Goals and progress analysis', 'de': 'Analyse von Zielen und Fortschritt', 'fr': 'Analyse des objectifs et progrès', 'es': 'Análisis de metas y progreso', 'tr': 'Hedef ve ilerleme analizi'}),
                onTap: () => AiPlanSheet.open(context, date: DateTime.now()),
              ),
              const SizedBox(height: 8),
              _QuickAction(
                emoji: '💡',
                tint: const Color(0xFFEDE7F7),
                title: _ladnaText(context, const {'ru': 'AI-инсайты', 'en': 'AI insights', 'de': 'AI-Insights', 'fr': 'Insights IA', 'es': 'Insights IA', 'tr': 'AI içgörüleri'}),
                subtitle: _ladnaText(context, const {'ru': 'Как события влияют на цели', 'en': 'How events influence goals', 'de': 'Wie Ereignisse Ziele beeinflussen', 'fr': 'Comment les événements influencent les objectifs', 'es': 'Cómo los eventos influyen en metas', 'tr': 'Olaylar hedefleri nasıl etkiler'}),
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    showDragHandle: true,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (_) => const AiInsightsSheet(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}


Future<String> _loadDisplayName() async {
  final client = Supabase.instance.client;
  final user = client.auth.currentUser;
  final email = user?.email;
  final metadata = user?.userMetadata ?? const <String, dynamic>{};
  for (final key in const ['name', 'full_name', 'display_name', 'username']) {
    final metadataName = metadata[key]?.toString().trim();
    if (metadataName != null && metadataName.isNotEmpty) return metadataName;
  }

  try {
    final uid = user?.id;
    if (uid != null) {
      final row = await client.from('users').select('name,email').eq('id', uid).maybeSingle();
      final name = row?['name']?.toString().trim();
      if (name != null && name.isNotEmpty) return name;
      final rowEmail = row?['email']?.toString().trim();
      if (rowEmail != null && rowEmail.isNotEmpty) return rowEmail.split('@').first;
    }
  } catch (_) {
    // fallback below
  }

  if (email != null && email.trim().isNotEmpty) return email.split('@').first;
  return 'Ladna';
}

class _HeroLogoCard extends StatelessWidget {
  const _HeroLogoCard({required this.onProfileTap});

  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF160E38), Color(0xFF1E1248)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -48,
            right: -42,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xFF6B54C0).withOpacity(0.22), Colors.transparent],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF6B54C0).withOpacity(0.30)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B54C0).withOpacity(0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B54C0).withOpacity(0.20),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            '✦',
                            style: TextStyle(fontSize: 30, color: Color(0xFFFAF6EE)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ladna',
                          style: TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 31,
                            height: 1.0,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFAF6EE),
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _ladnaText(context, const {
                            'ru': 'Навигация и действия',
                            'en': 'Navigation and actions',
                            'de': 'Navigation und Aktionen',
                            'fr': 'Navigation et actions',
                            'es': 'Navegación y acciones',
                            'tr': 'Gezinme ve işlemler',
                          }),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF9F95C8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: FutureBuilder<String>(
                    future: _loadDisplayName(),
                    builder: (context, snapshot) {
                      String? profileName;
                      try {
                        final profile = context.watch<ProfileModel>();
                        final raw = profile.name?.trim();
                        if (raw != null && raw.isNotEmpty) profileName = raw;
                      } catch (_) {
                        // ProfileModel is not always available above this bottom sheet.
                      }
                      final displayName = (profileName ?? snapshot.data ?? 'Ladna').trim();
                      return Row(
                        children: [
                          const Text('👤', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              displayName.isEmpty ? 'Ladna' : displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFFFAF6EE),
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Text('›', style: TextStyle(color: Color(0xFF9F95C8), fontSize: 25)),
                        ],
                      );
                    },
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: _LauncherSheet._muted,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.2,
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.emoji, required this.label, required this.tint, required this.onTap});

  final String emoji;
  final String label;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _LauncherSheet._card,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: _ladnaAdaptive(const Color(0xFFE0DCF0), const Color(0x336B54C0))),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(_ladnaDarkMode ? 0.30 : 0.035), blurRadius: 12, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: _ladnaDarkMode ? const Color(0xFF2A2140) : tint, borderRadius: BorderRadius.circular(14), border: Border.all(color: _ladnaAdaptive(Colors.transparent, const Color(0x336B54C0)))),
              child: Text(emoji, style: TextStyle(fontSize: 25)),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _LauncherSheet._dark,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.emoji, required this.tint, required this.title, required this.subtitle, required this.onTap});

  final String emoji;
  final Color tint;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: _LauncherSheet._card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _ladnaAdaptive(const Color(0xFFE0DCF0), const Color(0x336B54C0))),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(_ladnaDarkMode ? 0.30 : 0.035), blurRadius: 12, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: _ladnaDarkMode ? const Color(0xFF2A2140) : tint, borderRadius: BorderRadius.circular(11), border: Border.all(color: _ladnaAdaptive(Colors.transparent, const Color(0x336B54C0)))),
              child: Text(emoji, style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _LauncherSheet._dark,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _LauncherSheet._muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Text('›', style: TextStyle(color: _LauncherSheet._muted, fontSize: 25, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
