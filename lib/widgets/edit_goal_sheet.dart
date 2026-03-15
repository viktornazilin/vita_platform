// lib/widgets/edit_goal_sheet.dart
import 'package:flutter/material.dart';
import 'package:nest_app/l10n/app_localizations.dart';

import '../models/goal.dart';
import 'add_day_goal_sheet.dart'; // AddGoalResult

import 'nest/nest_card.dart';
import 'nest/nest_pill.dart';
import 'nest/nest_section_title.dart';

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
  late TimeOfDay _start;

  List<String> _normalizeBlocks({
    required List<String> availableBlocks,
    String? fixedLifeBlock,
    String? currentValue,
  }) {
    final seen = <String>{};
    final list = <String>['general'];

    void addValue(String? value) {
      final v = value?.trim();
      if (v == null || v.isEmpty) return;
      final key = v.toLowerCase();
      if (key == 'general') return;
      if (seen.add(key)) list.add(v);
    }

    addValue(fixedLifeBlock);

    for (final b in availableBlocks) {
      addValue(b);
    }

    addValue(currentValue);

    return list;
  }

  String _lifeBlockLabel(String value) {
    return value.toLowerCase() == 'general' ? 'General' : value;
  }

  @override
  void initState() {
    super.initState();
    final g = widget.goal;

    _titleCtrl = TextEditingController(text: g.title);
    _descCtrl = TextEditingController(text: g.description);
    _emotionCtrl = TextEditingController(text: g.emotion);

    final initialValue = (widget.fixedLifeBlock?.trim().isNotEmpty ?? false)
        ? widget.fixedLifeBlock!.trim()
        : ((g.lifeBlock?.trim().isNotEmpty ?? false)
              ? g.lifeBlock!.trim()
              : 'general');

    final blocks = _normalizeBlocks(
      availableBlocks: widget.availableBlocks,
      fixedLifeBlock: widget.fixedLifeBlock,
      currentValue: initialValue,
    );

    _lifeBlock = blocks.contains(initialValue) ? initialValue : 'general';
    _importance = g.importance.clamp(1, 3);
    _hours = g.spentHours.clamp(0.5, 14.0);
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
    final picked = await showTimePicker(
      context: context,
      initialTime: _start,
      builder: (ctx, child) {
        final t = Theme.of(ctx);
        return Theme(
          data: t.copyWith(
            colorScheme: t.colorScheme.copyWith(
              primary: t.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _start = picked);
    }
  }

  void _submit() {
    final t = AppLocalizations.of(context)!;

    final title = _titleCtrl.text.trim().isEmpty
        ? t.editGoalUntitled
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

  InputDecoration _nestInput({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final canEditBlock = widget.fixedLifeBlock == null;

    final blocks = _normalizeBlocks(
      availableBlocks: widget.availableBlocks,
      fixedLifeBlock: widget.fixedLifeBlock,
      currentValue: _lifeBlock,
    );

    final dropdownValue = blocks.contains(_lifeBlock) ? _lifeBlock : 'general';

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        minChildSize: 0.62,
        maxChildSize: 0.96,
        builder: (ctx, controller) {
          return SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 4),
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: scheme.outline.withOpacity(0.72),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    const _IconBubble(icon: Icons.edit_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t.editGoalTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                          height: 1.05,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                NestSectionTitle(t.editGoalSectionDetails),
                NestCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _titleCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: _nestInput(
                          label: t.editGoalFieldTitleLabel,
                          hint: t.editGoalFieldTitleHint,
                          icon: Icons.flag_outlined,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descCtrl,
                        minLines: 2,
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                        decoration: _nestInput(
                          label: t.editGoalFieldDescLabel,
                          hint: t.editGoalFieldDescHint,
                          icon: Icons.notes_outlined,
                        ),
                      ),
                    ],
                  ),
                ),

                if (canEditBlock) ...[
                  const SizedBox(height: 2),
                  NestSectionTitle(t.editGoalSectionLifeBlock),
                  NestCard(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<String>(
                      value: dropdownValue,
                      decoration: _nestInput(
                        label: t.editGoalFieldLifeBlockLabel,
                        icon: Icons.grid_view_rounded,
                      ),
                      items: blocks
                          .map(
                            (b) => DropdownMenuItem<String>(
                              value: b,
                              child: Text(_lifeBlockLabel(b)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _lifeBlock = v);
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 2),
                NestSectionTitle(t.editGoalSectionParams),
                NestCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _importance,
                              decoration: _nestInput(
                                label: t.editGoalFieldImportanceLabel,
                                icon: Icons.local_fire_department_rounded,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text(t.editGoalImportanceLow),
                                ),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Text(t.editGoalImportanceMedium),
                                ),
                                DropdownMenuItem(
                                  value: 3,
                                  child: Text(t.editGoalImportanceHigh),
                                ),
                              ],
                              onChanged: (v) {
                                setState(() => _importance = v ?? _importance);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _emotionCtrl,
                              textInputAction: TextInputAction.done,
                              decoration: _nestInput(
                                label: t.editGoalFieldEmotionLabel,
                                hint: t.editGoalFieldEmotionHint,
                                icon: Icons.emoji_emotions_outlined,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          Icon(
                            Icons.timelapse_rounded,
                            size: 18,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              t.editGoalDurationHours,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                          NestPill(
                            leading: const Icon(
                              Icons.timer_outlined,
                              size: 16,
                            ),
                            text: _hours.toStringAsFixed(1),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

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

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 18,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              t.editGoalStartTime,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
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

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _SoftButton(
                        label: t.commonCancel,
                        kind: _SoftButtonKind.secondary,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SoftButton(
                        label: t.commonSave,
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
          );
        },
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;

  const _IconBubble({required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Icon(
        icon,
        color: scheme.onSurface,
        size: 18,
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
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: scheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
            ),
          ],
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
    final isPrimary = kind == _SoftButtonKind.primary;

    return SizedBox(
      height: 48,
      child: isPrimary
          ? FilledButton(
              onPressed: onTap,
              child: Text(label),
            )
          : OutlinedButton(
              onPressed: onTap,
              child: Text(label),
            ),
    );
  }
}