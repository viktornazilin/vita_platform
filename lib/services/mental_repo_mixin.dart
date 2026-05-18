// lib/services/mental_repo_mixin.dart

import 'core/base_repo.dart';
import '../core/security/secure_crypto_service.dart';
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
  final SecureCryptoService _crypto = SecureCryptoService();

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

  String? _normOrNull(String? s) {
    final t = (s ?? '').trim();
    return t.isEmpty ? null : t;
  }

  bool _isYesNo(MentalQuestion q) {
    final t = (q.answerType ?? '').toString().toLowerCase().trim();
    return t == 'yes_no' || t == 'yesno' || t == 'bool' || t == 'boolean';
  }

  bool _isScale(MentalQuestion q) {
    final t = (q.answerType ?? '').toString().toLowerCase().trim();
    return t == 'scale' || t == 'rating' || t == 'int' || t == 'integer';
  }

  Future<Map<String, dynamic>> _encryptMentalAnswerPayload({
    bool? valueBool,
    int? valueInt,
    String? valueText,
  }) {
    return _crypto.encryptJson({
      'value_bool': valueBool,
      'value_int': valueInt,
      'value_text': _normOrNull(valueText),
    });
  }

  Future<Map<String, dynamic>> _decryptMentalAnswerRow(
    Map<String, dynamic> row,
  ) async {
    final encryptedPayload = row['encrypted_payload'];

    if (encryptedPayload == null || encryptedPayload is! Map) {
      return row;
    }

    try {
      final decrypted = await _crypto.decryptJson(
        Map<String, dynamic>.from(encryptedPayload),
      );

      row['value_bool'] = decrypted['value_bool'] is bool
          ? decrypted['value_bool'] as bool
          : null;

      final rawInt = decrypted['value_int'];
      row['value_int'] = rawInt is num ? rawInt.toInt() : null;

      final rawText = decrypted['value_text'];
      row['value_text'] = rawText is String ? _normOrNull(rawText) : null;

      return row;
    } catch (_) {
      // Fallback для старых/повреждённых записей:
      // оставляем plaintext-поля как есть.
      return row;
    }
  }

  Future<List<Map<String, dynamic>>> _decryptMentalAnswerRows(
    List<dynamic> rows,
  ) async {
    final out = <Map<String, dynamic>>[];

    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw as Map);
      out.add(await _decryptMentalAnswerRow(row));
    }

    return out;
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
        .select(
          'question_id, value_bool, value_int, value_text, encrypted_payload',
        )
        .eq('user_id', uid)
        .eq('day', _dateOnly(d));

    final decryptedRows = await _decryptMentalAnswerRows(res as List);

    final out = <String, Map<String, dynamic>>{};

    for (final m in decryptedRows) {
      final qid = (m['question_id'] ?? '').toString();
      if (qid.isEmpty) continue;

      out[qid] = {
        'value_bool': m['value_bool'],
        'value_int': (m['value_int'] as num?)?.toInt(),
        'value_text': _normOrNull(m['value_text']?.toString()),
      };
    }

    return out;
  }

  @override
  Future<void> upsertMentalAnswers(List<MentalAnswerUpsert> answers) async {
    if (answers.isEmpty) return;

    // 1) нормализуем вход (day -> YYYY-MM-DD, text -> trim/null)
    final normAnswers = answers.map((a) {
      final d = _d0(a.day);
      return (
        dayKey: _dateOnly(d),
        questionId: a.questionId,
        valueBool: a.valueBool,
        valueInt: a.valueInt,
        valueText: _normOrNull(a.valueText),
      );
    }).toList();

    // 2) одним запросом читаем существующие записи для затронутых day+question_id
    final days = normAnswers.map((e) => e.dayKey).toSet().toList();
    final qids = normAnswers.map((e) => e.questionId).toSet().toList();

    final existingRes = await client
        .from('mental_answers')
        .select(
          'day, question_id, value_bool, value_int, value_text, encrypted_payload',
        )
        .eq('user_id', uid)
        .inFilter('day', days)
        .inFilter('question_id', qids);

    final decryptedExistingRows = await _decryptMentalAnswerRows(
      existingRes as List,
    );

    // key: "$day|$questionId"
    final existing = <String, Map<String, dynamic>>{};

    for (final m in decryptedExistingRows) {
      final dayKey = _toDayKey(m['day']); // стабильно "YYYY-MM-DD"
      final qid = (m['question_id'] ?? '').toString();

      if (dayKey.isEmpty || qid.isEmpty) continue;

      existing['$dayKey|$qid'] = {
        'value_bool': m['value_bool'] as bool?,
        'value_int': (m['value_int'] as num?)?.toInt(),
        'value_text': _normOrNull(m['value_text']?.toString()),
      };
    }

    // 3) готовим rows только для новых/изменённых
    final rows = <Map<String, dynamic>>[];

    for (final a in normAnswers) {
      final key = '${a.dayKey}|${a.questionId}';
      final old = existing[key];

      final isSame = old != null &&
          (old['value_bool'] as bool?) == a.valueBool &&
          (old['value_int'] as int?) == a.valueInt &&
          (old['value_text'] as String?) == a.valueText;

      if (isSame) continue;

      final encryptedPayload = await _encryptMentalAnswerPayload(
        valueBool: a.valueBool,
        valueInt: a.valueInt,
        valueText: a.valueText,
      );

      rows.add(<String, dynamic>{
        'user_id': uid,
        'day': a.dayKey,
        'question_id': a.questionId,

        // Technical fallback for DB constraint mental_answers_has_value.
        // Real answer values are stored in encrypted_payload.
        'value_bool': null,
        'value_int': null,
        'value_text': '[encrypted]',

        'encrypted_payload': encryptedPayload,
        'encryption_version': 1,
      });
    }

    if (rows.isEmpty) return;

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
        .select(
          'day, question_id, value_bool, value_int, value_text, encrypted_payload',
        )
        .eq('user_id', uid)
        .gte('day', _dateOnly(s))
        .lte('day', _dateOnly(e))
        .order('day', ascending: true);

    return _decryptMentalAnswerRows(res as List);
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