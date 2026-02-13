  // lib/services/mental_repo_mixin.dart

import 'core/base_repo.dart';
import '../models/mental_question.dart';
import '../models/week_insights.dart';

/// DTO для апсерта ответа пользователя
class MentalAnswerUpsert {
  final String questionId;
  final DateTime day; // date-only
  final bool? valueBool;
  final int? valueInt;
  final String? valueText;

  MentalAnswerUpsert.yesNo({
    required this.questionId,
    required this.day,
    required bool value,
  })  : valueBool = value,
        valueInt = null,
        valueText = null;

  MentalAnswerUpsert.scale({
    required this.questionId,
    required this.day,
    required int value,
  })  : valueBool = null,
        valueInt = value,
        valueText = null;

  MentalAnswerUpsert.text({
    required this.questionId,
    required this.day,
    required String value,
  })  : valueBool = null,
        valueInt = null,
        valueText = value;
}

/// Интерфейс
abstract class MentalRepo {
  Future<List<MentalQuestion>> listMentalQuestions({bool onlyActive = true});

  Future<Map<String, Map<String, dynamic>>> getMentalAnswersForDay(
    DateTime day,
  );

  Future<void> upsertMentalAnswers(List<MentalAnswerUpsert> answers);

  /// ✅ ответы за диапазон (неделя)
  Future<List<Map<String, dynamic>>> getMentalAnswersForRange(
    DateTime startInclusive,
    DateTime endInclusive,
  );

  /// ✅ собрать готовые yesNoStats/scaleStats для карточки недели
  Future<
      ({
        Map<String, YesNoStat> yesNoStats,
        Map<String, ScaleStat> scaleStats,
        List<MentalQuestion> questions,
      })> buildWeekMentalStats(List<DateTime> days);
}

