import 'package:flutter/material.dart';

enum AiPeriod { week, month }

class AiSuggestion {
  final String title;
  final String? description;
  final String? lifeBlock;
  final double? hours;
  final int? importance;

  final DateTime? explicitDate;
  final int? weekday; // 1..7

  final TimeOfDay time;

  final AiPeriod periodSource;
  final bool selected;

  AiSuggestion({
    required this.title,
    required this.periodSource,
    required this.time,
    this.description,
    this.lifeBlock,
    this.hours,
    this.importance,
    this.explicitDate,
    this.weekday,
    this.selected = true,
  });

  factory AiSuggestion.fromJson(Map<String, dynamic> m, AiPeriod p) {
    TimeOfDay parseTime(dynamic v) {
      if (v is String && RegExp(r'^\d{1,2}:\d{2}$').hasMatch(v)) {
        final hh = int.parse(v.split(':')[0]);
        final mm = int.parse(v.split(':')[1]);
        return TimeOfDay(hour: hh.clamp(0, 23), minute: mm.clamp(0, 59));
      }
      return const TimeOfDay(hour: 9, minute: 0);
    }

    DateTime? parseDate(dynamic v) {
      if (v is String && v.isNotEmpty) {
        final d = DateTime.tryParse(v);
        if (d != null) return DateUtils.dateOnly(d);
      }
      return null;
    }

    return AiSuggestion(
      title: (m['title'] as String?)?.trim().isNotEmpty == true
          ? (m['title'] as String).trim()
          : 'Без названия',
      description: (m['description'] as String?)?.trim(),
      lifeBlock: (m['life_block'] as String?)?.trim().isEmpty == true
          ? null
          : (m['life_block'] as String?)?.trim(),
      hours: (m['hours'] is num) ? (m['hours'] as num).toDouble() : null,
      importance: (m['importance'] as int?) ?? 1,
      explicitDate: parseDate(m['date']),
      weekday: (m['weekday'] is num)
          ? (m['weekday'] as num).toInt().clamp(1, 7)
          : null,
      time: parseTime(m['time']),
      periodSource: p,
    );
  }

  AiSuggestion copyWith({
    String? title,
    String? description,
    TimeOfDay? time,
    bool? selected,
  }) {
    return AiSuggestion(
      title: title ?? this.title,
      description: description ?? this.description,
      lifeBlock: lifeBlock,
      hours: hours,
      importance: importance,
      explicitDate: explicitDate,
      weekday: weekday,
      time: time ?? this.time,
      periodSource: periodSource,
      selected: selected ?? this.selected,
    );
  }

  DateTime get displayDate => explicitDate ?? _defaultDateByPeriod();

  DateTime toStartDateTime() {
    final baseDate = displayDate;
    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      time.hour,
      time.minute,
    );
  }

  DateTime _defaultDateByPeriod() {
    final now = DateTime.now();
    if (periodSource == AiPeriod.week) {
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final nextMonday = monday.add(const Duration(days: 7));
      final wd = (weekday ?? 1).clamp(1, 7);
      return DateUtils.dateOnly(nextMonday.add(Duration(days: wd - 1)));
    } else {
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      if (weekday != null) {
        final wd = weekday!.clamp(1, 7);
        final firstDay = DateTime(nextMonth.year, nextMonth.month, 1);
        final shift = (DateTime.monday - firstDay.weekday) % 7;
        final firstMonday = firstDay.add(Duration(days: shift));
        return DateUtils.dateOnly(firstMonday.add(Duration(days: wd - 1)));
      }
      return DateUtils.dateOnly(nextMonth);
    }
  }
}
