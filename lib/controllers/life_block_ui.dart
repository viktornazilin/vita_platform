import 'package:flutter/material.dart';

class LifeBlockUI {
  final String label;
  final IconData icon;
  final Color accent; // основной цвет категории

  const LifeBlockUI({
    required this.label,
    required this.icon,
    required this.accent,
  });
}

/// Нормализуем код (чтобы "Health", " health ", null и т.д. не ломали UI)
String normalizeLifeBlock(String? raw) {
  final v = (raw ?? '').trim().toLowerCase();
  if (v.isEmpty) return 'general';
  return v;
}

LifeBlockUI lifeBlockUI(String? raw) {
  final key = normalizeLifeBlock(raw);

  switch (key) {
    case 'health':
      return const LifeBlockUI(
        label: 'Здоровье',
        icon: Icons.favorite_rounded,
        accent: Color(0xFF2FBF9B),
      );
    case 'career':
      return const LifeBlockUI(
        label: 'Карьера',
        icon: Icons.work_rounded,
        accent: Color(0xFF3AA8E6),
      );
    case 'family':
      return const LifeBlockUI(
        label: 'Семья',
        icon: Icons.home_rounded,
        accent: Color(0xFF6C8CFF),
      );
    case 'finance':
      return const LifeBlockUI(
        label: 'Финансы',
        icon: Icons.account_balance_wallet_rounded,
        accent: Color(0xFF7B61FF),
      );
    case 'relationships':
      return const LifeBlockUI(
        label: 'Отношения',
        icon: Icons.favorite_border_rounded,
        accent: Color(0xFFFF6B9A),
      );
    default:
      return const LifeBlockUI(
        label: 'Общее',
        icon: Icons.auto_awesome_rounded,
        accent: Color(0xFF6C8CFF),
      );
  }
}