mixin MentalRepoMixin on BaseRepo implements MentalRepo {
  // ---------- date helpers ----------

  DateTime _d0(DateTime d) => DateTime(d.year, d.month, d.day);

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Postgrest иногда отдаёт day как String ("YYYY-MM-DD" или ISO),
  /// а иногда как DateTime (в web/desktop бывает по-разному).
  /// Нам нужен стабильный ключ "YYYY-MM-DD".
  String _toDayKey(dynamic day) {
    if (day == null) return '';

    if (day is DateTime) {
      return _dateOnly(_d0(day));
    }

    final s = day.toString().trim();
    if (s.isEmpty) return '';
    return s.length >= 10 ? s.substring(0, 10) : s;
  }

  bool _isYesNo(MentalQuestion q) {
    final t = (q.answerType ?? '').toString().toLowerCase().trim();
    return t == 'yes_no' || t == 'yesno' || t == 'bool' || t == 'boolean';
  }

  bool _isScale(MentalQuestion q) {
    final t = (q.answerType ?? '').toString().toLowerCase().trim();
    return t == 'scale' || t == 'rating' || t == 'int' || t == 'integer';
  }

  // ---------- repo methods ----------

  @override
  Future<List<MentalQuestion>> listMentalQuestions({
    bool onlyActive = true,
  }) async {
    var q = client
        .from('mental_questions')
        .select(
          'id,code,text,answer_type,min_value,max_value,sort_order,is_active,created_at',
        );

    if (onlyActive) {
      q = q.eq('is_active', true);
    }

    final res = await q
        .order('sort_order', ascending: true)
        .order('created_at', ascending: true);

    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(MentalQuestion.fromMap)
        .toList();
  }

  /// Возвращает: questionId -> {value_bool,value_int,value_text}
  @override
  Future<Map<String, Map<String, dynamic>>> getMentalAnswersForDay(
    DateTime day,
  ) async {
    final d = _d0(day);

    final res = await client
        .from('mental_answers')
        .select('question_id, value_bool, value_int, value_text')
        .eq('user_id', uid)
        .eq('day', _dateOnly(d));

    final out = <String, Map<String, dynamic>>{};
    for (final r in (res as List)) {
      final m = Map<String, dynamic>.from(r as Map);
      final qid = (m['question_id'] ?? '').toString();
      if (qid.isEmpty) continue;

      out[qid] = {
        'value_bool': m['value_bool'],
        'value_int': (m['value_int'] as num?)?.toInt(),
        'value_text': m['value_text'],
      };
    }
    return out;
  }

  @override
  Future<void> upsertMentalAnswers(List<MentalAnswerUpsert> answers) async {
    if (answers.isEmpty) return;

    // ---- локальная нормализация текста (не меняем остальной файл) ----
    String norm(String? s) => (s ?? '').trim();
    String? normOrNull(String? s) {
      final t = norm(s);
      return t.isEmpty ? null : t;
    }

    // 1) нормализуем вход (day -> YYYY-MM-DD, text -> trim/null)
    final normAnswers = answers.map((a) {
      final d = _d0(a.day);
      return (
        dayKey: _dateOnly(d),
        questionId: a.questionId,
        valueBool: a.valueBool,
        valueInt: a.valueInt,
        valueText: normOrNull(a.valueText),
      );
    }).toList();

    // 2) одним запросом читаем существующие записи для затронутых day+question_id
    final days = normAnswers.map((e) => e.dayKey).toSet().toList();
    final qids = normAnswers.map((e) => e.questionId).toSet().toList();

    final existingRes = await client
        .from('mental_answers')
        .select('day, question_id, value_bool, value_int, value_text')
        .eq('user_id', uid)
        .inFilter('day', days)
        .inFilter('question_id', qids);

    // key: "$day|$questionId"
    final existing = <String, Map<String, dynamic>>{};
    for (final r in (existingRes as List)) {
      final m = Map<String, dynamic>.from(r as Map);
      final dayKey = _toDayKey(m['day']); // стабильно "YYYY-MM-DD"
      final qid = (m['question_id'] ?? '').toString();
      if (dayKey.isEmpty || qid.isEmpty) continue;

      existing['$dayKey|$qid'] = {
        'value_bool': m['value_bool'] as bool?,
        'value_int': (m['value_int'] as num?)?.toInt(),
        'value_text': normOrNull(m['value_text']?.toString()),
      };
    }

    // 3) готовим rows только для новых/изменённых (если без изменений — не пишем)
    final rows = <Map<String, dynamic>>[];

    for (final a in normAnswers) {
      final key = '${a.dayKey}|${a.questionId}';
      final old = existing[key];

      final isSame = old != null &&
          (old['value_bool'] as bool?) == a.valueBool &&
          (old['value_int'] as int?) == a.valueInt &&
          (old['value_text'] as String?) == a.valueText;

      if (isSame) continue; // ✅ ничего не изменилось — пропускаем

      rows.add(<String, dynamic>{
        'user_id': uid,
        'day': a.dayKey,
        'question_id': a.questionId,
        'value_bool': a.valueBool,
        'value_int': a.valueInt,
        'value_text': a.valueText, // уже null если пусто
      });
    }

    if (rows.isEmpty) return; // ✅ нет изменений — нет записи в БД

    await client
        .from('mental_answers')
        .upsert(rows, onConflict: 'user_id,day,question_id');
  }

  /// ✅ получить ответы за диапазон (например, неделю)
  @override
  Future<List<Map<String, dynamic>>> getMentalAnswersForRange(
    DateTime startInclusive,
    DateTime endInclusive,
  ) async {
    final s = _d0(startInclusive);
    final e = _d0(endInclusive);

    final res = await client
        .from('mental_answers')
        .select('day, question_id, value_bool, value_int, value_text')
        .eq('user_id', uid)
        .gte('day', _dateOnly(s))
        .lte('day', _dateOnly(e))
        .order('day', ascending: true);

    return (res as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<
      ({
        Map<String, YesNoStat> yesNoStats,
        Map<String, ScaleStat> scaleStats,
        List<MentalQuestion> questions,
      })> buildWeekMentalStats(List<DateTime> days) async {
    // 1) нормализуем дни (date-only) + убираем дубликаты
    final uniq = <DateTime>{};
    for (final d in days) {
      uniq.add(_d0(d));
    }
    final normDays = uniq.toList()..sort((a, b) => a.compareTo(b));

    if (normDays.isEmpty) {
      return (
        yesNoStats: <String, YesNoStat>{},
        scaleStats: <String, ScaleStat>{},
        questions: <MentalQuestion>[],
      );
    }

    final start = normDays.first;
    final end = normDays.last;

    // 2) вопросы
    final questions = await listMentalQuestions(onlyActive: true);

    // 3) ответы недели
    final answers = await getMentalAnswersForRange(start, end);

    // dayKey("YYYY-MM-DD") -> questionId -> row
    final answersByDay = <String, Map<String, Map<String, dynamic>>>{};

    for (final raw in answers) {
      final row = Map<String, dynamic>.from(raw);

      final dayKey = _toDayKey(row['day']); // "YYYY-MM-DD"
      final qid = (row['question_id'] ?? '').toString();

      if (dayKey.isEmpty || qid.isEmpty) continue;

      answersByDay.putIfAbsent(dayKey, () => <String, Map<String, dynamic>>{});
      answersByDay[dayKey]![qid] = row;
    }

    final yesNoStats = <String, YesNoStat>{};
    final scaleStats = <String, ScaleStat>{};

    // 4) считаем по каждому вопросу
    for (final q in questions) {
      final qid = q.id;

      // ---------- YES/NO ----------
      if (q.answerType == MentalAnswerType.yesNo) {
        int yes = 0;
        int total = 0;

        for (final d in normDays) {
          final dk = _dateOnly(d);
          final row = answersByDay[dk]?[qid];
          if (row == null) continue;

          final vb = _asBool(row['value_bool']);
          if (vb == null) continue;

          total++;
          if (vb) yes++;
        }

        if (total > 0) {
          yesNoStats[qid] = YesNoStat(question: q, yes: yes, total: total);
        }
      }

      // ---------- SCALE ----------
      if (q.answerType == MentalAnswerType.scale1to5 ||
          q.answerType == MentalAnswerType.scale1to10) {
        final series = List<int?>.filled(normDays.length, null);

        int sum = 0;
        int cnt = 0;

        for (int i = 0; i < normDays.length; i++) {
          final dk = _dateOnly(normDays[i]);
          final row = answersByDay[dk]?[qid];
          if (row == null) continue;

          final vi = _asInt(row['value_int']);
          if (vi == null) continue;

          series[i] = vi;
          sum += vi;
          cnt++;
        }

        if (cnt > 0) {
          scaleStats[qid] = ScaleStat(
            question: q,
            series: series,
            avg: sum / cnt,
          );
        }
      }

      // text — в week card пока не показываем
    }

    return (
      yesNoStats: yesNoStats,
      scaleStats: scaleStats,
      questions: questions,
    );
  }

  // ---------------- helpers ----------------

  bool? _asBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;

    if (v is num) return v != 0;

    final s = v.toString().trim().toLowerCase();
    if (s == 'true' || s == 't' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == 'f' || s == '0' || s == 'no') return false;

    return null;
  }

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();

    final s = v.toString().trim();
    if (s.isEmpty) return null;

    return int.tryParse(s) ?? double.tryParse(s)?.toInt();
  }
}
