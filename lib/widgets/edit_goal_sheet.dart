import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/goal.dart';
import 'add_day_goal_sheet.dart'; // AddGoalResult

class EditGoalSheet extends StatefulWidget {
  final Goal goal;
  final String? fixedLifeBlock;
  final List<String> availableBlocks;

  const EditGoalSheet({
    super.key,
    required this.goal,
    required this.fixedLifeBlock,
    required this.availableBlocks,
  });

  @override
  State<EditGoalSheet> createState() => _EditGoalSheetState();
}

class _EditGoalSheetState extends State<EditGoalSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _emotionCtrl;

  late String _lifeBlock;
  late int _importance; // 1..3
  late double _hours; // 0.5..14
  late TimeOfDay _start; // TimeOfDay

  List<String> _normalizeBlocks({
    required List<String> availableBlocks,
    String? fixedLifeBlock,
    String? currentValue,
  }) {
    final set = <String>{};

    if (fixedLifeBlock != null && fixedLifeBlock.trim().isNotEmpty) {
      set.add(fixedLifeBlock.trim());
    }

    for (final b in availableBlocks) {
      final v = b.trim();
      if (v.isNotEmpty) set.add(v);
    }

    if (currentValue != null && currentValue.trim().isNotEmpty) {
      set.add(currentValue.trim());
    }

    if (set.isEmpty) set.add('general');
    return set.toList();
  }

  @override
  void initState() {
    super.initState();
    final g = widget.goal;

    _titleCtrl = TextEditingController(text: g.title);
    _descCtrl = TextEditingController(text: g.description);
    _emotionCtrl = TextEditingController(text: g.emotion);

    final initialValue =
        widget.fixedLifeBlock ??
        g.lifeBlock ??
        (widget.availableBlocks.isNotEmpty
            ? widget.availableBlocks.first
            : 'general');

    final blocks = _normalizeBlocks(
      availableBlocks: widget.availableBlocks,
      fixedLifeBlock: widget.fixedLifeBlock,
      currentValue: initialValue,
    );

    _lifeBlock = blocks.contains(initialValue) ? initialValue : blocks.first;
    _importance = (g.importance).clamp(1, 3);
    _hours = (g.spentHours).clamp(0.5, 14.0);
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
    final title = _titleCtrl.text.trim().isEmpty
        ? 'Без названия'
        : _titleCtrl.text.trim();

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
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final canEditBlock = widget.fixedLifeBlock == null;

    final blocks = _normalizeBlocks(
      availableBlocks: widget.availableBlocks,
      fixedLifeBlock: widget.fixedLifeBlock,
      currentValue: _lifeBlock,
    );

    final dropdownValue = blocks.contains(_lifeBlock) ? _lifeBlock : null;

    final inputTheme = theme.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: const Color(0x6611121A),
      labelStyle: TextStyle(
        color: theme.colorScheme.onSurface.withOpacity(0.7),
      ),
      hintStyle: TextStyle(
        color: theme.colorScheme.onSurface.withOpacity(0.45),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
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
                const SizedBox(height: 14),

                Row(
                  children: [
                    _IconBubble(icon: Icons.edit_rounded),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Редактировать цель',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _titleCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Название',
                          hintText: 'Например: Пробежка 3 км',
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
                          hintText: 'Что именно нужно сделать?',
                          prefixIcon: Icon(Icons.notes_outlined),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                if (canEditBlock) ...[
                  _SectionCard(
                    child: DropdownButtonFormField<String>(
                      value: dropdownValue,
                      decoration: const InputDecoration(
                        labelText: 'Сфера/блок',
                        prefixIcon: Icon(Icons.grid_view_rounded),
                      ),
                      items: blocks
                          .map(
                            (b) => DropdownMenuItem<String>(
                              value: b,
                              child: Text(b),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _lifeBlock = v);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                _SectionCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _importance,
                          decoration: const InputDecoration(
                            labelText: 'Важность',
                            prefixIcon: Icon(
                              Icons.local_fire_department_rounded,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('Низкая')),
                            DropdownMenuItem(value: 2, child: Text('Средняя')),
                            DropdownMenuItem(value: 3, child: Text('Высокая')),
                          ],
                          onChanged: (v) =>
                              setState(() => _importance = v ?? _importance),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _emotionCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Эмоция',
                            hintText: '😊',
                            prefixIcon: Icon(Icons.emoji_emotions_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timelapse_rounded, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Длительность (ч)',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _ValuePill(text: _hours.toStringAsFixed(1)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3.5,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 18,
                          ),
                        ),
                        child: Slider(
                          min: 0.5,
                          max: 14,
                          divisions: 27,
                          value: _hours,
                          label: _hours.toStringAsFixed(1),
                          onChanged: (v) => setState(() => _hours = v),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Начало',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _PillButton(
                            label: _start.format(context),
                            icon: Icons.access_time_rounded,
                            onTap: _pickTime,
                          ),
                        ],
                      ),
                    ],
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
                        label: 'Сохранить',
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
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0x8011121A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0x22FFFFFF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 22,
                offset: Offset(0, 14),
              ),
              BoxShadow(
                color: Color(0x14FFFFFF),
                blurRadius: 18,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: child,
        ),
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
            color: Color(0x55000000),
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

class _ValuePill extends StatelessWidget {
  final String text;
  const _ValuePill({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0x7011121A),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
              color: theme.colorScheme.onSurface.withOpacity(0.9),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0x7011121A),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44000000),
                  blurRadius: 14,
                  offset: Offset(0, 8),
                ),
                BoxShadow(
                  color: Color(0x14FFFFFF),
                  blurRadius: 12,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.85),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: theme.colorScheme.onSurface.withOpacity(0.9),
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

    final bg = isPrimary ? null : const Color(0x7011121A);

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
            color: Colors.white.withOpacity(isPrimary ? 0.10 : 0.12),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 18,
              offset: Offset(0, 12),
            ),
            BoxShadow(
              color: Color(0x14FFFFFF),
              blurRadius: 14,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: isPrimary
                  ? Colors.white
                  : theme.colorScheme.onSurface.withOpacity(0.9),
            ),
          ),
        ),
      ),
    );
  }
}
