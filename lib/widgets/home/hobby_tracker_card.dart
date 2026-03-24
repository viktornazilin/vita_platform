
import 'package:flutter/material.dart';

import '../../services/home_trackers_repo.dart';
import '../report_section_card.dart';

class HobbyTrackerCard extends StatefulWidget {
  const HobbyTrackerCard({super.key});

  @override
  State<HobbyTrackerCard> createState() => _HobbyTrackerCardState();
}

class _HobbyTrackerCardState extends State<HobbyTrackerCard> {
  final _repo = HomeTrackersRepo();
  bool _loading = true;
  List<HobbySummary> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _repo.listHobbySummariesForWeek(DateTime.now());
      if (!mounted) return;
      setState(() => _items = items);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmtMinutes(int m) {
    final h = m ~/ 60;
    final min = m % 60;
    if (h == 0) return '${min}м';
    if (min == 0) return '${h}ч';
    return '${h}ч ${min}м';
  }

  Future<void> _showCreateHobbySheet() async {
    final titleCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Новое хобби',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Название хобби',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Введите хобби' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: targetCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Цель на неделю, минут',
                    ),
                    validator: (v) =>
                        (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Введите цель' : null,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (!(formKey.currentState?.validate() ?? false)) return;
                        await _repo.createHobby(
                          title: titleCtrl.text.trim(),
                          targetMinutesWeek: int.parse(targetCtrl.text.trim()),
                        );
                        if (!mounted) return;
                        Navigator.pop(ctx);
                        await _load();
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Создать'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddEntrySheet(HobbySummary hobby) async {
    final minutesCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Добавить время: ${hobby.hobbyTitle}',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: minutesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Сколько минут потратил',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Заметка',
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final minutes = int.tryParse(minutesCtrl.text.trim()) ?? 0;
                      if (minutes <= 0) return;
                      await _repo.addHobbyEntry(
                        hobbyId: hobby.hobbyId,
                        entryDate: DateTime.now(),
                        minutesSpent: minutes,
                        note: noteCtrl.text.trim(),
                      );
                      if (!mounted) return;
                      Navigator.pop(ctx);
                      await _load();
                    },
                    icon: const Icon(Icons.timer_rounded),
                    label: const Text('Сохранить'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteHobby(HobbySummary hobby) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Удалить хобби?'),
            content: Text('Хобби "${hobby.hobbyTitle}" будет удалено вместе со всеми записями.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Удалить'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;
    await _repo.deleteHobby(hobby.hobbyId);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ReportSectionCard(
      title: 'Трекер хобби',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: 'Добавить хобби',
              onPressed: _showCreateHobbySheet,
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
          ),
          if (_loading)
            const SizedBox(
              height: 96,
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else if (_items.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Пока нет хобби. Добавь первое направление и начни трекать время.',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _showCreateHobbySheet,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Создать хобби'),
                ),
              ],
            )
          else
            Column(
              children: [
                for (final hobby in _items) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.surface.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: cs.outlineVariant.withOpacity(0.65),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                hobby.hobbyTitle,
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _deleteHobby(hobby),
                              icon: const Icon(Icons.delete_outline_rounded),
                              tooltip: 'Удалить хобби',
                            ),
                            FilledButton.tonalIcon(
                              onPressed: () => _showAddEntrySheet(hobby),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Внести'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _InfoPill(
                              icon: Icons.today_rounded,
                              text: 'Сегодня ${_fmtMinutes(hobby.spentMinutesToday)}',
                            ),
                            _InfoPill(
                              icon: Icons.date_range_rounded,
                              text: 'Неделя ${_fmtMinutes(hobby.spentMinutesWeek)}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: hobby.weekProgress,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Цель: ${_fmtMinutes(hobby.targetMinutesWeek)}',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
    );
  }
}
