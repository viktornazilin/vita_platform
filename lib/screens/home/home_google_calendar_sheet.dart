import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;

import '../../main.dart'; // dbRepo
import '../../models/goals_calendar_model.dart';
import '../../services/google_calendar_service.dart';

enum _SyncMode { import, export }

enum _RangePreset { today, next7, next30, custom }

class HomeGoogleCalendarSheet extends StatefulWidget {
  const HomeGoogleCalendarSheet({super.key});

  @override
  State<HomeGoogleCalendarSheet> createState() =>
      _HomeGoogleCalendarSheetState();
}

class _HomeGoogleCalendarSheetState extends State<HomeGoogleCalendarSheet> {
  final GoogleCalendarService _service = GoogleCalendarService();

  bool _loading = false;
  String? _error;

  // calendars + selection
  List<gcal.CalendarListEntry> _calendars = const [];
  String _calendarId = 'primary';

  // import: events + selection
  List<gcal.Event> _events = const [];
  final Set<String> _selectedEventIds = {};
  final Map<String, String> _lifeBlockByEventId = {}; // eventId -> lifeBlock

  // life blocks
  List<String> _lifeBlocks = const [];
  String _defaultLifeBlock = 'General';

  // mode + period
  _SyncMode _mode = _SyncMode.import;
  _RangePreset _preset = _RangePreset.next30;
  DateTimeRange? _customRange;

  bool get _connected => _service.isConnected;

  @override
  void initState() {
    super.initState();
    _loadLifeBlocks();
  }

  Future<void> _loadLifeBlocks() async {
    try {
      final gm = GoalsCalendarModel();
      await gm.loadBlocks();
      final blocks = gm.lifeBlocks;

      if (!mounted) return;
      setState(() {
        _lifeBlocks = blocks.isNotEmpty ? blocks : const ['General'];
        _defaultLifeBlock = _lifeBlocks.first;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _lifeBlocks = const ['General'];
        _defaultLifeBlock = 'General';
      });
    }
  }

  // -------------------------------
  // Date helpers
  // -------------------------------

  DateTime? _eventDateTime(gcal.EventDateTime? edt) =>
      edt?.dateTime ?? edt?.date;

  DateTime? _eventStart(gcal.Event e) => _eventDateTime(e.start)?.toLocal();

  DateTime? _eventEnd(gcal.Event e) {
    final end = e.end;
    if (end == null) return null;

    final dt = _eventDateTime(end);
    if (dt == null) return null;

    final isAllDay = end.date != null && end.dateTime == null;
    if (isAllDay) return dt.subtract(const Duration(seconds: 1)).toLocal();

    return dt.toLocal();
  }

  String _fmtDateTime(BuildContext context, DateTime d) {
    final loc = MaterialLocalizations.of(context);
    final date = loc.formatShortMonthDay(d);
    final time = loc.formatTimeOfDay(TimeOfDay.fromDateTime(d));
    return '$date • $time';
  }

  String _fmtRange(BuildContext context, gcal.Event e) {
    final st = _eventStart(e);
    final en = _eventEnd(e);
    if (st == null) return '';
    if (en == null) return _fmtDateTime(context, st);
    return '${_fmtDateTime(context, st)} – ${_fmtDateTime(context, en)}';
  }

  DateTimeRange _resolveRange() {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);

