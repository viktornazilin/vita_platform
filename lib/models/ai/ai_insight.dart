class AiInsight {
  final String type; // behavioral | goal | emotional | habit | risk
  final String title;
  final String insight;

  final String impactGoal;
  final String impactDirection; // positive | negative | mixed
  final double impactStrength; // 0..1

  final List<String> evidence;
  final String? suggestion;

  AiInsight({
    required this.type,
    required this.title,
    required this.insight,
    required this.impactGoal,
    required this.impactDirection,
    required this.impactStrength,
    required this.evidence,
    this.suggestion,
  });

  factory AiInsight.fromJson(Map<String, dynamic> m) {
    final impact = (m['impact'] is Map)
        ? (m['impact'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final ev = (m['evidence'] is List) ? (m['evidence'] as List) : const [];

    return AiInsight(
      type: (m['type'] ?? 'behavioral').toString(),
      title: (m['title'] ?? 'Insight').toString(),
      insight: (m['insight'] ?? '').toString(),
      impactGoal: (impact['goal'] ?? 'general').toString(),
      impactDirection: (impact['direction'] ?? 'mixed').toString(),
      impactStrength:
          ((impact['strength'] is num)
                  ? (impact['strength'] as num).toDouble()
                  : 0.5)
              .clamp(0.0, 1.0),
      evidence: ev
          .map((e) => e.toString())
          .where((s) => s.trim().isNotEmpty)
          .toList(),
      suggestion: (m['suggestion'] as String?)?.trim().isEmpty == true
          ? null
          : (m['suggestion'] as String?)?.trim(),
    );
  }
}
