import 'package:flutter/material.dart';

import '../../models/ai/ai_insight.dart';
import '../widgets/info_chip.dart';

class AiInsightCard extends StatelessWidget {
  final AiInsight item;
  const AiInsightCard({super.key, required this.item});

  IconData _iconForType(String t) {
    switch (t) {
      case 'risk':
        return Icons.warning_amber_rounded;
      case 'emotional':
        return Icons.mood;
      case 'habit':
        return Icons.autorenew;
      case 'goal':
        return Icons.flag;
      default:
        return Icons.insights;
    }
  }

  String _strengthLabel(double v) {
    if (v >= 0.75) return 'Сильное влияние';
    if (v >= 0.5) return 'Заметное влияние';
    if (v >= 0.25) return 'Слабое влияние';
    return 'Низкая уверенность';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_iconForType(item.type), color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.title,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                _ImpactPill(direction: item.impactDirection),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.insight, style: tt.bodyMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: -6,
              children: [
                InfoChip(icon: Icons.flag_outlined, text: item.impactGoal),
                InfoChip(
                  icon: Icons.tune,
                  text: _strengthLabel(item.impactStrength),
                ),
                InfoChip(
                  icon: Icons.speed,
                  text: '${(item.impactStrength * 100).round()}%',
                ),
              ],
            ),
            if (item.evidence.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Доказательства',
                style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              ...item.evidence
                  .take(3)
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: tt.bodySmall),
                          Expanded(
                            child: Text(
                              e,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
            if ((item.suggestion ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item.suggestion!, style: tt.bodySmall),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ImpactPill extends StatelessWidget {
  final String direction; // positive | negative | mixed
  const _ImpactPill({required this.direction});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    IconData icon;
    String label;

    switch (direction) {
      case 'positive':
        icon = Icons.trending_up;
        label = 'Позитив';
        break;
      case 'negative':
        icon = Icons.trending_down;
        label = 'Негатив';
        break;
      default:
        icon = Icons.trending_flat;
        label = 'Смешано';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
