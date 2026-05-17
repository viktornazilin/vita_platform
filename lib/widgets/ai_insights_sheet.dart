// ai_insights_sheet.dart  ✅ i18n: вынесли тексты в t.* ключи
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nest_app/l10n/app_localizations.dart';

import '../../models/ai/ai_insight.dart';
import 'ai_insight_card.dart';

class AiInsightsSheet extends StatefulWidget {
  const AiInsightsSheet({super.key});

  @override
  State<AiInsightsSheet> createState() => _AiInsightsSheetState();
}

class _AiInsightsSheetState extends State<AiInsightsSheet> {
  bool _loading = false;
  bool _confirmed = false; // ✅ запуск только после подтверждения

  bool _checkingConsent = true;
  bool _aiConsentGranted = false;

  String? _error;

  List<AiInsight> _insights = [];

  // опционально: можно показать информацию о последнем запуске
  Map<String, dynamic>? _runMeta; // {id, created_at} или всё что вернёт функция
  String _period = 'last_30_days';


  Future<bool> _ensureAiProcessingConsent({bool forceDialog = false}) async {
    if (!mounted) return false;

    try {
      final alreadyAccepted = await _hasStoredAiProcessingConsent();
      if (!mounted) return false;

      if (alreadyAccepted && !forceDialog) {
        setState(() => _aiConsentGranted = true);
        return true;
      }

      final accepted = await _showAiProcessingConsentDialog();
      if (accepted != true) {
        if (mounted) setState(() => _aiConsentGranted = false);
        return false;
      }

      await _saveAiProcessingConsent();

      if (!mounted) return false;
      setState(() => _aiConsentGranted = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).aiInsightsConsentSaved)),
      );

      return true;
    } catch (e) {
      if (!mounted) return false;
      setState(() {
        _error = AppLocalizations.of(context).aiInsightsConsentCheckFailed(e.toString());
      });
      return false;
    }
  }

  Future<bool> _hasStoredAiProcessingConsent() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;

    if ((userId ?? '').trim().isEmpty) return false;

    final row = await client
        .from('users')
        .select('ai_processing_consent')
        .eq('id', userId!)
        .maybeSingle();

    if (row == null) return false;
    return row['ai_processing_consent'] == true;
  }

  Future<void> _saveAiProcessingConsent() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;

    if ((userId ?? '').trim().isEmpty) {
      throw Exception(AppLocalizations.of(context).aiInsightsUserNotAuthorized);
    }

    await client.from('users').update({
      'ai_processing_consent': true,
      'ai_processing_consent_at': DateTime.now().toUtc().toIso8601String(),
      'ai_processing_consent_version': '2026-05-17',
    }).eq('id', userId!);
  }

  Future<bool?> _showAiProcessingConsentDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final tt = Theme.of(ctx).textTheme;
        final cs = Theme.of(ctx).colorScheme;

        return AlertDialog(
          title: Text(
            AppLocalizations.of(ctx).aiInsightsConsentTitle,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(ctx).aiInsightsConsentBody,
                  style: tt.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(ctx).aiInsightsConsentDeclineBody,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                _AiConsentLegalLinks(onOpen: _openLegalUrl),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.of(ctx).aiInsightsConsentNotNow),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(ctx, true),
              icon: const Icon(Icons.check_rounded),
              label: Text(AppLocalizations.of(ctx).aiInsightsConsentAgree),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openLegalUrl(String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).aiInsightsOpenLinkFailed(url))),
      );
    }
  }

  Future<void> _load({bool requireConfirm = true}) async {
    if (_loading) return;

    if (!_aiConsentGranted) {
      final ok = await _ensureAiProcessingConsent(forceDialog: true);
      if (!mounted) return;
      if (!ok) {
        setState(() {
          _checkingConsent = false;
          _aiConsentGranted = false;
        });
        return;
      }
    }

    // если пользователь ещё не подтвердил запуск — просим подтверждение
    if (requireConfirm && !_confirmed) {
      final ok = await _confirmRunDialog();
      if (ok != true) return;
      if (!mounted) return;
      setState(() => _confirmed = true);
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await Supabase.instance.client.functions.invoke(
        'ai-insights',
        body: {
          'period': _period,
          // LLM включаем только для 7 дней.
          // Для 30/90 дней используем быстрый rule-based анализ,
          // чтобы Edge Function не упиралась в timeout и большой payload.
          'use_llm': _period == 'last_7_days',
        },
      );

      final raw = res.data is String
          ? jsonDecode(res.data as String)
          : res.data;

      final map = raw is Map
          ? raw.cast<String, dynamic>()
          : <String, dynamic>{'insights': raw};

      final items = _parseInsightsFromResponse(map);

      setState(() {
        _insights = items;
        _runMeta = (map['run'] is Map)
            ? (map['run'] as Map).cast<String, dynamic>()
            : null;
      });
    } catch (e) {
      if (mounted) {
        final t9n = AppLocalizations.of(context);
        setState(() => _error = t9n.aiInsightsErrorAi(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<AiInsight> _parseInsightsFromResponse(Map<String, dynamic> map) {
    // Поддерживаем оба формата:
    // 1) старый: { "insights": [ ... ] }
    // 2) новый: { "insights": { "summary": "...", "insights": [ ... ] } }
    final dynamic insightsRoot = map['insights'];

    final List<dynamic> rawList;
    if (insightsRoot is List) {
      rawList = insightsRoot;
    } else if (insightsRoot is Map) {
      final nested = insightsRoot['insights'];
      rawList = nested is List ? nested : const [];
    } else {
      rawList = const [];
    }

    return rawList
        .whereType<Map>()
        .map((e) => _normalizeInsightJson(e.cast<String, dynamic>()))
        .map(AiInsight.fromJson)
        .toList();
  }

  Map<String, dynamic> _normalizeInsightJson(Map<String, dynamic> json) {
    // Edge Function v2 обычно возвращает поле "insight".
    // Если LLM вернул "description" или "text", UI всё равно не должен падать.
    final insightText = (json['insight'] ??
            json['description'] ??
            json['text'] ??
            json['body'] ??
            '')
        .toString();

    final title = (json['title'] ?? json['name'] ?? AppLocalizations.of(context).aiInsightsDefaultTitle).toString();
    final type = (json['type'] ?? json['category'] ?? 'general').toString();

    final evidenceRaw = json['evidence'];
    final evidence = evidenceRaw is List
        ? evidenceRaw.map((e) => e.toString()).toList()
        : <String>[];

    final strengthRaw = json['impact_strength'] ??
        json['impactStrength'] ??
        json['strength'] ??
        0.5;

    final strength = strengthRaw is num
        ? strengthRaw.toDouble()
        : double.tryParse(strengthRaw.toString()) ?? 0.5;

    return <String, dynamic>{
      ...json,
      'title': title,
      'type': type,
      'insight': insightText,
      'evidence': evidence,
      'suggestion': (json['suggestion'] ?? json['recommendation'] ?? '').toString(),
      'impact_goal': (json['impact_goal'] ?? json['impactGoal'] ?? '').toString(),
      'impact_strength': strength.clamp(0.0, 1.0),
      'impact_direction': (json['impact_direction'] ??
              json['impactDirection'] ??
              json['direction'] ??
              'mixed')
          .toString(),
    };
  }

  // ❌ УБРАЛИ авто-запуск в initState
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapConsent());
  }

  Future<void> _bootstrapConsent() async {
    final ok = await _ensureAiProcessingConsent();
    if (!mounted) return;

    setState(() {
      _checkingConsent = false;
      _aiConsentGranted = ok;
    });
  }

  Future<bool?> _confirmRunDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final tt = Theme.of(ctx).textTheme;
        final t9n = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(
            t9n.aiInsightsConfirmTitle,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          content: Text(t9n.aiInsightsConfirmBody, style: tt.bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t9n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(t9n.aiInsightsConfirmRun),
            ),
          ],
        );
      },
    );
  }

  String _periodLabel(BuildContext context, String v) {
    final t9n = AppLocalizations.of(context);
    switch (v) {
      case 'last_7_days':
        return t9n.aiInsightsPeriod7;
      case 'last_30_days':
        return t9n.aiInsightsPeriod30;
      case 'last_90_days':
        return t9n.aiInsightsPeriod90;
      default:
        return t9n.aiInsightsPeriod30;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t9n = AppLocalizations.of(context);

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
                              t9n.aiInsightsTitle,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF2E4B5A),
                                  ),
                            ),
                            const Spacer(),

                            _PeriodPill(
                              label: _periodLabel(context, _period),
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

                                // ✅ НЕ запускаем сразу. Просто меняем период и просим нажать запуск.
                                setState(() {
                                  _period = picked;
                                  _error = null;
                                  _insights = [];
                                  _runMeta = null;
                                  // _confirmed оставляем как есть
                                });
                              },
                            ),

                            const SizedBox(width: 10),

                            _ActionButton(
                              loading: _loading,
                              confirmed: _confirmed,
                              onTap: _loading
                                  ? null
                                  : () => _load(requireConfirm: true),
                            ),
                          ],
                        ),
                      ),

                      if (_runMeta != null) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: _InfoPill(
                            text: t9n.aiInsightsLastRun(
                              ((_runMeta!['created_at'] ?? '').toString())
                                  .trim(),
                            ),
                          ),
                        ),
                      ],

                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: _ErrorPill(text: _error!, color: cs.error),
                        ),
                      ],

                      const SizedBox(height: 10),

                      Expanded(
                        child: _checkingConsent
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircularProgressIndicator.adaptive(),
                                    const SizedBox(height: 14),
                                    Text(AppLocalizations.of(context).aiInsightsCheckingConsent),
                                  ],
                                ),
                              )
                            : !_aiConsentGranted
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: _ConsentRequiredBox(
                                  onAccept: () async {
                                    setState(() => _checkingConsent = true);
                                    final ok = await _ensureAiProcessingConsent(forceDialog: true);
                                    if (!mounted) return;
                                    setState(() {
                                      _checkingConsent = false;
                                      _aiConsentGranted = ok;
                                    });
                                  },
                                ),
                              )
                            : !_confirmed && _insights.isEmpty && !_loading
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: _EmptyHint(
                                  title: t9n.aiInsightsEmptyNotRunTitle,
                                  subtitle: t9n.aiInsightsEmptyNotRunSubtitle,
                                  ctaLabel: t9n.aiInsightsCtaRun,
                                  onCta: () => _load(requireConfirm: true),
                                ),
                              )
                            : _loading && _insights.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : _insights.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: _EmptyHint(
                                  title: t9n.aiInsightsEmptyNoInsightsTitle,
                                  subtitle:
                                      t9n.aiInsightsEmptyNoInsightsSubtitle,
                                  ctaLabel: t9n.aiInsightsCtaRunAgain,
                                  onCta: () => _load(requireConfirm: true),
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


class _ConsentRequiredBox extends StatelessWidget {
  const _ConsentRequiredBox({required this.onAccept});

  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).aiInsightsConsentRequiredTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context).aiInsightsConsentRequiredBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onAccept,
            icon: const Icon(Icons.verified_user_rounded),
            label: Text(AppLocalizations.of(context).aiInsightsGiveConsent),
          ),
        ],
      ),
    );
  }
}

