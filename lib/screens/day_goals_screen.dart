// lib/screens/day_goals_screen.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/goal.dart';
import '../models/day_goals_model.dart';
import '../widgets/add_day_goal_sheet.dart';
import '../widgets/timeline_row.dart';

/// Читаем ключ Vision (для примера захардкожен; лучше вынести в --dart-define)
const String _kVisionApiKey = "AIzaSyBBEjM1LYnJw1_SmsAJbZIl-y08xjF5X-s";

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

  /// 1) выбрать фото → 2) (опц.) сохранить в Storage → 3) OCR Vision → 4) предпросмотр → 5) массовое добавление
  Future<void> _importFromJournal(BuildContext context) async {
    final vm = context.read<DayGoalsModel>();
    try {
      final source =
          (Theme.of(context).platform == TargetPlatform.iOS || Theme.of(context).platform == TargetPlatform.android)
              ? ImageSource.camera
              : ImageSource.gallery;

      final file = await _picker.pickImage(
        source: source,
        maxWidth: 2400,
        imageQuality: 92,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();

      // (опционально) — сохраняем снимок в Supabase Storage
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'anon';
      final path = '$userId/${DateTime.now().toIso8601String().replaceAll(":", "-")}_${file.name}';
      await Supabase.instance.client.storage
          .from('journal-uploads')
          .uploadBinary(path, bytes, fileOptions: const FileOptions(cacheControl: '3600', upsert: true));

      // Показать краткий лоадер на время OCR
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
      }

      // OCR Google Vision
      final ocrText = await _googleVisionOcr(bytes);

      if (mounted) Navigator.of(context).pop(); // закрыть лоадер

      // Парсим текст в черновики задач
      final parsed = await _visionParse(ocrText);

      // Просмотр/редактирование/выбор
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
      // закрыть лоадер, если открыт
      Navigator.of(context, rootNavigator: true).maybePop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось импортировать: $e')),
      );
    }
  }

  /// Вызов Google Cloud Vision (DOCUMENT_TEXT_DETECTION). Возвращает полный распознанный текст.
  Future<String> _googleVisionOcr(Uint8List bytes) async {
    if (_kVisionApiKey.isEmpty) {
      throw 'VISION_API_KEY не задан. Запусти с --dart-define=VISION_API_KEY=...';
    }

    final uri = Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=$_kVisionApiKey');

    final payload = {
      "requests": [
        {
          "image": {"content": base64Encode(bytes)},
          "features": [
            {"type": "DOCUMENT_TEXT_DETECTION"}
          ],
          "imageContext": {
            // подсказываем языки (рус/англ рукопись)
            "languageHints": ["ru", "en"]
          }
        }
      ]
    };

    final resp = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (resp.statusCode != 200) {
      throw 'Vision API error ${resp.statusCode}: ${resp.body}';
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final responses = (data['responses'] as List?) ?? const [];
    if (responses.isEmpty) return '';

    final fullText = (responses.first['fullTextAnnotation']?['text'] as String?) ?? '';
    return fullText;
  }

  /// Простой парсер строк → AddGoalResult:
  /// ищем префикс времени HH:mm (если нет — берём текущее), остальное — название.
  Future<List<AddGoalResult>> _visionParse(String fullText) async {
    if (fullText.trim().isEmpty) return const [];

    final now = TimeOfDay.now();
    final lines = fullText
        .split(RegExp(r'\r?\n'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    TimeOfDay parseTimeOr(TimeOfDay fallback, String s) {
      final m = RegExp(r'(\b\d{1,2}):(\d{2})\b').firstMatch(s);
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

    final useful = lines.where((l) => l.replaceAll(' ', '').length > 2).toList();

    return useful.map((raw) {
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
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (ctx) => _EditGoalSheet(
                            goal: g,
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

/// ───────────────────────────
/// Шторка редактирования цели
/// ───────────────────────────
class _EditGoalSheet extends StatefulWidget {
  final Goal goal;
  final String? fixedLifeBlock;
  final List<String> availableBlocks;

  const _EditGoalSheet({
    required this.goal,
    required this.fixedLifeBlock,
    required this.availableBlocks,
  });

  @override
  State<_EditGoalSheet> createState() => _EditGoalSheetState();
}

class _EditGoalSheetState extends State<_EditGoalSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _emotionCtrl;

  late String _lifeBlock;
  late int _importance;   // 1..3
  late double _hours;     // 0.5..14
  late TimeOfDay _start;  // показываем как TimeOfDay

  @override
  void initState() {
    super.initState();
    final g = widget.goal;

    _titleCtrl   = TextEditingController(text: g.title);
    _descCtrl    = TextEditingController(text: g.description);
    _emotionCtrl = TextEditingController(text: g.emotion);

    _lifeBlock = widget.fixedLifeBlock
        ?? g.lifeBlock
        ?? (widget.availableBlocks.isNotEmpty ? widget.availableBlocks.first : 'general');

    _importance = g.importance;

    // часы берём из spentHours, ограничиваем диапазон для слайдера
    _hours = g.spentHours;
    if (_hours < 0.5) _hours = 0.5;
    if (_hours > 14.0) _hours = 14.0;

    // DateTime -> TimeOfDay
    _start = TimeOfDay.fromDateTime(g.startTime);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _emotionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _start);
    if (picked != null) setState(() => _start = picked);
  }

  void _submit() {
    final title = _titleCtrl.text.trim().isEmpty ? 'Без названия' : _titleCtrl.text.trim();
    Navigator.pop(
      context,
      AddGoalResult(
        title: title,
        description: _descCtrl.text.trim(),
        lifeBlock: _lifeBlock,
        importance: _importance,
        emotion: _emotionCtrl.text.trim(),
        hours: _hours,
        startTime: _start,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final canEditBlock = widget.fixedLifeBlock == null;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (ctx, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 12),
              Text('Редактировать цель', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),

              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _descCtrl,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 12),

              if (canEditBlock) ...[
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Сфера/блок'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _lifeBlock,
                      isExpanded: true,
                      items: (widget.availableBlocks.isNotEmpty ? widget.availableBlocks : <String>['general'])
                          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (v) => setState(() => _lifeBlock = v ?? _lifeBlock),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              InputDecorator(
                decoration: const InputDecoration(labelText: 'Важность'),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _importance,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Низкая')),
                      DropdownMenuItem(value: 2, child: Text('Средняя')),
                      DropdownMenuItem(value: 3, child: Text('Высокая')),
                    ],
                    onChanged: (v) => setState(() => _importance = v ?? _importance),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _emotionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Эмоция (необязательно)',
                  prefixIcon: Icon(Icons.emoji_emotions_outlined),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Длительность, ч'),
                        Slider(
                          min: 0.5,
                          max: 14,
                          divisions: 27,
                          value: _hours,
                          label: _hours.toStringAsFixed(1),
                          onChanged: (v) => setState(() => _hours = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Начало'),
                      TextButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: Text(_start.format(context)),
                        onPressed: _pickTime,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Сохранить'),
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const SafeArea(top: false, child: SizedBox(height: 0)),
            ],
          ),
        ),
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
                    min: 0.5,
                    max: 14,
                    divisions: 27,
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
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2)),
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
