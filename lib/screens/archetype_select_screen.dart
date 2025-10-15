import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/user_service.dart';
import 'responsive.dart';

class ArchetypeSelectScreen extends StatelessWidget {
  final UserService userService;
  const ArchetypeSelectScreen({super.key, required this.userService});

  @override
  Widget build(BuildContext context) {
    final archetypes = <_Archetype>[
      _Archetype(key: 'game',     title: 'Игровой мир',      emoji: '🎮', desc: 'RPG/киберпанк стиль'),
      _Archetype(key: 'sport',    title: 'Спорт',            emoji: '🏆', desc: 'Динамика и дисциплина'),
      _Archetype(key: 'business', title: 'Бизнес',           emoji: '💼', desc: 'Стратегия и рост'),
      _Archetype(key: 'creative', title: 'Творчество',       emoji: '🎭', desc: 'Сцена и вдохновение'),
      _Archetype(key: 'travel',   title: 'Путешествия',      emoji: '🌍', desc: 'Исследование мира'),
      _Archetype(key: 'science',  title: 'Наука и знания',   emoji: '📚', desc: 'Эксперименты и обучение'),
      _Archetype(key: 'balance',  title: 'Баланс/ЗОЖ',       emoji: '🌱', desc: 'Гармония и энергия'),
      _Archetype(key: 'family',   title: 'Семья и забота',   emoji: '❤️', desc: 'Тёплые связи'),
    ];

    // адаптив: количество колонок и аспект ячейки
    final cols = context.responsiveColumns(min: 2, mid: 3, max: 4);
    final ratio = context.isCompact ? 1.06 : 1.2;

    return Scaffold(
      appBar: AppBar(title: const Text('Выбор стиля героя')),
      body: Padding(
        padding: context.pagePadding,
        child: CenteredConstrained(
          maxWidth: context.maxContentWidth,
          child: Column(
            crossAxisAlignment:
                context.isCompact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(
                'Кем бы ты был в этой истории?',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: context.isCompact ? TextAlign.center : TextAlign.start,
              ),
              const SizedBox(height: 12),

              // фокус-область для web/desktop клавиатурной навигации
              Expanded(
                child: FocusScope(
                  child: FocusTraversalGroup(
                    policy: ReadingOrderTraversalPolicy(),
                    child: GridView.builder(
                      itemCount: archetypes.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: ratio,
                      ),
                      itemBuilder: (_, i) => _ArchetypeCard(
                        data: archetypes[i],
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          await userService.saveArchetype(archetypes[i].key);
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pushReplacementNamed('/onboarding');
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Text(
                'От твоего выбора зависит тон общения, но цель одна — баланс ресурсов и персональные рекомендации.',
                textAlign: context.isCompact ? TextAlign.center : TextAlign.start,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Archetype {
  final String key;
  final String title;
  final String emoji;
  final String desc;
  const _Archetype({required this.key, required this.title, required this.emoji, required this.desc});
}

/// Карточка — stateful для анимации нажатия и фокус-индикатора
class _ArchetypeCard extends StatefulWidget {
  final _Archetype data;
  final VoidCallback onTap;
  const _ArchetypeCard({required this.data, required this.onTap});

  @override
  State<_ArchetypeCard> createState() => _ArchetypeCardState();
}

class _ArchetypeCardState extends State<_ArchetypeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surface;
    final outline = scheme.outlineVariant.withOpacity(0.6);

    return Semantics(
      button: true,
      label: '${widget.data.title}. ${widget.data.desc}',
      child: Focus(
        onFocusChange: (_) => setState(() {}),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 120),
            scale: _pressed ? 0.98 : 1.0,
            curve: Curves.easeOut,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                splashFactory: InkSparkle.splashFactory,
                onTap: widget.onTap,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: base.withOpacity(0.9),
                    border: Border.all(color: outline),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [base.withOpacity(0.95), base.withOpacity(0.88)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -24,
                        top: -24,
                        child: _AccentBlob(color: scheme.primary.withOpacity(0.10)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 220),
                              tween: Tween(begin: 0.96, end: 1.0),
                              curve: Curves.easeOutBack,
                              builder: (_, v, child) => Transform.scale(scale: v, child: child),
                              child: Text(widget.data.emoji, style: const TextStyle(fontSize: 40)),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.data.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.data.desc,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13, height: 1.2),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // индикатор клавиатурного фокуса
                      Positioned.fill(
                        child: IgnorePointer(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Focus.of(context).hasFocus
                                  ? Border.all(color: scheme.primary, width: 2)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccentBlob extends StatelessWidget {
  final Color color;
  const _AccentBlob({required this.color});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(width: 80, height: 80, color: color),
      ),
    );
  }
}
