import 'package:flutter/material.dart';

import '../models/life_block.dart';

class LifeBlocksFirstSetupSheet extends StatefulWidget {
  final List<String> initialSelected;

  const LifeBlocksFirstSetupSheet({
    super.key,
    this.initialSelected = const [],
  });

  @override
  State<LifeBlocksFirstSetupSheet> createState() =>
      _LifeBlocksFirstSetupSheetState();
}

class _LifeBlocksFirstSetupSheetState extends State<LifeBlocksFirstSetupSheet> {
  late final Set<String> _selected;

  static const List<LifeBlock> _blocks = [
    LifeBlock.health,
    LifeBlock.career,
    LifeBlock.family,
    LifeBlock.finances,
    LifeBlock.education,
    LifeBlock.hobbies,
    LifeBlock.relationships,
    LifeBlock.spirituality,
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet();
  }

  String _lang(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    switch (code) {
      case 'ru':
      case 'en':
      case 'de':
      case 'fr':
      case 'es':
      case 'tr':
        return code;
      default:
        return 'en';
    }
  }

  Map<String, String> _copy(BuildContext context) {
    final lang = _lang(context);

    const data = <String, Map<String, String>>{
      'ru': {
        'title': 'Выбери сферы жизни',
        'subtitle':
            'Nest будет показывать аналитику и цели только по тем сферам, которые тебе действительно важны. Позже это можно изменить в профиле.',
        'hint': 'Выбери минимум одну сферу',
        'save': 'Продолжить',
        'selected': 'Выбрано',
      },
      'en': {
        'title': 'Choose life areas',
        'subtitle':
            'Nest will show goals and insights only for the areas that matter to you. You can change this later in your profile.',
        'hint': 'Choose at least one area',
        'save': 'Continue',
        'selected': 'Selected',
      },
      'de': {
        'title': 'Lebensbereiche auswählen',
        'subtitle':
            'Nest zeigt Ziele und Auswertungen nur für die Bereiche, die dir wichtig sind. Du kannst sie später im Profil ändern.',
        'hint': 'Wähle mindestens einen Bereich',
        'save': 'Weiter',
        'selected': 'Ausgewählt',
      },
      'fr': {
        'title': 'Choisis tes domaines de vie',
        'subtitle':
            'Nest affichera les objectifs et analyses uniquement pour les domaines importants pour toi. Tu pourras les modifier plus tard dans le profil.',
        'hint': 'Choisis au moins un domaine',
        'save': 'Continuer',
        'selected': 'Sélectionné',
      },
      'es': {
        'title': 'Elige tus áreas de vida',
        'subtitle':
            'Nest mostrará objetivos e insights solo para las áreas que son importantes para ti. Podrás cambiarlas después en el perfil.',
        'hint': 'Elige al menos un área',
        'save': 'Continuar',
        'selected': 'Seleccionado',
      },
      'tr': {
        'title': 'Yaşam alanlarını seç',
        'subtitle':
            'Nest yalnızca senin için önemli olan alanlara göre hedefler ve içgörüler gösterecek. Bunları daha sonra profilden değiştirebilirsin.',
        'hint': 'En az bir alan seç',
        'save': 'Devam et',
        'selected': 'Seçildi',
      },
    };

    return data[lang] ?? data['en']!;
  }

  String _blockLabel(BuildContext context, LifeBlock block) {
    final lang = _lang(context);
    final key = block.name;

    const labels = <String, Map<String, String>>{
      'health': {
        'ru': 'Здоровье',
        'en': 'Health',
        'de': 'Gesundheit',
        'fr': 'Santé',
        'es': 'Salud',
        'tr': 'Sağlık',
      },
      'career': {
        'ru': 'Карьера',
        'en': 'Career',
        'de': 'Karriere',
        'fr': 'Carrière',
        'es': 'Carrera',
        'tr': 'Kariyer',
      },
      'family': {
        'ru': 'Семья',
        'en': 'Family',
        'de': 'Familie',
        'fr': 'Famille',
        'es': 'Familia',
        'tr': 'Aile',
      },
      'finances': {
        'ru': 'Финансы',
        'en': 'Finances',
        'de': 'Finanzen',
        'fr': 'Finances',
        'es': 'Finanzas',
        'tr': 'Finans',
      },
      'education': {
        'ru': 'Образование',
        'en': 'Education',
        'de': 'Bildung',
        'fr': 'Éducation',
        'es': 'Educación',
        'tr': 'Eğitim',
      },
      'hobbies': {
        'ru': 'Хобби',
        'en': 'Hobbies',
        'de': 'Hobbys',
        'fr': 'Loisirs',
        'es': 'Hobbies',
        'tr': 'Hobiler',
      },
      'relationships': {
        'ru': 'Отношения',
        'en': 'Relationships',
        'de': 'Beziehungen',
        'fr': 'Relations',
        'es': 'Relaciones',
        'tr': 'İlişkiler',
      },
      'spirituality': {
        'ru': 'Духовность',
        'en': 'Spirituality',
        'de': 'Spiritualität',
        'fr': 'Spiritualité',
        'es': 'Espiritualidad',
        'tr': 'Maneviyat',
      },
    };

    return labels[key]?[lang] ?? labels[key]?['en'] ?? key;
  }

