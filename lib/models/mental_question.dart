// lib/models/mental_question.dart

/// Тип ответа вопроса
enum MentalAnswerType { yesNo, scale1to10, scale1to5, text }

MentalAnswerType parseMentalAnswerType(String s) {
  switch (s) {
    case 'yes_no':
      return MentalAnswerType.yesNo;
    case 'scale_1_10':
      return MentalAnswerType.scale1to10;
    case 'scale_1_5':
      return MentalAnswerType.scale1to5;
    case 'text':
      return MentalAnswerType.text;
    default:
      return MentalAnswerType.text;
  }
}

String mentalAnswerTypeToDb(MentalAnswerType t) {
  switch (t) {
    case MentalAnswerType.yesNo:
      return 'yes_no';
    case MentalAnswerType.scale1to10:
      return 'scale_1_10';
    case MentalAnswerType.scale1to5:
      return 'scale_1_5';
    case MentalAnswerType.text:
      return 'text';
  }
}

/// Вопрос из банка mental_questions
class MentalQuestion {
  final String id; // uuid
  final String code;
  final String text;
  final MentalAnswerType answerType;
  final int? minValue;
  final int? maxValue;
  final int sortOrder;
  final bool isActive;

  MentalQuestion({
    required this.id,
    required this.code,
    required this.text,
    required this.answerType,
    required this.minValue,
    required this.maxValue,
    required this.sortOrder,
    required this.isActive,
  });

  factory MentalQuestion.fromMap(Map<String, dynamic> m) {
    return MentalQuestion(
      id: (m['id'] ?? '').toString(),
      code: (m['code'] ?? '').toString(),
      text: (m['text'] ?? '').toString(),
      answerType: parseMentalAnswerType(
        (m['answer_type'] ?? 'text').toString(),
      ),
      minValue: (m['min_value'] as num?)?.toInt(),
      maxValue: (m['max_value'] as num?)?.toInt(),
      sortOrder: (m['sort_order'] as num?)?.toInt() ?? 0,
      isActive: (m['is_active'] as bool?) ?? true,
    );
  }
}
