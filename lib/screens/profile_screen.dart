// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart'; // dbRepo
import '../models/profile_model.dart';
import '../controllers/theme_controller.dart';
import '../widgets/xp_progress_bar.dart';

// HABITS
import '../models/habits_model.dart';
import '../models/habit.dart';

// GOALS
import '../models/user_goals_model.dart';
import '../services/user_goals_repo_mixin.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProfileModel(repo: dbRepo)..load(),
        ),
        ChangeNotifierProvider(create: (_) => HabitsModel()..load()),
        ChangeNotifierProvider(
          create: (_) => UserGoalsModel(repo: dbRepo)..load(),
        ),
      ],
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  // ===== helpers =====
  void _snack(BuildContext context, String text) {
    final sm = ScaffoldMessenger.maybeOf(context);
    if (sm == null) return;
    sm.showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  Future<String?> _promptText(
    BuildContext context, {
    required String title,
    required String label,
    String initial = '',
    int maxLen = 200,
    int maxLines = 1,
    String? hint,
  }) async {
    final ctrl = TextEditingController(text: initial);
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          maxLength: maxLen,
          maxLines: maxLines,
          decoration: InputDecoration(labelText: label, hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    return res;
  }

  Future<int?> _promptInt(
    BuildContext context, {
    required String title,
    required String label,
    int? initial,
    int min = 0,
    int max = 120,
  }) async {
    final ctrl = TextEditingController(text: initial?.toString() ?? '');
    final res = await showDialog<int?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: label, hintText: '$min…$max'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              final t = ctrl.text.trim();
              if (t.isEmpty) return Navigator.pop(ctx, null);
              final v = int.tryParse(t);
              if (v == null || v < min || v > max) return;
              Navigator.pop(ctx, v);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    return res;
  }

  Future<double?> _promptDouble(
    BuildContext context, {
    required String title,
    required String label,
    required double initial,
    double min = 1,
    double max = 24,
    int decimals = 1,
  }) async {
    return showDialog<double>(
      context: context,
      builder: (ctx) {
        double value = initial.clamp(min, max);
        return StatefulBuilder(
          builder: (ctx, setSt) => AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(label)),
                    Text(
                      value.toStringAsFixed(decimals),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: ((max - min) * 2).round(), // шаг 0.5
                  onChanged: (v) => setSt(() => value = v),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, value),
                child: const Text('Сохранить'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<String>?> _editChipsDialog(
    BuildContext context, {
    required String title,
    required List<String> initial,
    String hint = 'Введите через запятую',
  }) async {
    final ctrl = TextEditingController(text: initial.join(', '));
    final res = await showDialog<List<String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              final raw = ctrl.text.trim();
              final list =
                  raw.isEmpty
                        ? <String>[]
                        : raw
                              .split(',')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toSet()
                              .toList()
                    ..sort();
              Navigator.pop(ctx, list);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    return res;
  }

  // ===== habits dialogs =====
  Future<void> _habitEditor(BuildContext context, {Habit? existing}) async {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    bool isNeg = existing?.isNegative ?? false;

    final res = await showDialog<(String title, bool neg)>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(
            existing == null ? 'Новая привычка' : 'Редактировать привычку',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                maxLength: 60,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              const SizedBox(height: 6),
              SwitchListTile(
                value: isNeg,
                onChanged: (v) => setSt(() => isNeg = v),
                title: const Text('Негативная привычка'),
                subtitle: const Text(
                  'Отметь, если хочешь отслеживать и сокращать',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                final t = titleCtrl.text.trim();
                if (t.isEmpty) return;
                Navigator.pop(ctx, (t, isNeg));
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );

    titleCtrl.dispose();
    if (res == null) return;

    final habits = context.read<HabitsModel>();
    String? err;
    if (existing == null) {
      err = await habits.create(title: res.$1, isNegative: res.$2);
    } else {
      err = await habits.update(existing.id, title: res.$1, isNegative: res.$2);
    }
    if (err != null && context.mounted) _snack(context, err);
  }

  Future<void> _habitDeleteConfirm(BuildContext context, Habit h) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить привычку?'),
        content: Text(
          '«${h.title}» будет удалена без возможности восстановления.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final habits = context.read<HabitsModel>();
    final err = await habits.delete(h.id);
    if (err != null && context.mounted) _snack(context, err);
  }

  // ======= UI blocks =======
  Widget _editableRow({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onEdit,
    IconData icon = Icons.edit_outlined,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        title: Text(label),
        subtitle: Text(value),
        trailing: Icon(icon, color: cs.primary),
        onTap: onEdit,
      ),
    );
  }

  Widget _chipsCard(
    BuildContext context, {
    required String title,
    required List<String> items,
    required VoidCallback onEdit,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  tooltip: 'Изменить',
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined, color: cs.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Opacity(opacity: .7, child: Text('—'))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map((e) => Chip(label: Text(e))).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _habitsCard(BuildContext context) {
    final habits = context.watch<HabitsModel>();
    final cs = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Привычки',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  tooltip: 'Добавить',
                  onPressed: () => _habitEditor(context),
                  icon: Icon(Icons.add_circle_outline, color: cs.primary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (habits.loading)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator.adaptive()),
              )
            else if (habits.items.isEmpty)
              const Opacity(
                opacity: .7,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Пока нет привычек. Добавь первую.'),
                ),
              )
            else
              ...habits.items.map((h) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    h.isNegative
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
                  ),
                  title: Text(h.title),
                  subtitle: Text(
                    h.isNegative ? 'Негативная' : 'Позитивная/нейтральная',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit')
                        return _habitEditor(context, existing: h);
                      if (v == 'delete') return _habitDeleteConfirm(context, h);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Изменить')),
                      PopupMenuItem(value: 'delete', child: Text('Удалить')),
                    ],
                  ),
                  onTap: () => _habitEditor(context, existing: h),
                );
              }),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Позже добавим “отсеивание” привычек на главном экране.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ProfileModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final err = model.error;
      if (err != null && ScaffoldMessenger.maybeOf(context) != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
      }
    });

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final isWide = w >= 960;
        final outerPad = EdgeInsets.symmetric(
          horizontal: isWide ? 24 : 16,
          vertical: isWide ? 16 : 12,
        );

        final leftColumnChildren = <Widget>[
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: 16),
                  model.xp != null
                      ? XPProgressBar(xp: model.xp!)
                      : const Opacity(
                          opacity: .65,
                          child: Text('XP data not available'),
                        ),
                  const SizedBox(height: 10),
                  _editableRow(
                    context: context,
                    label: 'Имя',
                    value: model.name?.isNotEmpty == true ? model.name! : '—',
                    onEdit: () async {
                      final v = await _promptText(
                        context,
                        title: 'Имя',
                        label: 'Как тебя называть?',
                        initial: model.name ?? '',
                        maxLen: 40,
                      );
                      if (v == null) return;
                      final err = await model.setName(v.isEmpty ? null : v);
                      if (err != null && context.mounted) _snack(context, err);
                    },
                  ),
                  _editableRow(
                    context: context,
                    label: 'Возраст',
                    value: model.age?.toString() ?? '—',
                    onEdit: () async {
                      final v = await _promptInt(
                        context,
                        title: 'Возраст',
                        label: 'Введите возраст',
                        initial: model.age,
                        min: 10,
                        max: 120,
                      );
                      final err = await model.setAge(v);
                      if (err != null && context.mounted) _snack(context, err);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Аккаунт',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _editableRow(
            context: context,
            label: 'Архетип',
            value: model.archetype ?? '—',
            onEdit: () async {
              final v = await _promptText(
                context,
                title: 'Архетип',
                label: 'Например: balance / sport / business…',
                initial: model.archetype ?? '',
                maxLen: 30,
              );
              if (v == null) return;
              final err = await model.setArchetype(v.isEmpty ? null : v);
              if (err != null && context.mounted) _snack(context, err);
            },
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: SwitchListTile(
              title: const Text('Пролог пройден'),
              subtitle: const Text('Можно изменить вручную'),
              value: model.hasSeenIntro,
              onChanged: (v) async {
                final err = await model.setHasSeenIntro(v);
                if (err != null && context.mounted) _snack(context, err);
              },
            ),
          ),
          const SizedBox(height: 16),
          _editableRow(
            context: context,
            label: 'Целевая норма часов/день',
            value: '${model.targetHours.toStringAsFixed(1)} ч',
            onEdit: () async {
              final v = await _promptDouble(
                context,
                title: 'Цель по часам в день',
                label: 'Часы',
                initial: model.targetHours,
                min: 1,
                max: 24,
                decimals: 1,
              );
              if (v == null) return;
              final err = await model.setTargetHours(v);
              if (err != null && context.mounted) _snack(context, err);
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Оформление',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const _ThemeSection(),
        ];

        final rightColumnChildren = <Widget>[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Опросник и сферы жизни',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (model.hasCompletedQuestionnaire)
                TextButton.icon(
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Изменить'),
                  onPressed: () => Navigator.pushNamed(context, '/onboarding'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (!model.hasCompletedQuestionnaire) ...[
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Opacity(
                      opacity: .7,
                      child: Text('Вы ещё не прошли опросник.'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/onboarding'),
                      child: const Text('Пройти сейчас'),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            _chipsCard(
              context,
              title: 'Сферы жизни',
              items: model.lifeBlocks,
              onEdit: () async {
                final v = await _editChipsDialog(
                  context,
                  title: 'Сферы жизни',
                  initial: model.lifeBlocks,
                  hint: 'Например: здоровье, карьера, семья',
                );
                if (v == null) return;
                final err = await model.setLifeBlocks(v);
                if (err != null && context.mounted) _snack(context, err);
              },
            ),
            _chipsCard(
              context,
              title: 'Приоритеты',
              items: model.priorities,
              onEdit: () async {
                final v = await _editChipsDialog(
                  context,
                  title: 'Приоритеты',
                  initial: model.priorities,
                  hint: 'Например: спорт, финансы, чтение',
                );
                if (v == null) return;
                final err = await model.setPriorities(v);
                if (err != null && context.mounted) _snack(context, err);
              },
            ),
            const SizedBox(height: 8),
            _GoalsByBlockCard(onSnack: (t) => _snack(context, t)),
            const SizedBox(height: 8),
            _habitsCard(context),
          ],
        ];

        Future<void> _refreshAll() async {
          await context.read<ProfileModel>().load();
          await context.read<HabitsModel>().load();
          await context.read<UserGoalsModel>().load();
        }

        if (!isWide) {
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Image.asset('assets/images/logo.png', height: 28),
                  const SizedBox(width: 10),
                  const Text('My Profile'),
                ],
              ),
            ),
            body: model.loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _refreshAll,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: outerPad,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ...leftColumnChildren,
                              const SizedBox(height: 24),
                              ...rightColumnChildren,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Image.asset('assets/images/logo.png', height: 28),
                const SizedBox(width: 10),
                const Text('My Profile'),
              ],
            ),
          ),
          body: model.loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refreshAll,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Padding(
                          padding: outerPad,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: leftColumnChildren,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 7,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: rightColumnChildren,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

// ======================= GOALS UI =======================

class _GoalsByBlockCard extends StatelessWidget {
  final void Function(String text) onSnack;
  const _GoalsByBlockCard({required this.onSnack});

  String _hLabel(GoalHorizon h) {
    switch (h) {
      case GoalHorizon.tactical:
        return 'Тактические (2–6 недель)';
      case GoalHorizon.mid:
        return 'Среднесрочные (3–6 месяцев)';
      case GoalHorizon.long:
        return 'Долгосрочные (1+ год)';
    }
  }

  IconData _hIcon(GoalHorizon h) {
    switch (h) {
      case GoalHorizon.tactical:
        return Icons.bolt_outlined;
      case GoalHorizon.mid:
        return Icons.trending_up;
      case GoalHorizon.long:
        return Icons.flag_outlined;
    }
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd.$mm.$yy';
  }

  Future<UserGoalUpsert?> _openGoalEditor(
    BuildContext context, {
    required List<String> allowedBlocks,
    UserGoal? existing,
    String? initialBlock,
  }) async {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    DateTime? targetDate = existing?.targetDate;

    GoalHorizon horizon = existing?.horizon ?? GoalHorizon.mid;
    String lifeBlock =
        existing?.lifeBlock ??
        (initialBlock ??
            (allowedBlocks.isNotEmpty ? allowedBlocks.first : 'general'));

    final res = await showDialog<UserGoalUpsert>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(existing == null ? 'Новая цель' : 'Редактировать цель'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: lifeBlock,
                    items: (allowedBlocks.isEmpty ? [lifeBlock] : allowedBlocks)
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (v) => setSt(() => lifeBlock = v ?? lifeBlock),
                    decoration: const InputDecoration(
                      labelText: 'Сфера жизни (life_block)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<GoalHorizon>(
                    value: horizon,
                    items: GoalHorizon.values
                        .map(
                          (h) => DropdownMenuItem(
                            value: h,
                            child: Text(_hLabel(h)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setSt(() => horizon = v ?? horizon),
                    decoration: const InputDecoration(labelText: 'Горизонт'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: titleCtrl,
                    maxLength: 80,
                    decoration: const InputDecoration(
                      labelText: 'Название',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Описание (опционально)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: Text('Дедлайн: ${_fmtDate(targetDate)}')),
                      TextButton.icon(
                        icon: const Icon(Icons.event),
                        label: const Text('Выбрать'),
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: ctx,
                            firstDate: DateTime(now.year - 1, 1, 1),
                            lastDate: DateTime(now.year + 10, 12, 31),
                            initialDate: targetDate ?? now,
                          );
                          if (picked != null) {
                            setSt(
                              () => targetDate = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                              ),
                            );
                          }
                        },
                      ),
                      if (targetDate != null)
                        IconButton(
                          tooltip: 'Убрать',
                          onPressed: () => setSt(() => targetDate = null),
                          icon: const Icon(Icons.clear),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                final t = titleCtrl.text.trim();
                if (t.isEmpty) return;

                Navigator.pop(
                  ctx,
                  UserGoalUpsert(
                    id: existing?.id,
                    lifeBlock: lifeBlock.trim(),
                    horizon: horizon,
                    title: t,
                    description: descCtrl.text.trim(),
                    targetDate: targetDate,
                  ),
                );
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );

    titleCtrl.dispose();
    descCtrl.dispose();
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileModel>();
    final goalsModel = context.watch<UserGoalsModel>();
    final cs = Theme.of(context).colorScheme;

    final allowedBlocks = profile.lifeBlocks;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Цели по сферам',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: 'Добавить цель',
                  onPressed: goalsModel.loading
                      ? null
                      : () async {
                          final dto = await _openGoalEditor(
                            context,
                            allowedBlocks: allowedBlocks,
                          );
                          if (dto == null) return;
                          final err = await context
                              .read<UserGoalsModel>()
                              .upsert(dto);
                          if (err != null && context.mounted) onSnack(err);
                        },
                  icon: Icon(Icons.add_circle_outline, color: cs.primary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (goalsModel.loading)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator.adaptive()),
              )
            else if (goalsModel.error != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  goalsModel.error!,
                  style: TextStyle(color: cs.error),
                ),
              )
            else if (goalsModel.grouped.isEmpty)
              const Opacity(
                opacity: .7,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Пока нет целей. Добавь первую цель для выбранных сфер.',
                  ),
                ),
              )
            else
              ...goalsModel.grouped.entries.map((blockEntry) {
                final block = blockEntry.key;
                final byH = blockEntry.value;

                // не показываем цели для сфер, которых нет в профиле
                if (allowedBlocks.isNotEmpty &&
                    !allowedBlocks.contains(block)) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    elevation: 0,
                    color: cs.surfaceContainerHighest.withOpacity(0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        block,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      children: [
                        for (final h in GoalHorizon.values) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(_hIcon(h), size: 18, color: cs.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _hLabel(h),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final dto = await _openGoalEditor(
                                    context,
                                    allowedBlocks: allowedBlocks.isEmpty
                                        ? [block]
                                        : allowedBlocks,
                                    initialBlock: block,
                                  );
                                  if (dto == null) return;
                                  final err = await context
                                      .read<UserGoalsModel>()
                                      .upsert(dto);
                                  if (err != null && context.mounted)
                                    onSnack(err);
                                },
                                child: const Text('Добавить'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if ((byH[h] ?? const <UserGoal>[]).isEmpty)
                            const Opacity(opacity: .65, child: Text('—'))
                          else
                            ...byH[h]!.map((g) {
                              final subtitleParts = <String>[
                                if (g.description.trim().isNotEmpty)
                                  g.description.trim(),
                                if (g.targetDate != null)
                                  'Дедлайн: ${_fmtDate(g.targetDate)}',
                              ];

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(g.title),
                                subtitle: subtitleParts.isEmpty
                                    ? null
                                    : Text(subtitleParts.join(' • ')),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (v) async {
                                    if (v == 'edit') {
                                      final dto = await _openGoalEditor(
                                        context,
                                        allowedBlocks: allowedBlocks.isEmpty
                                            ? [block]
                                            : allowedBlocks,
                                        existing: g,
                                      );
                                      if (dto == null) return;
                                      final err = await context
                                          .read<UserGoalsModel>()
                                          .upsert(dto);
                                      if (err != null && context.mounted)
                                        onSnack(err);
                                    }
                                    if (v == 'delete') {
                                      final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Удалить цель?'),
                                          content: Text(
                                            '«${g.title}» будет удалена без возможности восстановления.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text('Отмена'),
                                            ),
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text('Удалить'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (ok != true) return;
                                      final err = await context
                                          .read<UserGoalsModel>()
                                          .delete(g.id);
                                      if (err != null && context.mounted)
                                        onSnack(err);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Изменить'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Удалить'),
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  final dto = await _openGoalEditor(
                                    context,
                                    allowedBlocks: allowedBlocks.isEmpty
                                        ? [block]
                                        : allowedBlocks,
                                    existing: g,
                                  );
                                  if (dto == null) return;
                                  final err = await context
                                      .read<UserGoalsModel>()
                                      .upsert(dto);
                                  if (err != null && context.mounted)
                                    onSnack(err);
                                },
                              );
                            }),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

// ======================= THEME =======================

class _ThemeSection extends StatelessWidget {
  const _ThemeSection();

  static const _swatches = <Color>[
    Color(0xFF6750A4),
    Color(0xFF0061A4),
    Color(0xFF006E1C),
    Color(0xFF8B5000),
    Color(0xFF7D5260),
    Color(0xFFB00020),
    Color(0xFF005457),
    Color(0xFF4E342E),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final cs = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Цвет приложения',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _swatches.map((c) {
                final selected = theme.seedColor.value == c.value;
                return InkWell(
                  onTap: () => context.read<ThemeController>().setSeedColor(c),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? cs.primary : cs.outlineVariant,
                        width: selected ? 2.5 : 1,
                      ),
                      boxShadow: [
                        if (selected)
                          BoxShadow(
                            color: cs.primary.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Режим', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Светлая'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Тёмная'),
                  icon: Icon(Icons.dark_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('Системная'),
                  icon: Icon(Icons.phone_android),
                ),
              ],
              selected: {theme.mode},
              onSelectionChanged: (v) =>
                  context.read<ThemeController>().setMode(v.first),
            ),
          ],
        ),
      ),
    );
  }
}
