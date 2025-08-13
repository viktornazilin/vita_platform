import 'package:flutter/material.dart';

class ParsedGoalDraft {
  final String title;
  final String? description;
  final String? lifeBlock;
  final int? importance;
  final String? emotion;
  final double? hours;
  final TimeOfDay? startTime;

  ParsedGoalDraft({
    required this.title,
    this.description,
    this.lifeBlock,
    this.importance,
    this.emotion,
    this.hours,
    this.startTime,
  });

  factory ParsedGoalDraft.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parseTod(String? s) {
      if (s == null || s.isEmpty) return null;
      final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(s);
      if (m == null) return null;
      final h = int.tryParse(m.group(1)!);
      final mi = int.tryParse(m.group(2)!);
      if (h == null || mi == null) return null;
      return TimeOfDay(hour: h.clamp(0, 23), minute: mi.clamp(0, 59));
    }

    return ParsedGoalDraft(
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      lifeBlock: json['lifeBlock'] as String?,
      importance: json['importance'] as int?,
      emotion: json['emotion'] as String?,
      hours: (json['hours'] is num) ? (json['hours'] as num).toDouble() : null,
      startTime: parseTod(json['startTime'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'lifeBlock': lifeBlock,
    'importance': importance,
    'emotion': emotion,
    'hours': hours,
    'startTime': startTime == null
        ? null
        : '${startTime!.hour.toString().padLeft(2,'0')}:${startTime!.minute.toString().padLeft(2,'0')}',
  };

  ParsedGoalDraft copyWith({
    String? title,
    String? description,
    String? lifeBlock,
    int? importance,
    String? emotion,
    double? hours,
    TimeOfDay? startTime,
  }) => ParsedGoalDraft(
    title: title ?? this.title,
    description: description ?? this.description,
    lifeBlock: lifeBlock ?? this.lifeBlock,
    importance: importance ?? this.importance,
    emotion: emotion ?? this.emotion,
    hours: hours ?? this.hours,
    startTime: startTime ?? this.startTime,
  );
}

class ImportGoalsReviewSheet extends StatefulWidget {
  final List<ParsedGoalDraft> items;
  const ImportGoalsReviewSheet({super.key, required this.items});

  @override
  State<ImportGoalsReviewSheet> createState() => _ImportGoalsReviewSheetState();
}

class _ImportGoalsReviewSheetState extends State<ImportGoalsReviewSheet> {
  late List<bool> _checked;
  late List<ParsedGoalDraft> _drafts;

  @override
  void initState() {
    super.initState();
    _drafts = List.of(widget.items);
    _checked = List<bool>.filled(_drafts.length, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Импортировать цели', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _drafts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final d = _drafts[i];
                final titleCtrl = TextEditingController(text: d.title);
                final descCtrl = TextEditingController(text: d.description ?? '');
                return StatefulBuilder(
                  builder: (ctx, setInner) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _checked[i],
                                onChanged: (v) => setState(() => _checked[i] = v ?? true),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: titleCtrl,
                                  decoration: const InputDecoration(labelText: 'Название'),
                                  onChanged: (v) => _drafts[i] = _drafts[i].copyWith(title: v),
                                ),
                              ),
                            ],
                          ),
                          TextField(
                            controller: descCtrl,
                            decoration: const InputDecoration(labelText: 'Описание'),
                            onChanged: (v) => _drafts[i] = _drafts[i].copyWith(description: v),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text('Время: ${_fmtTod(d.startTime)}'),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: d.startTime ?? const TimeOfDay(hour: 9, minute: 0),
                                  );
                                  if (picked != null) {
                                    setState(() => _drafts[i] = _drafts[i].copyWith(startTime: picked));
                                  }
                                },
                                child: const Text('Изменить'),
                              ),
                              const Spacer(),
                              // Можно добавить поля lifeBlock, importance, hours, emotion при желании
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
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
                child: FilledButton(
                  onPressed: () {
                    final result = <ParsedGoalDraft>[];
                    for (int i = 0; i < _drafts.length; i++) {
                      if (_checked[i] && _drafts[i].title.trim().isNotEmpty) {
                        result.add(_drafts[i]);
                      }
                    }
                    Navigator.pop(context, result);
                  },
                  child: const Text('Импортировать выбранные'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtTod(TimeOfDay? t) =>
      t == null ? '—' : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
