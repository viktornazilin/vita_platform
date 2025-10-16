import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/user_service.dart';

/// Палитра Nest
const _kOffWhite = Color(0xFFFAF8F5); // мягкий фон
const _kCloud    = Color(0xFFEFF6FB); // лёгкий облачный слой
const _kSky      = Color(0xFF3FA7D6); // основной акцент (как в логотипе)
const _kSkyDeep  = Color(0xFF2C7FB2); // тёмный акцент
const _kInk      = Color(0xFF163043); // основной текст
const _kInkSoft  = Color(0x99163043); // подписи/вторичный

class EpicIntroScreen extends StatefulWidget {
  final UserService userService;
  const EpicIntroScreen({super.key, required this.userService});

  @override
  State<EpicIntroScreen> createState() => _EpicIntroScreenState();
}

class _EpicIntroScreenState extends State<EpicIntroScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;      // облачные переливы
  late final AnimationController _twinkleCtrl; // пылинки
  late final Animation<double> _bgAnim;
  late final Animation<double> _twinkleAnim;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 18))
      ..repeat(reverse: true);
    _twinkleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat();
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

        // Адаптивная типографика под светлую тему
        final titleStyle = (wide ? tt.displayMedium : phone ? tt.headlineMedium : tt.headlineSmall)
            ?.copyWith(color: _kInk, fontWeight: FontWeight.w800, letterSpacing: 0.2);
        final subtitleStyle = tt.titleMedium?.copyWith(
          color: _kInkSoft,
          height: 1.35,
          fontWeight: FontWeight.w500,
          fontSize: compact ? 14 : null,
        );

        // «Пылинок» достаточно, но экономно
        final starCount = max(60, ((w * h) / (phone ? 22000 : 16000)).round());

        return Scaffold(
          backgroundColor: _kOffWhite,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Фон — мягкие облачные переливы в фирменных тонах
              AnimatedBuilder(
                animation: _bgAnim,
                builder: (_, __) => CustomPaint(
                  painter: _CloudyPainter(t: _bgAnim.value),
                ),
              ),
              // Едва заметные «пылинки»
              RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _twinkleAnim,
                  builder: (_, __) => IgnorePointer(
                    child: Opacity(
                      opacity: 0.12,
                      child: CustomPaint(
                        painter: _DustPainter(t: _twinkleAnim.value, count: starCount),
                      ),
                    ),
                  ),
                ),
              ),

              // Контент
              SafeArea(
                child: Padding(
                  padding: hp + vp,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: _kInk.withOpacity(0.7),
                          ),
                          onPressed: () => _skip(context),
                          child: const Text('Пропустить'),
                        ),
                      ),
                      const Spacer(flex: 2),

                      // Логотип на «родном» фоне + заголовок
                      _FadeUp(
                        delayMs: 0,
                        child: Column(
                          children: [
                            _LogoPlate(
                              // ⇩ высота увеличена ~в 1.7× (подбирайте под свой ассет)
                              height: phone ? 148 : 192,
                              borderRadius: 28,
                              padding: EdgeInsets.symmetric(
                                horizontal: phone ? 20 : 28,
                                vertical: phone ? 16 : 22,
                              ),
                              // путь к вашему ассету
                              assetPath: 'assets/images/logo.png',
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: phone ? 12 : 16),
                      _FadeUp(
                        delayMs: 120,
                        child: Text(
                          'Дом для мыслей. Место, где растут цели,\nмечты и планы — бережно и осознанно.',
                          textAlign: TextAlign.center,
                          style: subtitleStyle,
                        ),
                      ),

                      const Spacer(),

                      // CTA-панель
                      _FadeUp(
                        delayMs: 240,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: wide ? 560 : 720),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(phone ? 14 : 18),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: _kSky.withOpacity(0.22)),
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: FilledButton(
                                          style: FilledButton.styleFrom(
                                            backgroundColor: _kSky,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(vertical: phone ? 14 : 16),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                            shadowColor: _kSky.withOpacity(0.35),
                                            elevation: 2,
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
                                            side: BorderSide(color: _kSkyDeep.withOpacity(0.35)),
                                            foregroundColor: _kSkyDeep,
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
                          'Всегда можно вернуться к прологу в настройках.',
                          textAlign: TextAlign.center,
                          style: tt.bodySmall?.copyWith(color: _kInk.withOpacity(0.55)),
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

/// Плашка для логотипа с тем же градиентом, что и фон экрана,
/// чтобы логотип визуально «не выделялся» даже если у ассета есть белая подложка.
class _LogoPlate extends StatelessWidget {
  final String assetPath;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const _LogoPlate({
    required this.assetPath,
    required this.height,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // лёгкая тень для объёма, почти незаметная
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kOffWhite, _kCloud],
        ),
        border: Border.all(color: _kSky.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: _kSkyDeep.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 6),
        child: Image.asset(
          assetPath,
          height: height,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
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

/// Мягкие «облака» в фирменной палитре
class _CloudyPainter extends CustomPainter {
  final double t; // 0..1
  _CloudyPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;

    // База — off-white -> облачный голубой
    final base = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_kOffWhite, _kCloud],
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

    // Мягкие голубые пятна – «облака»
    blob(_kSky,     Offset(w * (0.25 + 0.05 * sx(0.0, 1)), h * (0.32 + 0.04 * cx(0.3, 1))), w * 0.70, 0.35);
    blob(_kSkyDeep, Offset(w * (0.75 + 0.05 * sx(0.2, 1)), h * (0.45 + 0.04 * cx(0.5, 1))), w * 0.65, 0.25);
    blob(_kSky,     Offset(w * (0.50 + 0.07 * sx(0.4, 1)), h * (0.78 + 0.05 * cx(0.1, 1))), w * 0.80, 0.20);
  }

  @override
  bool shouldRepaint(covariant _CloudyPainter old) => old.t != t;
}

/// Едва заметные «пылинки»
class _DustPainter extends CustomPainter {
  final int count;
  final double t; // 0..1
  _DustPainter({required this.count, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(42);
    for (int i = 0; i < count; i++) {
      final bx = rnd.nextDouble() * size.width;
      final by = rnd.nextDouble() * size.height;

      final dx = bx + sin((i * 0.37 + t * 6.28)) * 4;
      final dy = by + cos((i * 0.53 + t * 6.28)) * 4;

      final tw = (sin((i * 0.23) + t * 12.0) + 1) / 2;
      final radius = (i % 7 == 0) ? 1.5 : 1.0;
      final paint = Paint()..color = _kSkyDeep.withOpacity(0.10 + 0.20 * tw);

      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DustPainter old) => old.t != t || old.count != count;
}