  String _blockSubtitle(BuildContext context, LifeBlock block) {
    final lang = _lang(context);
    final key = block.name;

    const subtitles = <String, Map<String, String>>{
      'health': {
        'ru': 'энергия, сон, привычки',
        'en': 'energy, sleep, habits',
        'de': 'Energie, Schlaf, Gewohnheiten',
        'fr': 'énergie, sommeil, habitudes',
        'es': 'energía, sueño, hábitos',
        'tr': 'enerji, uyku, alışkanlıklar',
      },
      'career': {
        'ru': 'работа, рост, проекты',
        'en': 'work, growth, projects',
        'de': 'Arbeit, Wachstum, Projekte',
        'fr': 'travail, croissance, projets',
        'es': 'trabajo, crecimiento, proyectos',
        'tr': 'iş, gelişim, projeler',
      },
      'family': {
        'ru': 'дом, близкие, баланс',
        'en': 'home, loved ones, balance',
        'de': 'Zuhause, Nähe, Balance',
        'fr': 'maison, proches, équilibre',
        'es': 'hogar, seres queridos, equilibrio',
        'tr': 'ev, sevdiklerim, denge',
      },
      'finances': {
        'ru': 'бюджет, расходы, цели',
        'en': 'budget, spending, goals',
        'de': 'Budget, Ausgaben, Ziele',
        'fr': 'budget, dépenses, objectifs',
        'es': 'presupuesto, gastos, metas',
        'tr': 'bütçe, harcama, hedefler',
      },
      'education': {
        'ru': 'обучение, навыки, книги',
        'en': 'learning, skills, books',
        'de': 'Lernen, Skills, Bücher',
        'fr': 'apprentissage, compétences, livres',
        'es': 'aprendizaje, habilidades, libros',
        'tr': 'öğrenme, beceriler, kitaplar',
      },
      'hobbies': {
        'ru': 'творчество, спорт, интересы',
        'en': 'creativity, sports, interests',
        'de': 'Kreativität, Sport, Interessen',
        'fr': 'créativité, sport, intérêts',
        'es': 'creatividad, deporte, intereses',
        'tr': 'yaratıcılık, spor, ilgi alanları',
      },
      'relationships': {
        'ru': 'общение, друзья, партнёр',
        'en': 'connection, friends, partner',
        'de': 'Austausch, Freunde, Partner',
        'fr': 'lien, amis, partenaire',
        'es': 'conexión, amigos, pareja',
        'tr': 'bağ, arkadaşlar, partner',
      },
      'spirituality': {
        'ru': 'смысл, ценности, спокойствие',
        'en': 'meaning, values, calm',
        'de': 'Sinn, Werte, Ruhe',
        'fr': 'sens, valeurs, calme',
        'es': 'sentido, valores, calma',
        'tr': 'anlam, değerler, sakinlik',
      },
    };

    return subtitles[key]?[lang] ?? subtitles[key]?['en'] ?? '';
  }

  IconData _iconFor(LifeBlock block) {
    switch (block) {
      case LifeBlock.health:
        return Icons.favorite_rounded;
      case LifeBlock.career:
        return Icons.work_rounded;
      case LifeBlock.family:
        return Icons.home_rounded;
      case LifeBlock.finances:
        return Icons.account_balance_wallet_rounded;
      case LifeBlock.education:
        return Icons.school_rounded;
      case LifeBlock.hobbies:
        return Icons.palette_rounded;
      case LifeBlock.relationships:
        return Icons.people_alt_rounded;
      case LifeBlock.spirituality:
        return Icons.self_improvement_rounded;
    }
  }

  Color _toneFor(BuildContext context, int index) {
    final cs = Theme.of(context).colorScheme;
    final colors = [
      cs.primary,
      cs.secondary,
      cs.tertiary,
      const Color(0xFFFF6B4A),
      const Color(0xFF8B5CF6),
      const Color(0xFF2FBF71),
      const Color(0xFFEF476F),
      const Color(0xFFFFB703),
    ];
    return colors[index % colors.length];
  }

