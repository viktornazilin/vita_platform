// lib/services/mental_repo_mixin.dart

import 'core/base_repo.dart';
import '../models/mental_question.dart';

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
  }) : valueBool = value,
       valueInt = null,
       valueText = null;

  MentalAnswerUpsert.scale({
    required this.questionId,
    required this.day,
    required int value,
  }) : valueBool = null,
       valueInt = value,
       valueText = null;

  MentalAnswerUpsert.text({
    required this.questionId,
    required this.day,
    required String value,
  }) : valueBool = null,
       valueInt = null,
       valueText = value;
}

/// Интерфейс (необязательно, но удобно)
abstract class MentalRepo {
  Future<List<MentalQuestion>> listMentalQuestions({bool onlyActive = true});
  Future<Map<String, Map<String, dynamic>>> getMentalAnswersForDay(
    DateTime day,
  );
  Future<void> upsertMentalAnswers(List<MentalAnswerUpsert> answers);
}

mixin MentalRepoMixin on BaseRepo implements MentalRepo {
  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  Future<List<MentalQuestion>> listMentalQuestions({
    bool onlyActive = true,
  }) async {
    // держим builder как filterable (eq будет доступен)
    var q = client
        .from('mental_questions')
        .select(
          'id,code,text,answer_type,min_value,max_value,sort_order,is_active,created_at',
        );

    if (onlyActive) {
      q = q.eq('is_active', true);
    }

    // order() НЕ присваиваем обратно в q — чтобы не было конфликта типов
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
    final d0 = DateTime(day.year, day.month, day.day);

    final res = await client
        .from('mental_answers')
        .select('question_id, value_bool, value_int, value_text')
        .eq('user_id', uid)
        .eq('day', _dateOnly(d0));

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

    final rows = answers.map((a) {
      final d0 = DateTime(a.day.year, a.day.month, a.day.day);
      final txt = (a.valueText ?? '').trim();

      return <String, dynamic>{
        'user_id': uid,
        'day': _dateOnly(d0),
        'question_id': a.questionId,
        'value_bool': a.valueBool,
        'value_int': a.valueInt,
        'value_text': txt.isEmpty ? null : txt,
      };
    }).toList();

    await client
        .from('mental_answers')
        .upsert(rows, onConflict: 'user_id,day,question_id');
  }
}
