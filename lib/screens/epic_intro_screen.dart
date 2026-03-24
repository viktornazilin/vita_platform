import 'dart:math';

import 'package:flutter/material.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import '../services/user_service.dart';
import '../widgets/nest/nest_background.dart';
import '../widgets/nest/nest_blur_card.dart';
import '../widgets/nest/nest_pill.dart';

class EpicIntroScreen extends StatefulWidget {
  final UserService userService;

  const EpicIntroScreen({super.key, required this.userService});

  @override
  State<EpicIntroScreen> createState() => _EpicIntroScreenState();
}

class _EpicIntroScreenState extends State<EpicIntroScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _twinkleCtrl;
  late final Animation<double> _bgAnim;
  late final Animation<double> _twinkleAnim;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);
    _twinkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _bgAnim = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOutSine);
    _twinkleAnim = CurvedAnimation(parent: _twinkleCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _twinkleCtrl.dispose();
    super.dispose();
  }

  Future<void> _continue(BuildContext context) async {
    await widget.userService.markEpicIntroSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/onboarding');
  }

  Future<void> _skip(BuildContext context) async {
    await widget.userService.markEpicIntroSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final phone = constraints.maxWidth < 600;
        final compact = constraints.maxWidth < 360;
        final wide = constraints.maxWidth >= 920;
        final hp = EdgeInsets.symmetric(horizontal: phone ? 20 : 32);
        final starCount = max(
          50,
          ((constraints.maxWidth * constraints.maxHeight) /
                  (phone ? 26000 : 19000))
              .round(),
        );

        return Scaffold(
          body: NestBackground(
            useSoftGradient: true,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedBuilder(
                  animation: _bgAnim,
                  builder: (_, __) => CustomPaint(
                    painter: _NestBackdropPainter(
                      t: _bgAnim.value,
                      scheme: scheme,
                    ),
                  ),
                ),
                RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _twinkleAnim,
                    builder: (_, __) => IgnorePointer(
                      child: CustomPaint(
                        painter: _DustPainter(
                          count: starCount,
                          t: _twinkleAnim.value,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        hp.horizontal / 2,
                        14,
                        hp.horizontal / 2,
                        20,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: wide ? 760 : 560),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: TextButton(
                                onPressed: () => _skip(context),
                                child: Text(l.epicIntroSkip),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _FadeUp(
                              child: Center(
                                child: NestPill(
                                  leading: const Icon(Icons.home_work_outlined),
                                  text: 'Nest',
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _FadeUp(
                              delayMs: 80,
                              child: NestBlurCard(
                                radius: 32,
                                padding: EdgeInsets.all(phone ? 20 : 28),
                                child: Column(
                                  children: [
                                    _LogoPlate(height: phone ? 140 : 176),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Nest',
                                      textAlign: TextAlign.center,
                                      style: (wide
                                              ? tt.displayMedium
                                              : phone
                                                  ? tt.headlineMedium
                                                  : tt.headlineLarge)
                                          ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      l.epicIntroSubtitle,
                                      textAlign: TextAlign.center,
                                      style: tt.titleMedium?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                        height: 1.35,
                                        fontSize: compact ? 14 : null,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    const SizedBox(height: 22),
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton(
                                        onPressed: () => _continue(context),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: phone ? 2 : 4,
                                          ),
                                          child: Text(l.epicIntroPrimaryCta),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: () => _skip(context),
                                        child: Text(
                                          phone
                                              ? l.epicIntroLater
                                              : l.epicIntroSecondaryCta,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _FadeUp(
                              delayMs: 160,
                              child: Text(
                                l.epicIntroFooter,
                                textAlign: TextAlign.center,
                                style: tt.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LogoPlate extends StatelessWidget {
  final double height;

  const _LogoPlate({required this.height});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceContainer : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Image.asset(
        'assets/images/logo.png',
        height: height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _FadeUp extends StatefulWidget {
  final Widget child;
  final int delayMs;

  const _FadeUp({required this.child, this.delayMs = 0});

  @override
  State<_FadeUp> createState() => _FadeUpState();
}

class _FadeUpState extends State<_FadeUp> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: SlideTransition(
        position: _a.drive(
          Tween(begin: const Offset(0, 0.04), end: Offset.zero),
        ),
        child: widget.child,
      ),
    );
  }
}

class _NestBackdropPainter extends CustomPainter {
  final double t;
  final ColorScheme scheme;

  _NestBackdropPainter({required this.t, required this.scheme});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final base = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [scheme.surface, scheme.surfaceContainerLow],
      ).createShader(rect);
    canvas.drawRect(rect, base);

    void blob(Color color, Offset center, double radius, double opacity) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color.withOpacity(opacity), Colors.transparent],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }

    final w = size.width;
    final h = size.height;
    double sx(double phase, double amp) => sin(2 * pi * (t + phase)) * amp;
    double cx(double phase, double amp) => cos(2 * pi * (t + phase)) * amp;

    blob(
      scheme.primary,
      Offset(w * (0.22 + 0.03 * sx(0.0, 1)), h * (0.24 + 0.03 * cx(0.3, 1))),
      w * 0.55,
      0.10,
    );
    blob(
      scheme.secondary,
      Offset(w * (0.76 + 0.04 * sx(0.2, 1)), h * (0.45 + 0.03 * cx(0.5, 1))),
      w * 0.48,
      0.08,
    );
    blob(
      scheme.tertiary,
      Offset(w * (0.52 + 0.05 * sx(0.4, 1)), h * (0.84 + 0.04 * cx(0.1, 1))),
      w * 0.66,
      0.06,
    );
  }

  @override
  bool shouldRepaint(covariant _NestBackdropPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.scheme != scheme;
  }
}

class _DustPainter extends CustomPainter {
  final int count;
  final double t;
  final Color color;

  _DustPainter({required this.count, required this.t, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(42);
    for (var i = 0; i < count; i++) {
      final bx = rnd.nextDouble() * size.width;
      final by = rnd.nextDouble() * size.height;
      final dx = bx + sin((i * 0.37 + t * 6.28)) * 4;
      final dy = by + cos((i * 0.53 + t * 6.28)) * 4;
      final tw = (sin((i * 0.23) + t * 12.0) + 1) / 2;
      final radius = i % 7 == 0 ? 1.5 : 1.0;
      final paint = Paint()..color = color.withOpacity(0.05 + 0.10 * tw);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DustPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.count != count ||
        oldDelegate.color != color;
  }
}
