// lib/widgets/day_google_calendar_sync_sheet.dart
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:nest_app/l10n/app_localizations.dart';

import '../main.dart'; // dbRepo
import '../models/goals_calendar_model.dart';
import '../services/google_calendar_service.dart';

/// Синхронизация Google Calendar ТОЛЬКО для указанного дня:
/// - Импорт: события дня -> цели
/// - Экспорт: цели дня -> события
class DayGoogleCalendarSyncSheet extends StatefulWidget {
  final DateTime date;
  const DayGoogleCalendarSyncSheet({super.key, required this.date});

  @override
  State<DayGoogleCalendarSyncSheet> createState() =>
      _DayGoogleCalendarSyncSheetState();
}

enum _DaySyncMode { import, export }

class _DayGoogleCalendarSyncSheetState
    extends State<DayGoogleCalendarSyncSheet> {
  final GoogleCalendarService _service = GoogleCalendarService();

  bool _loading = false;
  String? _error;
  _DaySyncMode _mode = _DaySyncMode.import;

  // calendars
  List<gcal.CalendarListEntry> _calendars = const [];
  String _calendarId = 'primary';

  // import: events
  List<gcal.Event> _events = const [];
  final Set<String> _selectedEventIds = {};

  // lifeblocks
  List<String> _lifeBlocks = const ['General'];
  String _defaultLifeBlock = 'General';
  final Map<String, String> _lifeBlockByEventId = {};

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

  DateTimeRange _dayRange() {
    final d = DateUtils.dateOnly(widget.date);
    return DateTimeRange(start: d, end: d.add(const Duration(days: 1)));
  }

  // --- event dt helpers
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

  String _fmtTime(BuildContext context, DateTime d) {
    final loc = MaterialLocalizations.of(context);
    return loc.formatTimeOfDay(TimeOfDay.fromDateTime(d));
  }

  String _fmtRange(BuildContext context, gcal.Event e) {
    final st = _eventStart(e);
    final en = _eventEnd(e);
    if (st == null) return '';
    if (en == null) return _fmtTime(context, st);
    return '${_fmtTime(context, st)} – ${_fmtTime(context, en)}';
  }

  // --- connect / calendars
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

  // --- import: list events for that day
  Future<void> _findEventsForDay() async {
    setState(() {
      _loading = true;
      _error = null;
      _events = const [];
      _selectedEventIds.clear();
      _lifeBlockByEventId.clear();
    });

    try {
      final range = _dayRange();

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

  // --- import selected events as goals
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

        final title = (e.summary ?? AppLocalizations.of(context)!.gcNoTitle)
            .trim();
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
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.gcImportedGoals(created))));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // --- export: goals (day) -> calendar
  Future<void> _exportGoalsForDay() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final day = DateUtils.dateOnly(widget.date);
      final goals = await dbRepo.getGoalsByDate(day);

      int exported = 0;

      for (final g in goals) {
        final st = g.startTime.toLocal();

        final durMinutes = (g.spentHours > 0)
            ? (g.spentHours * 60).round().clamp(15, 24 * 60)
            : 60;

        final en = st.add(Duration(minutes: durMinutes));

        await _service.upsertEvent(
          calendarId: _calendarId,
          summary: g.title,
          description: g.description,
          start: st,
          end: en,
          timeZone: 'Europe/Berlin',
          extendedPrivateTags: ['vita_goal_id=${g.id}'],
        );

        exported++;
      }

      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.gcExportedGoals(exported))));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

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

  Widget _modeToggle(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SegmentedButton<_DaySyncMode>(
      segments: [
        ButtonSegment(value: _DaySyncMode.import, label: Text(t.gcModeImport)),
        ButtonSegment(value: _DaySyncMode.export, label: Text(t.gcModeExport)),
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
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final showImport = _mode == _DaySyncMode.import;

    final viewH = MediaQuery.of(context).size.height;
    final maxH = viewH * 0.90;

    return SizedBox(
      height: maxH,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                t.gcTitleDaySync,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                showImport ? t.gcSubtitleImport : t.gcSubtitleExport,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 10),

            if (_error != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(_error!, style: TextStyle(color: cs.error)),
              ),
              const SizedBox(height: 10),
            ],

            _modeToggle(context),
            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_connected) ...[
                      DropdownButtonFormField<String>(
                        value: _calendarId,
                        items: [
                          DropdownMenuItem(
                            value: 'primary',
                            child: Text(t.gcCalendarPrimary),
                          ),
                          ..._calendars
                              .where((c) => (c.id?.isNotEmpty ?? false))
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id!,
                                  child: Text(
                                    c.summaryOverride ?? c.summary ?? c.id!,
                                  ),
                                ),
                              ),
                        ],
                        onChanged: _loading
                            ? null
                            : (v) =>
                                  setState(() => _calendarId = v ?? 'primary'),
                        decoration: InputDecoration(
                          labelText: t.gcCalendarLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (showImport) ...[
                        _lifeBlockDropdown(
                          value: _defaultLifeBlock,
                          label: t.gcDefaultLifeBlockLabel,
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

                    if (showImport) ...[
                      if (_events.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Text(
                            _connected
                                ? t.gcEventsNotLoaded
                                : t.gcConnectToLoadEvents,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _events.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx, i) {
                            final e = _events[i];
                            final id = e.id ?? 'no-id-$i';
                            final checked = _selectedEventIds.contains(id);
                            final subtitle = _fmtRange(context, e);
                            final blockValue =
                                _lifeBlockByEventId[id] ?? _defaultLifeBlock;

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
                                                        _selectedEventIds
                                                            .remove(id);
                                                      } else {
                                                        _selectedEventIds.add(
                                                          id,
                                                        );
                                                      }
                                                    });
                                                  },
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  (e.summary ?? t.gcNoTitle)
                                                      .trim(),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  subtitle,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color:
                                                            cs.onSurfaceVariant,
                                                      ),
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
                                        label: t.gcLifeBlockForThisGoalLabel,
                                        onChanged: (v) {
                                          if (v == null) return;
                                          setState(
                                            () => _lifeBlockByEventId[id] = v,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.72),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFD6E6F5)),
                        ),
                        child: Text(
                          t.gcExportHint,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loading ? null : _connect,
                    child: Text(
                      _loading
                          ? t.gcLoadingDots
                          : (_connected ? t.gcConnected : t.gcConnect),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (showImport) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading || !_connected
                          ? null
                          : _findEventsForDay,
                      child: Text(_loading ? t.gcLoadingDots : t.gcFindForDay),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _loading || _selectedEventIds.isEmpty
                          ? null
                          : _importSelected,
                      child: Text(_loading ? t.gcLoadingDots : t.gcImport),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: FilledButton(
                      onPressed: _loading || !_connected
                          ? null
                          : _exportGoalsForDay,
                      child: Text(_loading ? t.gcLoadingDots : t.gcExport),
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
