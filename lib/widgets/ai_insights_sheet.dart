import 'dart:convert';

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

      // Edge Function у нас возвращает JSON-объект {insights:[...]} (как мы делали)
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
          initialChildSize: 0.9,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (ctx, controller) => Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'AI-инсайты',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    DropdownButton<String>(
                      value: _period,
                      items: const [
                        DropdownMenuItem(
                          value: 'last_7_days',
                          child: Text('7 дней'),
                        ),
                        DropdownMenuItem(
                          value: 'last_30_days',
                          child: Text('30 дней'),
                        ),
                        DropdownMenuItem(
                          value: 'last_90_days',
                          child: Text('90 дней'),
                        ),
                      ],
                      onChanged: _loading
                          ? null
                          : (v) {
                              if (v == null) return;
                              setState(() => _period = v);
                              _load();
                            },
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _loading ? null : _load,
                      icon: _loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      label: const Text('Обновить'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(_error!, style: TextStyle(color: cs.error)),
                ),
              const SizedBox(height: 4),
              Expanded(
                child: _loading && _insights.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _insights.isEmpty
                    ? const Center(
                        child: Text(
                          'Инсайтов пока нет — добавь данных и обнови.',
                        ),
                      )
                    : ListView.separated(
                        controller: controller,
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                        itemCount: _insights.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) =>
                            AiInsightCard(item: _insights[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
