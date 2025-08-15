import 'package:flutter/material.dart';
import '../services/user_service.dart';

class EpicIntroScreen extends StatelessWidget {
  final UserService userService;
  const EpicIntroScreen({super.key, required this.userService});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // animated gradient background (простая анимация через ShaderMask/свечение)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // легкие «частицы»
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.15,
                child: _ParticlesOverlay(),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Text(
                    'VitaPlatform',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Каждый день ты расходуешь свои ресурсы.\nПора управлять ими как герой.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 18,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: size.width,
                    child: FilledButton(
                      onPressed: () async {
                        await userService.markEpicIntroSeen(); // NEW
                        // идём к выбору архетипа
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pushReplacementNamed('/archetype');
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Начать мой путь', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () async {
                      await userService.markEpicIntroSeen(); // всё равно отмечаем
                      // Пропустить к архетипу
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pushReplacementNamed('/archetype');
                    },
                    child: const Text('Пропустить пролог'),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticlesOverlay extends StatelessWidget {
  const _ParticlesOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlesPainter(),
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.25);
    // простое «звёздное» рассеивание
    for (int i = 0; i < 120; i++) {
      final dx = (size.width) * (i * 37 % 100) / 100.0;
      final dy = (size.height) * (i * 53 % 100) / 100.0;
      canvas.drawCircle(Offset(dx, dy), (i % 3 == 0) ? 1.6 : 1.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
