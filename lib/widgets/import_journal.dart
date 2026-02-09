import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/day_goals_model.dart';
import 'add_day_goal_sheet.dart'; // для AddGoalResult

/// Запускает импорт из фото страницы ежедневника.
/// Внутри: выбор фото → (опц.) загрузка в Supabase Storage → Google Vision OCR → парсинг → обзор и массовое добавление.
Future<void> importFromJournal(
  BuildContext context,
  DayGoalsModel vm, {
  required String visionApiKey,
}) async {
  try {
    final picker = ImagePicker();
    final platform = Theme.of(context).platform;
    final source =
        (platform == TargetPlatform.iOS || platform == TargetPlatform.android)
        ? ImageSource.camera
        : ImageSource.gallery;

    final file = await picker.pickImage(
      source: source,
      maxWidth: 2400,
      imageQuality: 92,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();

    // (опционально) сохраняем снимок в Supabase Storage
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

    // краткий лоадер
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }

    // OCR -> текст
    final ocrText = await _googleVisionOcr(bytes, visionApiKey: visionApiKey);

    if (context.mounted) Navigator.of(context).pop(); // закрыть лоадер

    // парсим в черновики задач
    final parsed = _visionParse(ocrText);

    // обзор/редактирование/выбор
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

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Добавлено целей: ${accepted.length}')),
    );
  } catch (e) {
    if (!context.mounted) return;
    // закрыть лоадер, если вдруг открыт
    Navigator.of(context, rootNavigator: true).maybePop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Не удалось импортировать: $e')));
  }
}

/// Вызов Google Cloud Vision (DOCUMENT_TEXT_DETECTION).
Future<String> _googleVisionOcr(
  Uint8List bytes, {
  required String visionApiKey,
}) async {
  if (visionApiKey.isEmpty) {
    throw 'VISION_API_KEY не задан. Запусти с --dart-define=VISION_API_KEY=...';
  }
  final uri = Uri.parse(
    'https://vision.googleapis.com/v1/images:annotate?key=$visionApiKey',
  );

  final payload = {
    "requests": [
      {
        "image": {"content": base64Encode(bytes)},
        "features": [
          {"type": "DOCUMENT_TEXT_DETECTION"},
        ],
        "imageContext": {
          "languageHints": ["ru", "en"],
        },
      },
    ],
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
  return (responses.first['fullTextAnnotation']?['text'] as String?) ?? '';
}

/// Простой парсер строк → AddGoalResult.
List<AddGoalResult> _visionParse(String fullText) {
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
  State<_ReviewParsedGoalsSheet> createState() =>
      _ReviewParsedGoalsSheetState();
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
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Время:'),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: ctx,
                      initialTime: time,
                    );
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
                SizedBox(
                  width: 48,
                  child: Text(
                    hours.toStringAsFixed(1),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
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
              setState(() {
                items[i] = items[i].copyWith(
                  data: AddGoalResult(
                    title: titleCtrl.text.trim().isEmpty
                        ? 'Без названия'
                        : titleCtrl.text.trim(),
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
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Найденные задачи',
              style: Theme.of(context).textTheme.titleMedium,
            ),
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
                      onChanged: (v) => setState(
                        () => items[i] = it.copyWith(accepted: v ?? true),
                      ),
                    ),
                    title: Text(d.title),
                    subtitle: Text(
                      '${d.startTime.format(context)} • ${d.hours.toStringAsFixed(1)} ч',
                    ),
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
                          final accepted = items
                              .where((e) => e.accepted)
                              .map((e) => e.data)
                              .toList();
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
      _EditableParsed(
        accepted: accepted ?? this.accepted,
        data: data ?? this.data,
      );
}
