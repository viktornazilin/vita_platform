import 'package:flutter/widgets.dart';

import '../models/mental_question.dart';

/// Localizes mental question titles stored in Supabase.
///
/// The database keeps stable technical `code` values and a Russian fallback
/// in `text`. The app displays the localized label based on the current
/// Flutter locale.
String localizedMentalQuestionText(BuildContext context, MentalQuestion q) {
  final lang = Localizations.localeOf(context).languageCode.toLowerCase();
  final key = _questionKey(q);
  final value = _translations[key]?[lang] ?? _translations[key]?['en'];

  if (value != null && value.trim().isNotEmpty) return value;
  return q.text;
}

String _questionKey(MentalQuestion q) {
  final code = _normalize(q.code);
  final text = _normalize(q.text);
  final joined = '$code $text';

  if (_hasAny(joined, ['satisfaction', 'satisfied', 'udovletvoren', 'удовлетвор'])) {
    return 'day_satisfaction';
  }
  if (_hasAny(joined, ['positive', 'positiv', 'pozitiv', 'позитив', 'emotional_background', 'эмоциональныйфон'])) {
    return 'positive_emotional_background';
  }
  if (_hasAny(joined, ['anxiety', 'trevozh', 'тревож'])) {
    return 'anxiety_level';
  }
  if (_hasAny(joined, ['stress', 'стресс'])) {
    return 'stress_level';
  }
  if (_hasAny(joined, ['panic', 'obsessive', 'navyaz', 'паническ', 'навязчив'])) {
    return 'panic_obsessive_thoughts';
  }
  if (_hasAny(joined, ['sleep', 'сон', 'sna', 'quality_sleep'])) {
    return 'sleep_quality';
  }
  if (_hasAny(joined, ['energy', 'energi', 'энерг'])) {
    return 'energy_level';
  }
  if (_hasAny(joined, ['negative_peak', 'emotion_peak', 'peak_negative', 'негативныхэмоций', 'грусть', 'злость', 'pik'])) {
    return 'negative_emotion_peak';
  }
  if (_hasAny(joined, ['burnout', 'overload', 'перегруз', 'выгоран'])) {
    return 'overload_burnout';
  }
  if (_hasAny(joined, ['focus', 'focused', 'сфокусирован'])) {
    return 'focus_level';
  }

  return code.isNotEmpty ? code : text;
}

bool _hasAny(String source, List<String> needles) {
  for (final n in needles) {
    if (source.contains(_normalize(n))) return true;
  }
  return false;
}

String _normalize(String value) {
  return value
      .toLowerCase()
      .replaceAll('ё', 'е')
      .replaceAll(RegExp(r'[^a-zа-я0-9]+'), '');
}

const Map<String, Map<String, String>> _translations = {
  'day_satisfaction': {
    'ru': 'Было ли чувство удовлетворения от дня?',
    'en': 'Did you feel satisfied with your day?',
    'de': 'Hattest du ein Gefühl der Zufriedenheit mit dem Tag?',
    'fr': 'As-tu ressenti de la satisfaction par rapport à ta journée ?',
    'es': '¿Sentiste satisfacción con el día?',
    'tr': 'Günden memnuniyet duydun mu?',
  },
  'positive_emotional_background': {
    'ru': 'Общий эмоциональный фон сегодня был скорее позитивным?',
    'en': 'Was your overall emotional state today mostly positive?',
    'de': 'War deine allgemeine emotionale Stimmung heute eher positiv?',
    'fr': 'Ton état émotionnel global était-il plutôt positif aujourd’hui ?',
    'es': '¿Tu estado emocional general de hoy fue más bien positivo?',
    'tr': 'Bugünkü genel duygusal durumun çoğunlukla olumlu muydu?',
  },
  'anxiety_level': {
    'ru': 'Уровень тревожности сегодня',
    'en': 'Anxiety level today',
    'de': 'Angstniveau heute',
    'fr': 'Niveau d’anxiété aujourd’hui',
    'es': 'Nivel de ansiedad de hoy',
    'tr': 'Bugünkü kaygı seviyesi',
  },
  'stress_level': {
    'ru': 'Уровень стресса сегодня',
    'en': 'Stress level today',
    'de': 'Stressniveau heute',
    'fr': 'Niveau de stress aujourd’hui',
    'es': 'Nivel de estrés de hoy',
    'tr': 'Bugünkü stres seviyesi',
  },
  'panic_obsessive_thoughts': {
    'ru': 'Были ли панические/навязчивые мысли сегодня?',
    'en': 'Did you have panic or intrusive thoughts today?',
    'de': 'Hattest du heute panische oder aufdringliche Gedanken?',
    'fr': 'As-tu eu des pensées paniques ou intrusives aujourd’hui ?',
    'es': '¿Tuviste pensamientos de pánico o intrusivos hoy?',
    'tr': 'Bugün panik ya da takıntılı düşünceler yaşadın mı?',
  },
  'sleep_quality': {
    'ru': 'Качество сна прошлой ночью',
    'en': 'Sleep quality last night',
    'de': 'Schlafqualität letzte Nacht',
    'fr': 'Qualité du sommeil la nuit dernière',
    'es': 'Calidad del sueño de anoche',
    'tr': 'Dün geceki uyku kalitesi',
  },
  'energy_level': {
    'ru': 'Уровень энергии сегодня',
    'en': 'Energy level today',
    'de': 'Energielevel heute',
    'fr': 'Niveau d’énergie aujourd’hui',
    'es': 'Nivel de energía de hoy',
    'tr': 'Bugünkü enerji seviyesi',
  },
  'negative_emotion_peak': {
    'ru': 'Был ли сегодня “пик” сильных негативных эмоций (грусть/злость)?',
    'en': 'Was there a peak of strong negative emotions today, such as sadness or anger?',
    'de': 'Gab es heute einen Höhepunkt starker negativer Emotionen, zum Beispiel Traurigkeit oder Wut?',
    'fr': 'Y a-t-il eu aujourd’hui un pic d’émotions négatives fortes, comme la tristesse ou la colère ?',
    'es': '¿Hubo hoy un pico de emociones negativas fuertes, como tristeza o ira?',
    'tr': 'Bugün üzüntü ya da öfke gibi güçlü olumsuz duygularda bir zirve yaşandı mı?',
  },
  'overload_burnout': {
    'ru': 'Чувствовал(а) ли ты перегруз/выгорание сегодня?',
    'en': 'Did you feel overloaded or burned out today?',
    'de': 'Hast du dich heute überlastet oder ausgebrannt gefühlt?',
    'fr': 'T’es-tu senti(e) surchargé(e) ou épuisé(e) aujourd’hui ?',
    'es': '¿Te sentiste sobrecargado/a o agotado/a hoy?',
    'tr': 'Bugün aşırı yüklenmiş ya da tükenmiş hissettin mi?',
  },
  'focus_level': {
    'ru': 'Насколько ты был(а) сфокусирован(а) сегодня',
    'en': 'How focused were you today?',
    'de': 'Wie fokussiert warst du heute?',
    'fr': 'À quel point étais-tu concentré(e) aujourd’hui ?',
    'es': '¿Qué tan concentrado/a estuviste hoy?',
    'tr': 'Bugün ne kadar odaklanmıştın?',
  },
};