class _AiConsentLegalLinks extends StatelessWidget {
  const _AiConsentLegalLinks({required this.onOpen});

  final Future<void> Function(String url) onOpen;

  static const _privacyUrl = 'https://nest-landing-lemon.vercel.app/privacy';
  static const _datenschutzUrl = 'https://nest-landing-lemon.vercel.app/datenschutz';
  static const _termsUrl = 'https://nest-landing-lemon.vercel.app/terms';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget link(String label, String url) {
      return InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => onOpen(url),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.primary.withOpacity(0.16)),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        link(AppLocalizations.of(context).aiInsightsPrivacyPolicy, _privacyUrl),
        link(AppLocalizations.of(context).aiInsightsDatenschutz, _datenschutzUrl),
        link(AppLocalizations.of(context).aiInsightsTermsOfUse, _termsUrl),
      ],
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
  final bool confirmed;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.loading,
    required this.confirmed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = confirmed ? Icons.refresh_rounded : Icons.play_arrow_rounded;

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
              : Icon(icon, size: 20, color: const Color(0xFF3AA8E6)),
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

class _InfoPill extends StatelessWidget {
  final String text;
  const _InfoPill({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withOpacity(0.14)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF2E4B5A),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? ctaLabel;
  final VoidCallback? onCta;

  const _EmptyHint({
    required this.title,
    required this.subtitle,
    this.ctaLabel,
    this.onCta,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          if (ctaLabel != null && onCta != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onCta,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(ctaLabel!),
              ),
            ),
          ],
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
    final t9n = AppLocalizations.of(context);

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
              item(
                'last_7_days',
                t9n.aiInsightsPeriod7,
                Icons.calendar_view_week_rounded,
              ),
              const SizedBox(height: 10),
              item(
                'last_30_days',
                t9n.aiInsightsPeriod30,
                Icons.calendar_month_rounded,
              ),
              const SizedBox(height: 10),
              item(
                'last_90_days',
                t9n.aiInsightsPeriod90,
                Icons.calendar_view_month_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
