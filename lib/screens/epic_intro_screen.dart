import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/user_service.dart';

class EpicIntroScreen extends StatefulWidget {
  final UserService userService;
  const EpicIntroScreen({super.key, required this.userService});

  @override
  State<EpicIntroScreen> createState() => _EpicIntroScreenState();
}

class _EpicIntroScreenState extends State<EpicIntroScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;      // аурора
  late final AnimationController _twinkleCtrl; // звезды
  late final Animation<double> _bgAnim;
  late final Animation<double> _twinkleAnim;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat(reverse: true);
    _twinkleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat();
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
    Navigator.of(context).pushReplacementNamed('/archetype');
  }

  Future<void> _skip(BuildContext context) async {
    await widget.userService.markEpicIntroSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;
        final compact = w < 360;           // очень узкие (iPhone SE)
        final phone   = w < 600;           // телефоны
        final wide    = w >= 900;          // десктоп/планшет шире
        final hp = EdgeInsets.symmetric(horizontal: phone ? 20 : 32);
        final vp = EdgeInsets.symmetric(vertical: phone ? 16 : 24);

        // адаптивные размеры шрифтов
        final titleStyle = (wide ? tt.displayMedium : phone ? tt.headlineMedium : tt.headlineSmall)
            ?.copyWith(color: Colors.white.withOpacity(0.96), fontWeight: FontWeight.w800, letterSpacing: 0.5);
        final subtitleStyle = tt.titleMedium?.copyWith(
          color: Colors.white.withOpacity(0.88),
          height: 1.35,
          fontWeight: FontWeight.w500,
          fontSize: compact ? 14 : null,
        );

        // звёзд столько, чтобы не перегружать слабые экраны
        final starCount = max(80, ((w * h) / (phone ? 18000 : 12000)).round());

        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // фон
              AnimatedBuilder(
                animation: _bgAnim,
                builder: (_, __) => CustomPaint(painter: _AuroraPainter(t: _bgAnim.value, cs: cs)),
              ),
              // звезды
              RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _twinkleAnim,
                  builder: (_, __) => IgnorePointer(
                    child: Opacity(
                      opacity: 0.22,
                      child: CustomPaint(
                        painter: _StarsPainter(t: _twinkleAnim.value, starCount: starCount),
                      ),
                    ),
                  ),
                ),
              ),

              // контент
              SafeArea(
                child: Padding(
                  padding: hp + vp,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          style: TextButton.styleFrom(foregroundColor: Colors.white.withOpacity(0.9)),
                          onPressed: () => _skip(context),
                          child: const Text('Пропустить'),
                        ),
                      ),
                      const Spacer(flex: 2),

                      _FadeUp(
                        delayMs: 0,
                        child: Text('VitaPlatform', textAlign: TextAlign.center, style: titleStyle),
                      ),
                      SizedBox(height: phone ? 12 : 16),
                      _FadeUp(
                        delayMs: 120,
                        child: Text(
                          'Каждый день ты расходуешь свои ресурсы.\nПора управлять ими',
                          textAlign: TextAlign.center,
                          style: subtitleStyle,
                        ),
                      ),

                      const Spacer(),

                      // CTA-панель с max шириной на широких
                      _FadeUp(
                        delayMs: 240,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: wide ? 560 : 720),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(phone ? 14 : 18),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withOpacity(0.24)),
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: FilledButton(
                                          style: FilledButton.styleFrom(
                                            backgroundColor: cs.primaryContainer.withOpacity(0.85),
                                            foregroundColor: cs.onPrimaryContainer,
                                            padding: EdgeInsets.symmetric(vertical: phone ? 14 : 16),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          ),
                                          onPressed: () => _continue(context),
                                          child: Text(
                                            'Начать мой путь',
                                            style: TextStyle(
                                              fontSize: phone ? 16 : 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: Colors.white.withOpacity(0.35)),
                                            foregroundColor: Colors.white.withOpacity(0.9),
                                            padding: EdgeInsets.symmetric(vertical: phone ? 12 : 14),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          ),
                                          onPressed: () => _skip(context),
                                          child: Text(phone ? 'Позже' : 'Войти в аккаунт'),
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
                      SizedBox(height: phone ? 8 : 12),

                      _FadeUp(
                        delayMs: 360,
                        child: Text(
                          'Ты всегда сможешь вернуться к прологу в настройках.',
                          textAlign: TextAlign.center,
                          style: tt.bodySmall?.copyWith(color: Colors.white.withOpacity(0.7)),
                        ),
                      ),

                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Плавное появление с подъёмом
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
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    Future.delayed(Duration(milliseconds: widget.delayMs), () { if (mounted) _c.forward(); });
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: SlideTransition(
        position: _a.drive(Tween(begin: const Offset(0, 0.04), end: Offset.zero)),
        child: widget.child,
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double t; // 0..1
  final ColorScheme cs;
  _AuroraPainter({required this.t, required this.cs});

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;

    final base = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F172A), Color(0xFF111827)],
      ).createShader(r);
    canvas.drawRect(r, base);

    void blob(Color color, Offset center, double radius, double opacity) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color.withOpacity(opacity), Colors.transparent],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }

    final w = size.width;
    final h = size.height;

    double sx(double phase, double amp) => (sin(2 * pi * (t + phase)) * amp);
    double cx(double phase, double amp) => (cos(2 * pi * (t + phase)) * amp);

    blob(cs.primary.withBlue(255), Offset(w * (0.25 + 0.05 * sx(0.0, 1)), h * (0.35 + 0.04 * cx(0.3, 1))), w * 0.65, 0.55);
    blob(cs.tertiary,             Offset(w * (0.75 + 0.05 * sx(0.2, 1)), h * (0.40 + 0.04 * cx(0.5, 1))), w * 0.60, 0.45);
    blob(cs.secondary,            Offset(w * (0.50 + 0.07 * sx(0.4, 1)), h * (0.70 + 0.05 * cx(0.1, 1))), w * 0.70, 0.35);
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) => old.t != t || old.cs != cs;
}

class _StarsPainter extends CustomPainter {
  final int starCount;
  final double t; // 0..1
  _StarsPainter({required this.starCount, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(42);
    for (int i = 0; i < starCount; i++) {
      final bx = rnd.nextDouble() * size.width;
      final by = rnd.nextDouble() * size.height;

      final dx = bx + sin((i * 0.37 + t * 6.28)) * 6;
      final dy = by + cos((i * 0.53 + t * 6.28)) * 6;

      final tw = (sin((i * 0.23) + t * 12.0) + 1) / 2;
      final radius = (i % 7 == 0) ? 1.7 : 1.1;
      final paint = Paint()..color = Colors.white.withOpacity(0.25 + 0.55 * tw);

      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter old) => old.t != t || old.starCount != starCount;
}
