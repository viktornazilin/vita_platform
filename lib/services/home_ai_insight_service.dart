import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

class HomeAiInsightResult {
  const HomeAiInsightResult({
    required this.insight,
    required this.source,
    required this.aiUsed,
    required this.generatedAt,
  });

  final String insight;
  final String source;
  final bool aiUsed;
  final DateTime? generatedAt;

  bool get isPlaceholder => insight.trim().isEmpty;

  factory HomeAiInsightResult.placeholder(String text) {
    return HomeAiInsightResult(
      insight: text,
      source: 'placeholder',
      aiUsed: false,
      generatedAt: null,
    );
  }

  factory HomeAiInsightResult.fromMap(Map<String, dynamic> map) {
    return HomeAiInsightResult(
      insight: (map['insight'] ?? '').toString().trim(),
      source: (map['source'] ?? '').toString().trim(),
      aiUsed: map['ai_used'] == true,
      generatedAt: DateTime.tryParse((map['generated_at'] ?? '').toString()),
    );
  }
}

class HomeAiInsightService {
  HomeAiInsightService._();

  static final HomeAiInsightService instance = HomeAiInsightService._();

  Future<HomeAiInsightResult> fetch({required String locale}) async {
    final response = await Supabase.instance.client.functions.invoke(
      'home-ai-insight',
      body: {'locale': locale},
    );

    final raw = response.data;
    final map = _asMap(raw);

    if (response.status != 200) {
      throw Exception(map['error'] ?? 'home-ai-insight returned ${response.status}');
    }

    if (map['ok'] == false) {
      throw Exception(map['error'] ?? 'home-ai-insight returned ok=false');
    }

    final result = HomeAiInsightResult.fromMap(map);
    if (result.insight.isEmpty) {
      throw Exception('home-ai-insight returned empty insight');
    }
    return result;
  }


  Future<HomeAiInsightResult> fetchReport({
    required String locale,
    required String reportTab,
  }) async {
    final response = await Supabase.instance.client.functions.invoke(
      'home-ai-insight',
      body: {
        'locale': locale,
        'surface': 'reports',
        'report_tab': reportTab,
      },
    );

    final raw = response.data;
    final map = _asMap(raw);

    if (response.status != 200) {
      throw Exception(map['error'] ?? 'home-ai-insight returned ${response.status}');
    }

    if (map['ok'] == false) {
      throw Exception(map['error'] ?? 'home-ai-insight returned ok=false');
    }

    final result = HomeAiInsightResult.fromMap(map);
    if (result.insight.isEmpty) {
      throw Exception('home-ai-insight returned empty insight');
    }
    return result;
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String && raw.trim().isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    return <String, dynamic>{};
  }
}
