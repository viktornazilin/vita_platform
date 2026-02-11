import 'dart:ui';
import 'package:flutter/material.dart';

import '../widgets/nest_sheet.dart';
import '../widgets/nest_card.dart';
import '../widgets/nest_pill.dart';
import '../widgets/nest_section_title.dart';

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
        : '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}',
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

  // Контроллеры, чтобы не пересоздавать на каждый build
  late final List<TextEditingController> _titleCtrls;
  late final List<TextEditingController> _descCtrls;

  @override
  void initState() {
    super.initState();
    _drafts = List.of(widget.items);
    _checked = List<bool>.filled(_drafts.length, true);
    _titleCtrls = List.generate(
      _drafts.length,
      (i) => TextEditingController(text: _drafts[i].title),
    );
    _descCtrls = List.generate(
      _drafts.length,
      (i) => TextEditingController(text: _drafts[i].description ?? ''),
    );
  }

  @override
  void dispose() {
    for (final c in _titleCtrls) {
      c.dispose();
    }
    for (final c in _descCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickTime(int i) async {
    final current = _drafts[i].startTime ?? const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked == null) return;
    setState(() => _drafts[i] = _drafts[i].copyWith(startTime: picked));
  }

  void _toggleAll(bool v) {
    setState(() {
      for (var i = 0; i < _checked.length; i++) {
        _checked[i] = v;
      }
    });
  }

  void _submit() {
    final result = <ParsedGoalDraft>[];
    for (int i = 0; i < _drafts.length; i++) {
      final title = _drafts[i].title.trim();
      if (_checked[i] && title.isNotEmpty) {
        result.add(_drafts[i].copyWith(title: title));
      }
    }
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final selected = _checked.where((e) => e).length;

    final inputTheme = theme.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: const Color(0xFFEFF7FF).withOpacity(0.85),
      labelStyle: const TextStyle(color: Color(0xFF2E4B5A)),
      hintStyle: const TextStyle(color: Color(0x992E4B5A)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFBBD9F7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFBBD9F7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.55),
          width: 1.4,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );

    return Theme(
      data: theme.copyWith(inputDecorationTheme: inputTheme),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: NestSheet(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.88,
            minChildSize: 0.62,
            maxChildSize: 0.96,
            builder: (ctx, controller) => SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 4),
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _IconBubble(icon: Icons.download_rounded),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Импортировать цели',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                            color: const Color(0xFF2E4B5A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      NestPill(
                        leading: Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        text: '$selected/${_drafts.length}',
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Отметь, что импортировать, и при необходимости поправь название/описание.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF2E4B5A).withOpacity(0.75),
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 14),

                  NestCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Выбрать всё',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2E4B5A),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _toggleAll(true),
                          child: const Text('Да'),
                        ),
                        TextButton(
                          onPressed: () => _toggleAll(false),
                          child: const Text('Нет'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  const NestSectionTitle('Список'),

                  ListView.separated(
                    controller: controller,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _drafts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _DraftTile(
                      checked: _checked[i],
                      onChecked: (v) => setState(() => _checked[i] = v ?? true),
                      titleCtrl: _titleCtrls[i],
                      descCtrl: _descCtrls[i],
                      timeText: _fmtTod(_drafts[i].startTime),
                      onTimeTap: () => _pickTime(i),
                      onTitleChanged: (v) =>
                          _drafts[i] = _drafts[i].copyWith(title: v),
                      onDescChanged: (v) =>
                          _drafts[i] = _drafts[i].copyWith(description: v),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _SoftButton(
                          label: 'Отмена',
                          kind: _SoftButtonKind.secondary,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SoftButton(
                          label: 'Импортировать',
                          kind: _SoftButtonKind.primary,
                          onTap: _submit,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  const SafeArea(top: false, child: SizedBox(height: 0)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _fmtTod(TimeOfDay? t) => t == null
      ? '—'
      : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class _DraftTile extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool?> onChecked;

  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;

  final String timeText;
  final VoidCallback onTimeTap;

  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescChanged;

  const _DraftTile({
    required this.checked,
    required this.onChecked,
    required this.titleCtrl,
    required this.descCtrl,
    required this.timeText,
    required this.onTimeTap,
    required this.onTitleChanged,
    required this.onDescChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NestCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Checkbox(value: checked, onChanged: onChecked),
              Expanded(
                child: TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Название',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  onChanged: onTitleChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Описание',
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: onDescChanged,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              NestPill(
                leading: const Icon(Icons.schedule_rounded, size: 16),
                text: 'Время: $timeText',
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onTimeTap,
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Изменить'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  const _IconBubble({required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.95),
            theme.colorScheme.primary.withOpacity(0.55),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A2B5B7A),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x22FFFFFF),
            blurRadius: 14,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}

enum _SoftButtonKind { primary, secondary }

class _SoftButton extends StatelessWidget {
  final String label;
  final _SoftButtonKind kind;
  final VoidCallback onTap;

  const _SoftButton({
    required this.label,
    required this.kind,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPrimary = kind == _SoftButtonKind.primary;

    final bg = isPrimary ? null : Colors.white.withOpacity(0.70);

    final gradient = isPrimary
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.95),
              theme.colorScheme.primary.withOpacity(0.55),
            ],
          )
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: bg,
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isPrimary
                ? Colors.white.withOpacity(0.10)
                : const Color(0xFFD6E6F5),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A2B5B7A),
              blurRadius: 18,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: isPrimary ? Colors.white : const Color(0xFF2E4B5A),
            ),
          ),
        ),
      ),
    );
  }
}
