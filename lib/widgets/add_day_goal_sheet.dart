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
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название')),
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
    final bottom = MediaQuery.of(context).viewInsets.bottom;

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
                color: Colors.white.withOpacity(0.94),
                border: Border.all(color: const Color(0xFFD6E6F5)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A2B5B7A),
                    blurRadius: 30,
                    offset: Offset(0, -10),
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
                        color: const Color(0xFF9BC7E6).withOpacity(0.55),
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
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF3AA8E6), Color(0xFF7DD3FC)],
                          ),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Новая цель на день',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF2E4B5A),
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
                          label: 'Название *',
                          hint: 'Например: Тренировка / Работа / Учёба',
                          icon: Icons.flag_rounded,
                        ),
                        const SizedBox(height: 10),
                        _PrettyField(
                          controller: _descCtrl,
                          label: 'Описание',
                          hint: 'Коротко: что именно нужно сделать',
                          icon: Icons.notes_rounded,
                          minLines: 2,
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  _Section(
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded, color: Color(0xFF3AA8E6)),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Время начала',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2E4B5A),
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
                          const Icon(Icons.category_rounded, color: Color(0xFF3AA8E6)),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Сфера жизни',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2E4B5A),
                              ),
                            ),
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _lifeBlock,
                              items: (widget.availableBlocks.isEmpty
                                      ? const <String>['general']
                                      : widget.availableBlocks)
                                  .map(
                                    (b) => DropdownMenuItem(
                                      value: b,
                                      child: Text(b),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => _lifeBlock = v ?? _lifeBlock),
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
                        const Text(
                          'Важность',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2E4B5A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: List.generate(5, (i) {
                            final v = i + 1;
                            final selected = _importance == v;
                            return ChoiceChip(
                              label: Text('$v'),
                              selected: selected,
                              onSelected: (_) => setState(() => _importance = v),
                              selectedColor: const Color(0xFF3AA8E6).withOpacity(0.18),
                              backgroundColor: const Color(0xFFF4FAFF),
                              side: BorderSide(
                                color: selected
                                    ? const Color(0xFF3AA8E6).withOpacity(0.35)
                                    : const Color(0xFFD6E6F5),
                              ),
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF2E4B5A).withOpacity(selected ? 1 : 0.75),
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
                        const Text(
                          'Эмоция',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2E4B5A),
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
                              selectedColor: const Color(0xFF3AA8E6).withOpacity(0.18),
                              backgroundColor: const Color(0xFFF4FAFF),
                              side: BorderSide(
                                color: selected
                                    ? const Color(0xFF3AA8E6).withOpacity(0.35)
                                    : const Color(0xFFD6E6F5),
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
                            const Expanded(
                              child: Text(
                                'Часы',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2E4B5A),
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
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            side: const BorderSide(color: Color(0xFFD6E6F5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Отмена',
                            style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2E4B5A)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3AA8E6),
                            foregroundColor: Colors.white,
                            elevation: 10,
                            shadowColor: const Color(0x334AAAE6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Добавить',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD6E6F5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F2B5B7A),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
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

  const _PrettyField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF3AA8E6)),
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD6E6F5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD6E6F5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: const Color(0xFF3AA8E6).withOpacity(0.6), width: 1.4),
        ),
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD6E6F5)),
          ),
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2E4B5A)),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6E6F5)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2E4B5A)),
      ),
    );
  }
}
