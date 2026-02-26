// lib/widgets/goals/add_day_goal_sheet.dart
import 'package:flutter/material.dart';
import 'package:nest_app/l10n/app_localizations.dart';

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

  // ✅ ограничиваем 1..3
  int _importance = 2;

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
            : 'general');
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
    if (picked != null) setState(() => _startTime = picked);
  }

  void _submit() {
    final l = AppLocalizations.of(context)!;

    if (_titleCtrl.text.trim().isEmpty) {
      final sm = ScaffoldMessenger.maybeOf(context);
      final scheme = Theme.of(context).colorScheme;
      sm?.showSnackBar(
        SnackBar(
          content: Text(
            l.addDayGoalEnterTitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: scheme.surfaceContainerHigh.withOpacity(0.92),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
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
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    final sheetSurface =
        (isDark ? scheme.surfaceContainerHigh : scheme.surface)
            .withOpacity(isDark ? 0.90 : 0.92);

    final borderColor = scheme.outlineVariant.withOpacity(isDark ? 0.65 : 0.55);

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.82,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        builder: (ctx, controller) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Container(
              decoration: BoxDecoration(
                color: sheetSurface,
                border: Border.all(color: borderColor),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.45),
                          blurRadius: 30,
                          offset: const Offset(0, -12),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: const Color(0xFF004A98).withOpacity(0.12),
                          blurRadius: 30,
                          offset: const Offset(0, -10),
                        ),
                      ],
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  Center(
                    child: Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: scheme.onSurfaceVariant
                            .withOpacity(isDark ? 0.28 : 0.20),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              scheme.primary.withOpacity(0.95),
                              scheme.primary.withOpacity(0.55),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: scheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l.addDayGoalTitle,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: scheme.onSurface,
                              ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _Section(
                    child: Column(
                      children: [
                        _PrettyField(
                          controller: _titleCtrl,
                          label: l.addDayGoalFieldTitle,
                          hint: l.addDayGoalTitleHint,
                          icon: Icons.flag_rounded,
                          // ✅ приятнее: 2 строки вместо жёсткого 1
                          minLines: 1,
                          maxLines: 2,
                          maxLen: 60,
                        ),
                        const SizedBox(height: 10),
                        _PrettyField(
                          controller: _descCtrl,
                          label: l.addDayGoalFieldDescription,
                          hint: l.addDayGoalDescriptionHint,
                          icon: Icons.notes_rounded,
                          minLines: 2,
                          maxLines: 4,
                          maxLen: 240,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  _Section(
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded, color: scheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l.addDayGoalStartTime,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: scheme.onSurface,
                                ),
                          ),
                        ),
                        _PillButton(
                          text: _startTime.format(context),
                          onTap: _pickStartTime,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (widget.fixedLifeBlock == null) ...[
                    _Section(
                      child: Row(
                        children: [
                          Icon(Icons.category_rounded, color: scheme.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l.addDayGoalLifeBlock,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: scheme.onSurface,
                                  ),
                            ),
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _lifeBlock,
                              dropdownColor: scheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(14),
                              items: (widget.availableBlocks.isEmpty
                                      ? const <String>['general']
                                      : widget.availableBlocks)
                                  .map(
                                    (b) => DropdownMenuItem(
                                      value: b,
                                      child: Text(
                                        b,
                                        style: TextStyle(color: scheme.onSurface),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _lifeBlock = v ?? _lifeBlock),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  _Section(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.addDayGoalImportance,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: scheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: List.generate(3, (i) {
                            final v = i + 1;
                            final selected = _importance == v;

                            return ChoiceChip(
                              label: Text('$v'),
                              selected: selected,
                              onSelected: (_) => setState(() => _importance = v),
                              selectedColor: scheme.primary.withOpacity(0.18),
                              backgroundColor:
                                  scheme.surfaceContainerHighest.withOpacity(0.75),
                              side: BorderSide(
                                color: selected
                                    ? scheme.primary.withOpacity(0.35)
                                    : scheme.outlineVariant.withOpacity(0.65),
                              ),
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: scheme.onSurface.withOpacity(
                                  selected ? 1 : 0.80,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  _Section(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.addDayGoalEmotion,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: scheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: _emotions.map((e) {
                            final selected = _emotion == e;
                            return ChoiceChip(
                              label: Text(e, style: const TextStyle(fontSize: 18)),
                              selected: selected,
                              onSelected: (_) => setState(() => _emotion = e),
                              selectedColor: scheme.primary.withOpacity(0.18),
                              backgroundColor:
                                  scheme.surfaceContainerHighest.withOpacity(0.75),
                              side: BorderSide(
                                color: selected
                                    ? scheme.primary.withOpacity(0.35)
                                    : scheme.outlineVariant.withOpacity(0.65),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  _Section(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l.addDayGoalHours,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: scheme.onSurface,
                                    ),
                              ),
                            ),
                            _Pill(text: _hours.toStringAsFixed(1)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          min: 0.5,
                          max: 14.0,
                          divisions: 27,
                          value: _hours,
                          onChanged: (v) => setState(() => _hours = v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l.commonCancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _submit,
                          child: Text(l.commonAdd),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final Widget child;
  const _Section({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark
        ? scheme.surfaceContainer.withOpacity(0.72)
        : scheme.surfaceContainerHigh.withOpacity(0.85);

    final border = scheme.outlineVariant.withOpacity(isDark ? 0.55 : 0.50);

    final shadow = isDark
        ? <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ]
        : <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF004A98).withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
        boxShadow: shadow,
      ),
      child: child,
    );
  }
}

class _PrettyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int minLines;
  final int maxLines;
  final int? maxLen;

  const _PrettyField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLen,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLen,
      textInputAction:
          maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: scheme.primary),
        labelText: label,
        hintText: hint,
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _PillButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: scheme.surfaceContainerHigh.withOpacity(isDark ? 0.90 : 0.95),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outlineVariant.withOpacity(isDark ? 0.65 : 0.55),
            ),
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: scheme.onSurface,
                ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh.withOpacity(isDark ? 0.90 : 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant.withOpacity(isDark ? 0.65 : 0.55),
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: scheme.onSurface,
            ),
      ),
    );
  }
}