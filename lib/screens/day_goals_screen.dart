import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/goal.dart';
import '../models/day_goals_model.dart';
import '../widgets/add_day_goal_sheet.dart';
import '../widgets/timeline_row.dart';

class DayGoalsScreen extends StatelessWidget {
  final DateTime date;
  final String? lifeBlock;
  final List<String> availableBlocks;

  const DayGoalsScreen({
    super.key,
    required this.date,
    required this.lifeBlock,
    this.availableBlocks = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DayGoalsModel(
        date: date,
        lifeBlock: lifeBlock,
        availableBlocks: availableBlocks,
      )..load(),
      child: const _DayGoalsView(),
    );
  }
}

class _DayGoalsView extends StatefulWidget {
  const _DayGoalsView();

  @override
  State<_DayGoalsView> createState() => _DayGoalsViewState();
}

class _DayGoalsViewState extends State<_DayGoalsView> {
  final _scroll = ScrollController();
  final _picker = ImagePicker();
  bool _fabOpen = false;

  Future<void> _openAdd(BuildContext context) async {
    final vm = context.read<DayGoalsModel>();
    final res = await showModalBottomSheet<AddGoalResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: AddDayGoalSheet(
            fixedLifeBlock: vm.lifeBlock,
            availableBlocks: vm.availableBlocks,
          ),
        ),
      ),
    );

    if (res != null) {
      await vm.createGoal(
        title: res.title,
        description: res.description,
        lifeBlockValue: res.lifeBlock,
        importance: res.importance,
        emotion: res.emotion,
        hours: res.hours,
        startTime: res.startTime,
      );
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 80));
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  Future<XFile?> _pickJournalImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Сделать фото'),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Выбрать из галереи'),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
    if (source == null) return null;
    return _picker.pickImage(source: source, maxWidth: 2000, imageQuality: 90);
  }

  Future<void> _importFromJournal(BuildContext context) async {
    final vm = context.read<DayGoalsModel>();
    try {
      final file = await _pickJournalImage(context);
      if (file == null) return;

      final bytes = await file.readAsBytes();

      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'anon';
      final path =
          '$userId/${DateTime.now().toIso8601String().replaceAll(":", "-")}_${file.name}';

      await Supabase.instance.client.storage
          .from('journal-uploads')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final parsed = await _mockVisionParse(bytes);

      final accepted = await showModalBottomSheet<List<AddGoalResult>>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: _ReviewParsedGoalsSheet(
              initial: parsed,
              fixedLifeBlock: vm.lifeBlock,
              availableBlocks: vm.availableBlocks,
            ),
          ),
        ),
      );

      if (accepted == null || accepted.isEmpty) return;

      for (final g in accepted) {
        await vm.createGoal(
          title: g.title,
          description: g.description,
          lifeBlockValue: g.lifeBlock,
          importance: g.importance,
          emotion: g.emotion,
          hours: g.hours,
          startTime: g.startTime,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Добавлено целей: ${accepted.length}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось импортировать: $e')),
      );
    }
  }

  Future<List<AddGoalResult>> _mockVisionParse(Uint8List bytes) async {
    final now = TimeOfDay.now();
    final lines = <String>[
      '08:30 Пробежка 5 км',
      '10:00 Встреча с дизайнером',
      '19:15 Прочитать 20 страниц книги',
    ];

    TimeOfDay parseTimeOr(TimeOfDay fallback, String s) {
      final m = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(s);
      if (m != null) {
        final h = int.tryParse(m.group(1)!) ?? fallback.hour;
        final min = int.tryParse(m.group(2)!) ?? fallback.minute;
        return TimeOfDay(hour: h.clamp(0, 23), minute: min.clamp(0, 59));
      }
      return fallback;
    }

    String stripTimePrefix(String s) =>
        s.replaceFirst(RegExp(r'^\s*\d{1,2}:\d{2}\s*'), '').trim();

    return lines.map((raw) {
      final t = parseTimeOr(now, raw);
      final title = stripTimePrefix(raw);
      return AddGoalResult(
        title: title.isEmpty ? 'Без названия' : title,
        description: '',
        lifeBlock: 'general',
        importance: 2,
        emotion: '',
        hours: 1.0,
        startTime: t,
      );
    }).toList();
  }

  List<Goal> _sortedByStartTime(List<Goal> src) {
    final list = List<Goal>.from(src);
    list.sort((a, b) => a.startTime.compareTo(b.startTime));
    return list;
  }

  Future<void> _refresh() async {
    await context.read<DayGoalsModel>().load();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DayGoalsModel>();
    final goals = _sortedByStartTime(vm.goals);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final title = vm.lifeBlock ?? 'Все сферы';

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final isCompact = w < 600;
        final listHPad = isCompact ? 12.0 : 16.0;

        return Scaffold(
          floatingActionButtonLocation:
              isCompact ? FloatingActionButtonLocation.endFloat : FloatingActionButtonLocation.endFloat,
          floatingActionButton: _FabMenu(
            compact: isCompact,
            open: _fabOpen,
            onOpenChanged: (v) => setState(() => _fabOpen = v),
            actions: [
              FabActionItem(
                icon: Icons.edit_outlined,
                label: 'Добавить вручную',
                onTap: () => _openAdd(context),
              ),
              FabActionItem(
                icon: Icons.document_scanner_outlined,
                label: 'Фото ежедневника',
                onTap: () => _importFromJournal(context),
              ),
            ],
          ),
          body: RefreshIndicator.adaptive(
            onRefresh: _refresh,
            child: CustomScrollView(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (isCompact)
                  SliverAppBar(
                    pinned: true,
                    title: Text(vm.formattedDate),
                    centerTitle: false,
                    actions: [
                      if (vm.lifeBlock != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: cs.secondaryContainer,
                                border: Border.all(color: cs.outlineVariant),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(title, style: tt.labelMedium),
                            ),
                          ),
                        ),
                    ],
                  )
                else
                  SliverAppBar.large(
                    title: Text(vm.formattedDate),
                    centerTitle: false,
                    actions: [
                      if (vm.lifeBlock != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: cs.secondaryContainer,
                                border: Border.all(color: cs.outlineVariant),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(title, style: tt.labelMedium),
                            ),
                          ),
                        ),
                    ],
                  ),

                // Пустое состояние / список
                if (vm.loading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (goals.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      icon: Icons.flag_outlined,
                      title: 'Целей на этот день нет',
                      subtitle: 'Нажми «+» чтобы добавить задачу вручную\nили импортируй из дневника.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: listHPad, vertical: 6),
                    sliver: SliverList.separated(
                      itemCount: goals.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final g = goals[i];
                        return TimelineRow(
                          key: ValueKey(g.id),
                          goal: g,
                          index: i,
                          total: goals.length,
                          onToggle: () => vm.toggleComplete(g),
                          onDelete: () => vm.deleteGoal(g),
                          onEdit: () async {
                            final res = await showModalBottomSheet<AddGoalResult>(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              ),
                              builder: (ctx) => Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 520),
                                  child: AddDayGoalSheet(
                                    fixedLifeBlock: vm.lifeBlock,
                                    availableBlocks: vm.availableBlocks,
                                  ),
                                ),
                              ),
                            );
                            if (res != null) {
                              await vm.updateGoal(
                                id: g.id,
                                title: res.title,
                                description: res.description,
                                lifeBlockValue: res.lifeBlock,
                                importance: res.importance,
                                emotion: res.emotion,
                                hours: res.hours,
                                startTime: res.startTime,
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),

                SliverToBoxAdapter(child: SizedBox(height: isCompact ? 72 : 96)),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// FAB с меню-действиями (адаптивный)
class _FabMenu extends StatelessWidget {
  final bool compact;
  final bool open;
  final ValueChanged<bool> onOpenChanged;
  final List<FabActionItem> actions;

  const _FabMenu({
    required this.compact,
    required this.open,
    required this.onOpenChanged,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final fab = compact
        ? FloatingActionButton.small(
            heroTag: 'day-fab-small',
            onPressed: () => onOpenChanged(!open),
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            child: AnimatedRotation(
              turns: open ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.add),
            ),
          )
        : FloatingActionButton(
            heroTag: 'day-fab',
            onPressed: () => onOpenChanged(!open),
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            child: AnimatedRotation(
              turns: open ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.add),
            ),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (open) ...[
          for (final a in actions.reversed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FabActionChip(item: a, compact: compact),
            ),
        ],
        fab,
      ],
    );
  }
}

class FabActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  FabActionItem({required this.icon, required this.label, required this.onTap});
}

class _FabActionChip extends StatelessWidget {
  final FabActionItem item;
  final bool compact;
  const _FabActionChip({required this.item, required this.compact});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final padding = compact ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8) : const EdgeInsets.symmetric(horizontal: 14, vertical: 10);
    final iconSize = compact ? 16.0 : 18.0;
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: cs.onSurface,
          fontSize: compact ? 12 : null,
        );
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          elevation: 2,
          color: cs.surface.withOpacity(0.9),
          shape: StadiumBorder(side: BorderSide(color: cs.outlineVariant)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () {
              item.onTap();
              final state = context.findAncestorStateOfType<_DayGoalsViewState>();
              state?.setState(() => state._fabOpen = false);
            },
            child: Padding(
              padding: padding,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(item.icon, size: iconSize, color: cs.onSurface),
                const SizedBox(width: 8),
                Text(item.label, style: textStyle),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Шторка «просмотр найденных задач»
class _ReviewParsedGoalsSheet extends StatefulWidget {
  final List<AddGoalResult> initial;
  final String? fixedLifeBlock;
  final List<String> availableBlocks;

  const _ReviewParsedGoalsSheet({
    required this.initial,
    required this.fixedLifeBlock,
    required this.availableBlocks,
  });

  @override
  State<_ReviewParsedGoalsSheet> createState() => _ReviewParsedGoalsSheetState();
}

class _ReviewParsedGoalsSheetState extends State<_ReviewParsedGoalsSheet> {
  late List<_EditableParsed> items;

  @override
  void initState() {
    super.initState();
    items = widget.initial.map((e) => _EditableParsed(accepted: true, data: e)).toList();
  }

  Future<void> _editItem(int i) async {
    final cur = items[i].data;
    final titleCtrl = TextEditingController(text: cur.title);
    TimeOfDay time = cur.startTime;
    double hours = cur.hours;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Редактировать'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Название')),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Время:'),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(context: ctx, initialTime: time);
                    if (picked != null) setState(() => time = picked);
                  },
                  child: Text(time.format(ctx)),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Часы:'),
                Expanded(
                  child: Slider(
                    min: 0.5, max: 14, divisions: 27,
                    value: hours,
                    label: hours.toStringAsFixed(1),
                    onChanged: (v) => setState(() => hours = v),
                  ),
                ),
                SizedBox(width: 48, child: Text(hours.toStringAsFixed(1), textAlign: TextAlign.right)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              setState(() {
                items[i] = items[i].copyWith(
                  data: AddGoalResult(
                    title: titleCtrl.text.trim().isEmpty ? 'Без названия' : titleCtrl.text.trim(),
                    description: cur.description,
                    lifeBlock: widget.fixedLifeBlock ?? cur.lifeBlock,
                    importance: cur.importance,
                    emotion: cur.emotion,
                    hours: hours,
                    startTime: time,
                  ),
                );
              });
              Navigator.pop(ctx);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (ctx, controller) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Найденные задачи', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    controller: controller,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final it = items[i];
                      final d = it.data;
                      return ListTile(
                        leading: Checkbox(
                          value: it.accepted,
                          onChanged: (v) =>
                              setState(() => items[i] = it.copyWith(accepted: v ?? true)),
                        ),
                        title: Text(d.title),
                        subtitle: Text('${d.startTime.format(context)} • ${d.hours.toStringAsFixed(1)} ч'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _editItem(i),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Отмена'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              final accepted = items.where((e) => e.accepted).map((e) => e.data).toList();
                              Navigator.pop(context, accepted);
                            },
                            child: const Text('Добавить выбранные'),
                          ),
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
    );
  }
}

class _EditableParsed {
  final bool accepted;
  final AddGoalResult data;
  _EditableParsed({required this.accepted, required this.data});

  _EditableParsed copyWith({bool? accepted, AddGoalResult? data}) =>
      _EditableParsed(accepted: accepted ?? this.accepted, data: data ?? this.data);
}

// ——— Пустое состояние
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 44, color: cs.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(subtitle, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
