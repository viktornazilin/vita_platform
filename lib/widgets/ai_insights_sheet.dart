import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/ai/ai_insight.dart';
import 'ai_insight_card.dart';

class AiInsightsSheet extends StatefulWidget {
  const AiInsightsSheet({super.key});

  @override
  State<AiInsightsSheet> createState() => _AiInsightsSheetState();
}

class _AiInsightsSheetState extends State<AiInsightsSheet> {
  bool _loading = false;
  String? _error;
  List<AiInsight> _insights = [];

  String _period = 'last_30_days';

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await Supabase.instance.client.functions.invoke(
        'ai-insights',
        body: {'period': _period},
      );

      final raw = res.data is String
          ? jsonDecode(res.data as String)
          : res.data;

      // Edge Function возвращает { insights: [...] }
      final map = (raw as Map).cast<String, dynamic>();
      final list = (map['insights'] as List?) ?? const [];

      final items = list
          .map((e) => AiInsight.fromJson((e as Map).cast<String, dynamic>()))
          .toList();

      setState(() => _insights = items);
    } catch (e) {
      setState(() => _error = 'Ошибка AI: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _periodLabel(String v) => switch (v) {
    'last_7_days' => '7 дней',
    'last_30_days' => '30 дней',
    'last_90_days' => '90 дней',
    _ => '30 дней',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottom =
        MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.90,
          minChildSize: 0.60,
          maxChildSize: 0.95,
          builder: (ctx, controller) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: _NestSheetSurface(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _Handle(),
                      const SizedBox(height: 10),

                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            Text(
                              'AI-инсайты',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF2E4B5A),
                                  ),
                            ),
                            const Spacer(),

                            _PeriodPill(
                              label: _periodLabel(_period),
                              enabled: !_loading,
                              onTap: () async {
                                final picked =
                                    await showModalBottomSheet<String>(
                                      context: context,
                                      showDragHandle: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (c) =>
                                          _PeriodPickerSheet(current: _period),
                                    );
                                if (picked == null || picked == _period) return;
                                setState(() => _period = picked);
                                _load();
                              },
                            ),

                            const SizedBox(width: 10),

                            _ActionButton(
                              loading: _loading,
                              onTap: _loading ? null : _load,
                            ),
                          ],
                        ),
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: _ErrorPill(text: _error!, color: cs.error),
                        ),
                      ],

                      const SizedBox(height: 10),

                      Expanded(
                        child: _loading && _insights.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : _insights.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: _EmptyHint(
                                  title: 'Инсайтов пока нет',
                                  subtitle:
                                      'Добавь данных (цели, настроение, привычки, расходы) и нажми «Обновить».',
                                ),
                              )
                            : ListView.separated(
                                controller: controller,
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  8,
                                  12,
                                  16,
                                ),
                                itemCount: _insights.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (_, i) =>
                                    AiInsightCard(item: _insights[i]),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// Nest UI building blocks (внутри файла — без зависимостей)
// ============================================================================

class _NestSheetSurface extends StatelessWidget {
  final Widget child;
  const _NestSheetSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: const Color(0xFFD6E6F5)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A2B5B7A),
                blurRadius: 30,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0xFF2E4B5A).withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _PeriodPill extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _PeriodPill({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF4FAFF),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFD6E6F5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded, size: 16, color: cs.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E4B5A),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.expand_more_rounded,
              size: 18,
              color: const Color(0xFF2E4B5A).withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onTap;

  const _ActionButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFF4FAFF),
          border: Border.all(color: const Color(0xFFD6E6F5)),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(
                  Icons.refresh_rounded,
                  size: 20,
                  color: Color(0xFF3AA8E6),
                ),
        ),
      ),
    );
  }
}

class _ErrorPill extends StatelessWidget {
  final String text;
  final Color color;
  const _ErrorPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String title;
  final String subtitle;
  const _EmptyHint({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD6E6F5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFF3AA8E6)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2E4B5A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: tt.bodyMedium?.copyWith(
                    height: 1.25,
                    color: const Color(0xFF2E4B5A).withOpacity(0.70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodPickerSheet extends StatelessWidget {
  final String current;
  const _PeriodPickerSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    Widget item(String value, String label, IconData icon) {
      final selected = value == current;
      return InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.pop(context, value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF3AA8E6).withOpacity(0.10) : null,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD6E6F5)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF3AA8E6)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E4B5A),
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_rounded, color: Color(0xFF3AA8E6)),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: const Color(0xFFD6E6F5)),
          ),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E4B5A).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              item('last_7_days', '7 дней', Icons.calendar_view_week_rounded),
              const SizedBox(height: 10),
              item('last_30_days', '30 дней', Icons.calendar_month_rounded),
              const SizedBox(height: 10),
              item(
                'last_90_days',
                '90 дней',
                Icons.calendar_view_month_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
