// lib/models/week_insights.dart

import 'habit.dart';
import 'mental_question.dart';

class WeekInsights {
  final List<DateTime> days;
  final List<int> moodScores;

  final List<Habit> habits;
  final List<Habit> topHabits;
  final Map<DateTime, Map<String, Map<String, dynamic>>> habitEntriesByDay;
  final Map<String, int> habitDoneCount;

  final List<MentalQuestion> questions;
  final Map<String, YesNoStat> yesNoStats;
  final Map<String, ScaleStat> scaleStats;

  const WeekInsights({
    required this.days,
    required this.moodScores,
    required this.habits,
    required this.topHabits,
    required this.habitEntriesByDay,
    required this.habitDoneCount,
    required this.questions,
    required this.yesNoStats,
    required this.scaleStats,
  });
}

class YesNoStat {
  final MentalQuestion question;
  final int yes;
  final int total;

  const YesNoStat({
    required this.question,
    required this.yes,
    required this.total,
  });

  double get ratio => total <= 0 ? 0 : yes / total;
}

class ScaleStat {
  final MentalQuestion question;
  final List<int?> series;
  final double? avg;

  const ScaleStat({
    required this.question,
    required this.series,
    required this.avg,
  });
}

/// Чтобы удобно передавать label-функцию в виджеты
typedef WeekdayLabel = String Function(DateTime d);