  void _toggle(String key) {
    setState(() {
      if (_selected.contains(key)) {
        _selected.remove(key);
      } else {
        _selected.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final copy = _copy(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return WillPopScope(
      onWillPop: () async => _selected.isNotEmpty,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.84,
          minChildSize: 0.72,
          maxChildSize: 0.94,
          builder: (ctx, controller) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? cs.surfaceContainer
                      : Color.lerp(cs.surface, cs.secondary, 0.06),
                  border: Border.all(
                    color: Color.lerp(cs.outlineVariant, cs.secondary, 0.28)!,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.34 : 0.12),
                      blurRadius: 32,
                      offset: const Offset(0, -12),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -120,
                      right: -90,
                      child: _Glow(
                        color: cs.secondary.withOpacity(isDark ? 0.24 : 0.32),
                        size: 260,
                      ),
                    ),
                    Positioned(
                      bottom: -120,
                      left: -90,
                      child: _Glow(
                        color: cs.tertiary.withOpacity(isDark ? 0.18 : 0.24),
                        size: 260,
                      ),
                    ),
                    ListView(
                      controller: controller,
                      padding: EdgeInsets.fromLTRB(
                        18,
                        12,
                        18,
                        18 + MediaQuery.of(context).padding.bottom,
                      ),
                      children: [
                        Center(
                          child: Container(
                            width: 46,
                            height: 5,
                            decoration: BoxDecoration(
                              color: cs.onSurfaceVariant.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    cs.primary,
                                    cs.secondary,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: cs.secondary.withOpacity(
                                      isDark ? 0.18 : 0.28,
                                    ),
                                    blurRadius: 18,
                                    offset: const Offset(0, 9),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.tune_rounded,
                                color: cs.onPrimary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    copy['title']!,
                                    style: tt.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      height: 1.05,
                                      letterSpacing: -0.5,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    copy['subtitle']!,
                                    style: tt.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      height: 1.38,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Color.lerp(
                              cs.surfaceContainerHighest,
                              cs.secondary,
                              isDark ? 0.10 : 0.18,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Color.lerp(
                                cs.outlineVariant,
                                cs.secondary,
                                0.26,
                              )!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: cs.secondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${copy['selected']}: ${_selected.length}',
                                style: tt.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final twoColumns = constraints.maxWidth >= 520;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _blocks.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: twoColumns ? 2 : 1,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: twoColumns ? 2.15 : 3.65,
                              ),
                              itemBuilder: (context, index) {
                                final block = _blocks[index];
                                final key = block.name;
                                final selected = _selected.contains(key);
                                final tone = _toneFor(context, index);

                                return _BlockTile(
                                  title: _blockLabel(context, block),
                                  subtitle: _blockSubtitle(context, block),
                                  icon: _iconFor(block),
                                  tone: tone,
                                  selected: selected,
                                  onTap: () => _toggle(key),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        if (_selected.isEmpty) ...[
                          Text(
                            copy['hint']!,
                            textAlign: TextAlign.center,
                            style: tt.bodySmall?.copyWith(
                              color: cs.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        SizedBox(
                          height: 54,
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _selected.isEmpty
                                ? null
                                : () {
                                    final values = _blocks
                                        .map((b) => b.name)
                                        .where(_selected.contains)
                                        .toList(growable: false);

                                    Navigator.pop(context, values);
                                  },
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: Text(copy['save']!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BlockTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color tone;
  final bool selected;
  final VoidCallback onTap;

  const _BlockTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tone,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = selected
        ? Color.lerp(cs.surfaceContainerHighest, tone, isDark ? 0.20 : 0.26)
        : Color.lerp(cs.surfaceContainerHighest, tone, isDark ? 0.05 : 0.08);

    final border = selected
        ? Color.lerp(cs.outlineVariant, tone, 0.72)!
        : Color.lerp(cs.outlineVariant, tone, 0.24)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: border,
              width: selected ? 1.7 : 1.1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: tone.withOpacity(isDark ? 0.14 : 0.20),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? tone.withOpacity(isDark ? 0.36 : 0.24)
                        : cs.surface.withOpacity(isDark ? 0.18 : 0.62),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: selected
                          ? tone.withOpacity(0.72)
                          : cs.outlineVariant.withOpacity(0.65),
                    ),
                  ),
                  child: Icon(
                    selected ? Icons.check_rounded : icon,
                    color: selected ? tone : cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;

  const _Glow({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: size * 0.38,
              spreadRadius: size * 0.16,
            ),
          ],
        ),
      ),
    );
  }
}
