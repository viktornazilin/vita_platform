import 'dart:ui';

import 'package:flutter/material.dart';

class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  static const _ink = Color(0xFF6D55D8);
  static const _gold = Color(0xFFFFD166);
  static const _text = Color(0xFF17123A);
  static const _muted = Color(0xFF7E7898);
  static const _stroke = Color(0xFFE4DDF6);

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final base = color;

    return SizedBox(
      height: 76,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.78),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _stroke.withOpacity(0.95)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x16221846),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _IconBubble(
                      icon: icon,
                      color: base,
                      fallback: _ink,
                      accent: _gold,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.labelLarge?.copyWith(
                              fontSize: 13,
                              height: 1.05,
                              fontWeight: FontWeight.w900,
                              color: _text,
                              letterSpacing: -0.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: tt.bodySmall?.copyWith(
                              fontSize: 11,
                              height: 1.18,
                              fontWeight: FontWeight.w600,
                              color: _muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const _ChevronPill(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color fallback;
  final Color accent;

  const _IconBubble({
    required this.icon,
    required this.color,
    required this.fallback,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final base = color.opacity == 0 ? fallback : color;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            base.withOpacity(0.95),
            const Color(0xFF7A5CFF).withOpacity(0.82),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: base.withOpacity(0.20),
            blurRadius: 16,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: 7,
            top: 7,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.86),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Icon(icon, color: Colors.white, size: 19),
        ],
      ),
    );
  }
}

class _ChevronPill extends StatelessWidget {
  const _ChevronPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECFF),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFDCD2FF)),
      ),
      child: const Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: Color(0xFF6D55D8),
      ),
    );
  }
}
