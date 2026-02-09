import 'dart:ui';
import 'package:flutter/material.dart';

class AddGoalResult {
  final String title;
  final String description;
  final String lifeBlock;
  final int importance;
  final String emotion;
  final double hours;
  final TimeOfDay startTime;

  AddGoalResult({
    required this.title,
    required this.description,
    required this.lifeBlock,
    required this.importance,
    required this.emotion,
    required this.hours,
    required this.startTime,
  });
}

class AddDayGoalSheet extends StatefulWidget {
  final String? fixedLifeBlock;
  final List<String> availableBlocks;

  const AddDayGoalSheet({
    super.key,
    required this.fixedLifeBlock,
    this.availableBlocks = const [],
  });

  @override
  State<AddDayGoalSheet> createState() => _AddDayGoalSheetState();
}

class _AddDayGoalSheetState extends State<AddDayGoalSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final _emotions = const ['😊', '😐', '😢', '😎', '😤', '🤔', '😴', '😇'];
  String _emotion = '😊';
  int _importance = 1;
  double _hours = 1.0;
  late String _lifeBlock;

  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _lifeBlock =
        widget.fixedLifeBlock ??
        (widget.availableBlocks.isNotEmpty
            ? widget.availableBlocks.first
            : 'health');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите название')));
      return;
    }

    Navigator.pop(
      context,
      AddGoalResult(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        lifeBlock: _lifeBlock,
        importance: _importance,
        emotion: _emotion,
        hours: _hours,
        startTime: _startTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // Унифицированный стиль инпутов под “glass”
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
        padding: EdgeInsets.only(
          left: 14,
          right: 14,
          top: 10,
          bottom: bottomInset + 14,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
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

              // Заголовок
              Row(
                children: [
                  _IconBubble(icon: Icons.add_task_rounded),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Новая цель на день',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Карточка-секция (glass)
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _titleCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Название *',
                        hintText: 'Например: Тренировка 5 км',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descCtrl,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Описание (опционально)',
                        hintText: 'Кратко опиши задачу',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Время начала (как отдельный “премиум” блок)
              _SectionCard(
                child: Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Время начала',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _PillButton(
                      label: _startTime.format(context),
                      icon: Icons.access_time_rounded,
                      onTap: _pickStartTime,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              if (widget.fixedLifeBlock == null) ...[
                _SectionCard(
                  child: DropdownButtonFormField<String>(
                    initialValue: _lifeBlock,
                    decoration: const InputDecoration(labelText: 'Сфера жизни'),
                    items:
                        (widget.availableBlocks.isEmpty
                                ? <String>['health']
                                : widget.availableBlocks)
                            .map(
                              (b) => DropdownMenuItem(value: b, child: Text(b)),
                            )
                            .toList(),
                    onChanged: (v) =>
                        setState(() => _lifeBlock = v ?? _lifeBlock),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Важность + эмоция
              _SectionCard(
                child: Row(
                  children: [
                    Expanded(
                      child: _LabeledDropdown<int>(
                        label: 'Важность',
                        value: _importance,
                        items: List.generate(5, (i) => i + 1),
                        itemLabel: (v) => '$v',
                        onChanged: (v) =>
                            setState(() => _importance = v ?? _importance),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LabeledDropdown<String>(
                        label: 'Эмоция',
                        value: _emotion,
                        items: _emotions,
                        itemLabel: (v) => v,
                        onChanged: (v) =>
                            setState(() => _emotion = v ?? _emotion),
                        itemBuilder: (ctx, v) =>
                            Text(v, style: const TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Часы (slider)
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
                            'Часы',
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
                        max: 14.0,
                        divisions: 27,
                        value: _hours,
                        label: _hours.toStringAsFixed(1),
                        onChanged: (v) => setState(() => _hours = v),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Кнопки
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
                      label: 'Добавить',
                      kind: _SoftButtonKind.primary,
                      onTap: _submit,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
            ],
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
      child: const Icon(
        Icons.auto_awesome_rounded,
        color: Colors.white,
        size: 18,
      ),
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

class _LabeledDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final Widget Function(BuildContext, T)? itemBuilder;

  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface.withOpacity(0.75),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          decoration: const InputDecoration(isDense: true),
          items: items
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e,
                  child: itemBuilder?.call(context, e) ?? Text(itemLabel(e)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
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
