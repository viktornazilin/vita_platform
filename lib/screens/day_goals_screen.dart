import 'dart:typed_data';
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

enum _FabAction { manual, scan }

class _DayGoalsView extends StatefulWidget {
  const _DayGoalsView();

  @override
  State<_DayGoalsView> createState() => _DayGoalsViewState();
}

class _DayGoalsViewState extends State<_DayGoalsView> {
  final _scroll = ScrollController();
  final _picker = ImagePicker();

  Future<void> _openAdd(BuildContext context) async {
    final vm = context.read<DayGoalsModel>();
    final res = await showModalBottomSheet<AddGoalResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => AddDayGoalSheet(
        fixedLifeBlock: vm.lifeBlock,
        availableBlocks: vm.availableBlocks,
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
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 60));
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    }
  }

  /// 1) выбрать файл, 2) загрузить в storage, 3) распознать (заглушка), 4) показать предпросмотр и добавить отмеченные
  Future<void> _importFromJournal(BuildContext context) async {
    final vm = context.read<DayGoalsModel>();
    try {
      final source = Theme.of(context).platform == TargetPlatform.iOS ||
              Theme.of(context).platform == TargetPlatform.android
          ? ImageSource.camera
          : ImageSource.gallery;

      final file = await _picker.pickImage(
        source: source,
        maxWidth: 2000,
        imageQuality: 90,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();

      // 2) upload в Supabase storage (необязательно для заглушки, но пригодится для Vision)
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'anon';
      final path =
          '$userId/${DateTime.now().toIso8601String().replaceAll(":", "-")}_${file.name}';

      await Supabase.instance.client.storage
          .from('journal-uploads')
          .uploadBinary(path, bytes, fileOptions: const FileOptions(cacheControl: '3600', upsert: true));

      // 3) «распознание» — пока заглушка, превратим строки текста в задачи.
      final parsed = await _mockVisionParse(bytes);

      // 4) просмотр/редактирование/выбор
      final accepted = await showModalBottomSheet<List<AddGoalResult>>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) => _ReviewParsedGoalsSheet(
          initial: parsed,
          fixedLifeBlock: vm.lifeBlock,
          availableBlocks: vm.availableBlocks,
        ),
      );

      if (accepted == null || accepted.isEmpty) return;

      // Массовое добавление выбранных
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

  /// Простая заглушка OCR:
  /// - делаем вид, что нашли три пункта вида "08:30 Пробежка 5 км"
  /// - парсим время (HH:mm) и берем оставшееся как title
  Future<List<AddGoalResult>> _mockVisionParse(Uint8List bytes) async {
    // В реальной интеграции сюда подставим Google Cloud Vision/Text Detection.
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

    String stripTimePrefix(String s) {
      return s.replaceFirst(RegExp(r'^\s*\d{1,2}:\d{2}\s*'), '').trim();
    }

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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DayGoalsModel>();
    final goals = _sortedByStartTime(vm.goals);
    final title = vm.lifeBlock ?? 'Все сферы';

    return Scaffold(
      appBar: AppBar(
        title: Text('${vm.formattedDate}  •  $title'),
      ),
      floatingActionButton: PopupMenuButton<_FabAction>(
        icon: const Icon(Icons.add),
        itemBuilder: (ctx) => const [
          PopupMenuItem(
            value: _FabAction.manual,
            child: Text('Добавить вручную'),
          ),
          PopupMenuItem(
            value: _FabAction.scan,
            child: Text('Загрузить фото ежедневника'),
          ),
        ],
        onSelected: (action) async {
          if (action == _FabAction.manual) {
            await _openAdd(context);
          } else {
            await _importFromJournal(context);
          }
        },
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : goals.isEmpty
              ? const Center(child: Text('Целей на этот день нет'))
              : ListView.builder(
                  controller: _scroll,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  itemCount: goals.length,
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
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (ctx) => AddDayGoalSheet(
                            fixedLifeBlock: vm.lifeBlock,
                            availableBlocks: vm.availableBlocks,
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
    );
  }
}

/// Шторка «просмотр найденных задач»: отметь галочками, можно быстро отредактировать
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
    items = widget.initial
        .map((e) => _EditableParsed(accepted: true, data: e))
        .toList();
  }

  Future<void> _editItem(int i) async {
    final cur = items[i].data;
    // мини-редактор: заголовок + время + часы
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
                    if (picked != null) {
                      setState(() => time = picked);
                    }
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
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (ctx, controller) => Column(
          children: [
            const SizedBox(height: 8),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2))),
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
                      onChanged: (v) => setState(() => items[i] = it.copyWith(accepted: v ?? true)),
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