    switch (_preset) {
      case _RangePreset.today:
        return DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 1)),
        );
      case _RangePreset.next7:
        return DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 7)),
        );
      case _RangePreset.next30:
        return DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 30)),
        );
      case _RangePreset.custom:
        return _customRange ??
            DateTimeRange(
              start: today,
              end: today.add(const Duration(days: 7)),
            );
    }
  }

  // -------------------------------
  // Google connect + load calendars
  // -------------------------------

  Future<void> _connect() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _service.connect();

      final calendars = await _service.listCalendars();
      if (!mounted) return;
      setState(() {
        _calendars = calendars;

        final primary = calendars.where((c) => (c.primary ?? false)).toList();
        if (primary.isNotEmpty && (primary.first.id?.isNotEmpty ?? false)) {
          _calendarId = primary.first.id!;
        } else {
          _calendarId = 'primary';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // -------------------------------
  // Import: load events
  // -------------------------------

  Future<void> _findEvents() async {
    setState(() {
      _loading = true;
      _error = null;
      _events = const [];
      _selectedEventIds.clear();
      _lifeBlockByEventId.clear();
    });

    try {
      final range = _resolveRange();

      final items = await _service.listEvents(
        calendarId: _calendarId,
        timeMin: range.start,
        timeMax: range.end,
      );

      final filtered = items.where((e) {
        final st = _eventDateTime(e.start);
        return (e.summary?.trim().isNotEmpty ?? false) && st != null;
      }).toList();

      final def = _defaultLifeBlock;
      for (final e in filtered) {
        final id = e.id;
        if (id == null) continue;
        _lifeBlockByEventId[id] = def;
      }

      if (!mounted) return;
      setState(() => _events = filtered);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // -------------------------------
  // Import: create goals
  // -------------------------------

  Future<void> _importSelected() async {
    if (_selectedEventIds.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      int created = 0;

      for (final e in _events) {
        final id = e.id;
        if (id == null || !_selectedEventIds.contains(id)) continue;

        final start = _eventStart(e);
        if (start == null) continue;

        final end = _eventEnd(e) ?? start.add(const Duration(hours: 1));
        final deadline = DateTime(end.year, end.month, end.day, 23, 59);

        final title = (e.summary ?? 'Без названия').trim();
        final description = (e.description ?? '').trim();
        final block = _lifeBlockByEventId[id] ?? _defaultLifeBlock;

        await dbRepo.createGoal(
          title: title,
          description: description,
          deadline: deadline,
          lifeBlock: block,
          importance: 1,
          emotion: '',
          spentHours: 0,
          startTime: start,
        );

        created++;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Импортировано целей: $created')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // -------------------------------
  // Export: goals -> Google Calendar
  // -------------------------------

  Future<void> _exportGoalsToCalendar() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final range = _resolveRange();

      final goals = await dbRepo.fetchGoalsInRange(
        start: range.start,
        end: range.end,
      );

      int exported = 0;
      for (final g in goals) {
        final st = g.startTime.toLocal();
        final en = st.add(const Duration(hours: 1)); // MVP

        await _service.upsertEvent(
          calendarId: _calendarId,
          summary: g.title,
          description: g.description,
          start: st,
          end: en,
          timeZone: 'Europe/Berlin',
          // eventId: g.gcalEventId (если добавишь в модель)
          extendedPrivateTags: ['vita_goal_id=${g.id}'],
        );

        exported++;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Экспортировано целей: $exported')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // -------------------------------
  // UI helpers
  // -------------------------------

  Widget _lifeBlockDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
    String? label,
    bool dense = false,
  }) {
    final blocks = _lifeBlocks.isNotEmpty ? _lifeBlocks : const ['General'];
    final safeValue = blocks.contains(value) ? value : blocks.first;

    return DropdownButtonFormField<String>(
      value: safeValue,
      items: blocks
          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
          .toList(),
      onChanged: _loading ? null : onChanged,
      isDense: dense,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: dense
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
            : null,
      ),
    );
  }

  Widget _rangeDropdown() {
    return DropdownButtonFormField<_RangePreset>(
      value: _preset,
      items: const [
        DropdownMenuItem(value: _RangePreset.today, child: Text('Сегодня')),
        DropdownMenuItem(
          value: _RangePreset.next7,
          child: Text('Следующие 7 дней'),
        ),
        DropdownMenuItem(
          value: _RangePreset.next30,
          child: Text('Следующие 30 дней'),
        ),
        DropdownMenuItem(
          value: _RangePreset.custom,
          child: Text('Выбрать период...'),
        ),
      ],
      onChanged: _loading
          ? null
          : (v) async {
              if (v == null) return;

              if (v == _RangePreset.custom) {
                final now = DateTime.now();
                final init =
                    _customRange ??
                    DateTimeRange(
                      start: DateUtils.dateOnly(now),
                      end: DateUtils.dateOnly(now).add(const Duration(days: 7)),
                    );

                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(now.year - 2),
                  lastDate: DateTime(now.year + 2),
                  initialDateRange: init,
                );

                if (picked == null) return;
                setState(() {
                  _preset = _RangePreset.custom;
                  _customRange = picked;
                });
                return;
              }

              setState(() {
                _preset = v;
              });
            },
      decoration: const InputDecoration(
        labelText: 'Период',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _modeToggle() {
    return SegmentedButton<_SyncMode>(
      segments: const [
        ButtonSegment(value: _SyncMode.import, label: Text('Импорт')),
        ButtonSegment(value: _SyncMode.export, label: Text('Экспорт')),
      ],
      selected: {_mode},
      onSelectionChanged: _loading
          ? null
          : (s) {
              if (s.isEmpty) return;
              setState(() => _mode = s.first);
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final showImportList = _mode == _SyncMode.import;

    final viewH = MediaQuery.of(context).size.height;
    final maxH = viewH * 0.90; // чтобы всегда помещалось

    Widget importList() {
      if (_events.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Text(
            _connected
                ? 'События не загружены'
                : 'Подключи аккаунт, чтобы загрузить события',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(), // ✅ скроллит общий scroll
        itemCount: _events.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          final e = _events[i];
          final id = e.id ?? 'no-id-$i';
          final checked = _selectedEventIds.contains(id);
          final subtitle = _fmtRange(context, e);

          final blockValue = _lifeBlockByEventId[id] ?? _defaultLifeBlock;

          return Material(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(() {
                  if (checked) {
                    _selectedEventIds.remove(id);
                  } else {
                    _selectedEventIds.add(id);
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: checked,
                          onChanged: _loading
                              ? null
                              : (_) {
                                  setState(() {
                                    if (checked) {
                                      _selectedEventIds.remove(id);
                                    } else {
                                      _selectedEventIds.add(id);
                                    }
                                  });
                                },
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (e.summary ?? 'Без названия').trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _lifeBlockDropdown(
                      value: blockValue,
                      dense: true,
                      label: 'Life block для этой цели',
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _lifeBlockByEventId[id] = v);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    Widget exportHint() {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.72),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD6E6F5)),
        ),
        child: Text(
          'Экспорт создаст события в выбранном календаре за выбранный период.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      );
    }

    return SizedBox(
      height: maxH,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          children: [
            // ===== Fixed header (не скроллится) =====
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Google Calendar',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                showImportList
                    ? 'Найди события в календаре и импортируй их как цели.'
                    : 'Выбери период и экспортируй цели из приложения в Google Calendar.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 12),

            if (_error != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(_error!, style: TextStyle(color: cs.error)),
              ),
              const SizedBox(height: 12),
            ],

            // mode toggle
            _modeToggle(),
            const SizedBox(height: 12),

            // ===== Scrollable middle =====
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_connected) ...[
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _calendarId,
                              items: [
                                const DropdownMenuItem(
                                  value: 'primary',
                                  child: Text('Primary (по умолчанию)'),
                                ),
                                ..._calendars
                                    .where((c) => (c.id?.isNotEmpty ?? false))
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c.id!,
                                        child: Text(
                                          c.summaryOverride ??
                                              c.summary ??
                                              c.id!,
                                        ),
                                      ),
                                    ),
                              ],
                              onChanged: _loading
                                  ? null
                                  : (v) => setState(
                                      () => _calendarId = v ?? 'primary',
                                    ),
                              decoration: const InputDecoration(
                                labelText: 'Календарь',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: _rangeDropdown()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (showImportList) ...[
                        _lifeBlockDropdown(
                          value: _defaultLifeBlock,
                          label: 'Default life block (для импорта)',
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              _defaultLifeBlock = v;
                              for (final e in _events) {
                                final id = e.id;
                                if (id == null) continue;
                                _lifeBlockByEventId[id] = v;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],

                    if (showImportList) importList() else exportHint(),
                  ],
                ),
              ),
            ),

            // ===== Fixed footer (не скроллится) =====
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loading ? null : _connect,
                    child: Text(
                      _loading
                          ? '...'
                          : (_connected ? 'Подключено' : 'Подключить'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (showImportList) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading || !_connected ? null : _findEvents,
                      child: Text(_loading ? '...' : 'Найти события'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _loading || _selectedEventIds.isEmpty
                          ? null
                          : _importSelected,
                      child: Text(_loading ? '...' : 'Импортировать'),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: FilledButton(
                      onPressed: _loading || !_connected
                          ? null
                          : _exportGoalsToCalendar,
                      child: Text(_loading ? '...' : 'Экспортировать'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
