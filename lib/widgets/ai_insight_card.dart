// ai_insight_card.dart  ✅ фикс бага с иконкой + защита от null/пустых полей
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../models/ai/ai_insight.dart';
import '../widgets/info_chip.dart';

class AiInsightCard extends StatelessWidget {
  final AiInsight item;
  const AiInsightCard({super.key, required this.item});

  IconData _iconForType(String t) {
    switch (t) {
      case 'data_quality':
        return Icons.rule_rounded;
      case 'risk':
        return Icons.warning_amber_rounded;
      case 'emotional':
        return Icons.mood_rounded;
      case 'habit':
        return Icons.autorenew_rounded;
      case 'goal':
        return Icons.flag_rounded;
      default:
        return Icons.insights_rounded;
    }
  }

  String _labelForType(String t) => switch (t) {
    'data_quality' => 'Качество данных',
    'risk' => 'Риск',
    'emotional' => 'Эмоции',
    'habit' => 'Привычки',
    'goal' => 'Цели',
    _ => 'Инсайт',
  };

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

    final type = (item.type).toString();
    final typeIcon = _iconForType(type);
    final typeLabel = _labelForType(type);

    // ✅ защита от пустых impact полей
    final impactGoal = (item.impactGoal.isNotEmpty) ? item.impactGoal : '—';
    final strength = item.impactStrength.clamp(0.0, 1.0);
    final direction = item.impactDirection.isNotEmpty
        ? item.impactDirection
        : 'mixed';

    return _NestCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconBadge(icon: typeIcon), // ✅ теперь реально показывает icon
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF2E4B5A),
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _SoftChip(
                            icon: Icons.category_rounded,
                            text: typeLabel,
                          ),
                          _ImpactPill(direction: direction),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Insight text
            Text(
              item.insight,
              style: tt.bodyMedium?.copyWith(
                height: 1.25,
                color: cs.onSurface.withOpacity(0.92),
              ),
            ),

            const SizedBox(height: 12),

            // Metrics chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                InfoChip(icon: Icons.flag_outlined, text: impactGoal),
                InfoChip(
                  icon: Icons.tune_rounded,
                  text: _strengthLabel(strength),
                ),
                InfoChip(
                  icon: Icons.speed_rounded,
                  text: '${(strength * 100).round()}%',
                ),
              ],
            ),

            if (item.evidence.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Доказательства',
                style: tt.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2E4B5A),
                ),
              ),
              const SizedBox(height: 8),
              ...item.evidence
                  .take(3)
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _BulletLine(text: e),
                    ),
                  ),
            ],

            if ((item.suggestion ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              _SuggestionBox(text: item.suggestion!.trim()),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Nest UI (локально в файле — без внешних зависимостей)
// ============================================================================

class _NestCard extends StatelessWidget {
  final Widget child;
  const _NestCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.78),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD6E6F5)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A2B5B7A),
                blurRadius: 22,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  const _IconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6E6F5)),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 20,
          color: const Color(0xFF3AA8E6),
        ), // ✅ баг фикс
      ),
    );
  }
}

class _SoftChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SoftChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD6E6F5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF3AA8E6)),
          const SizedBox(width: 6),
          Text(
            text,
            style: tt.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2E4B5A),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String text;
  const _BulletLine({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 7),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFF3AA8E6),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: tt.bodySmall?.copyWith(
              height: 1.25,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestionBox extends StatelessWidget {
  final String text;
  const _SuggestionBox({required this.text});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD6E6F5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF3AA8E6)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: tt.bodySmall?.copyWith(
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E4B5A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactPill extends StatelessWidget {
  final String direction; // positive | negative | mixed
  const _ImpactPill({required this.direction});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String label;

    switch (direction) {
      case 'positive':
        icon = Icons.trending_up_rounded;
        label = 'Позитив';
        break;
      case 'negative':
        icon = Icons.trending_down_rounded;
        label = 'Негатив';
        break;
      default:
        icon = Icons.trending_flat_rounded;
        label = 'Смешано';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD6E6F5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFF2E4B5A).withOpacity(0.70),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFF2E4B5A).withOpacity(0.75),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
