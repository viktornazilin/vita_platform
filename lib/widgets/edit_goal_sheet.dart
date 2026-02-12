// lib/widgets/edit_goal_sheet.dart
import 'dart:ui';
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
    final list = set.toList();
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
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
    final picked = await showTimePicker(
      context: context,
      initialTime: _start,
      builder: (ctx, child) {
        // чуть ближе к Nest-палитре
        final t = Theme.of(ctx);
        return Theme(
          data: t.copyWith(
            colorScheme: t.colorScheme.copyWith(
              primary: const Color(0xFF3AA8E6),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _start = picked);
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
      filled: true,
      fillColor: const Color(0xFFEFF7FF),
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
        borderSide: const BorderSide(color: Color(0xFF3AA8E6), width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final canEditBlock = widget.fixedLifeBlock == null;

    final blocks = _normalizeBlocks(
      availableBlocks: widget.availableBlocks,
      fixedLifeBlock: widget.fixedLifeBlock,
      currentValue: _lifeBlock,
    );

    final dropdownValue = blocks.contains(_lifeBlock)
        ? _lifeBlock
        : blocks.first;

    return Padding(
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
                    color: const Color(0xFF9BC7E6).withOpacity(0.55),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  const _IconBubble(icon: Icons.edit_rounded),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t.editGoalTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2E4B5A),
                        height: 1.05,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              NestSectionTitle(t.editGoalSectionDetails),
              NestCard(
                padding: const EdgeInsets.all(14),
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
                NestSectionTitle(t.editGoalSectionLifeBlock),
                NestCard(
                  padding: const EdgeInsets.all(14),
                  child: DropdownButtonFormField<String>(
                    value: dropdownValue,
                    decoration: _nestInput(
                      label: t.editGoalFieldLifeBlockLabel,
                      icon: Icons.grid_view_rounded,
                    ),
                    items: blocks
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _lifeBlock = v);
                    },
                  ),
                ),
              ],

              NestSectionTitle(t.editGoalSectionParams),
              NestCard(
                padding: const EdgeInsets.all(14),
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
                            onChanged: (v) =>
                                setState(() => _importance = v ?? _importance),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _emotionCtrl,
                            decoration: _nestInput(
                              label: t.editGoalFieldEmotionLabel,
                              hint: t.editGoalFieldEmotionHint,
                              icon: Icons.emoji_emotions_outlined,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        const Icon(
                          Icons.timelapse_rounded,
                          size: 18,
                          color: Color(0xFF2E4B5A),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            t.editGoalDurationHours,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2E4B5A),
                            ),
                          ),
                        ),
                        NestPill(
                          leading: const Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: Color(0xFF2E4B5A),
                          ),
                          text: _hours.toStringAsFixed(1),
                        ),
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

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 18,
                          color: Color(0xFF2E4B5A),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            t.editGoalStartTime,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2E4B5A),
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
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3AA8E6), Color(0xFF6C8CFF)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F2B5B7A),
            blurRadius: 16,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 18),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF7FF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFBBD9F7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF2E4B5A)),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E4B5A),
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
      height: 46,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: isPrimary ? 6 : 0,
          backgroundColor: isPrimary
              ? const Color(0xFF3AA8E6)
              : const Color(0xFFEFF7FF),
          foregroundColor: isPrimary ? Colors.white : const Color(0xFF2E4B5A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          side: const BorderSide(color: Color(0xFFBBD9F7)),
        ),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
