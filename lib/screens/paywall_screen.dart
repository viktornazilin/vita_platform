import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nest_app/l10n/app_localizations.dart';

import 'home/home_screen.dart';
import '../services/access_gate.dart';

/// Обязательный экран подписки — показывается вместо HomeScreen, если у
/// пользователя нет активного entitlement и он не grandfathered (см.
/// AccessGate). Не закрывается сам по себе: выйти можно только оформив
/// подписку/восстановив покупку, либо разлогинившись.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Открываем шторку RevenueCat сразу при показе экрана — не нужно ждать
    // лишнего тапа, пользователь и так уже понимает, зачем он здесь.
    WidgetsBinding.instance.addPostFrameCallback((_) => _openPaywall());
  }

  Future<void> _openPaywall() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      // Готовая шторка RevenueCat: сама показывает цену, условия триала и
      // текст автопродления так, как требует Apple — вручную это писать не
      // нужно. Требует настроенный Offering с привязанным Paywall-дизайном
      // в дашборде RevenueCat.
      final result = await RevenueCatUI.presentPaywall();
      if (result == PaywallResult.purchased || result == PaywallResult.restored) {
        await _recheckAndEnter();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await Purchases.restorePurchases();
    } catch (_) {
      // Если восстанавливать нечего — тихо игнорируем, _recheckAndEnter
      // ниже всё равно корректно определит итоговый статус.
    }
    await _recheckAndEnter();
  }

  Future<void> _recheckAndEnter() async {
    final active = await AccessGate.hasActiveEntitlement();
    if (!mounted) return;
    setState(() => _busy = false);
    if (active) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _logout() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await Supabase.instance.client.auth.signOut();
    } finally {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _busy
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium_rounded, size: 56),
                      const SizedBox(height: 16),
                      Text(
                        l.paywallTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.paywallSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _openPaywall,
                        child: Text(l.paywallOpenButton),
                      ),
                      const SizedBox(height: 8),
                      // Обязательная кнопка по требованию Apple — без неё
                      // гарантированный реджект при ревью.
                      TextButton(
                        onPressed: _restore,
                        child: Text(l.paywallRestoreButton),
                      ),
                      TextButton(
                        onPressed: _logout,
                        child: Text(l.paywallLogoutButton),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
