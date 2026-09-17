import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AccessDecision {
  grantedGrandfathered,
  grantedSubscribed,
  requiresPaywall,
}

/// Решает, пускать ли пользователя в приложение, или показать пейволл.
///
/// Два независимых пути к доступу:
/// 1. `is_grandfathered = true` в таблице users — старые пользователи,
///    зарегистрированные до введения платной подписки, бесплатны навсегда.
///    RevenueCat в этом случае вообще не трогаем.
/// 2. Активный entitlement 'premium' в RevenueCat (покупка ИЛИ ещё идущий
///    30-дневный триал — RevenueCat считает оба состояния "активными",
///    отдельно считать дни триала самим не нужно).
class AccessGate {
  // Имя entitlement в RevenueCat — должно точно совпадать с тем, что
  // создано в дашборде (Product catalog → Entitlements). У нас там уже
  // создан 'ladna_pro' — используем именно его, а не общее 'premium'.
  static const String entitlementId = 'ladna_pro';

  static Future<AccessDecision> resolve() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    if (uid == null) {
      // Не должно случиться — сюда попадаем только когда пользователь уже
      // залогинен, но на всякий случай не пускаем без проверки.
      return AccessDecision.requiresPaywall;
    }

    // 1) Старые пользователи — бесплатно навсегда.
    try {
      final row = await client
          .from('users')
          .select('is_grandfathered')
          .eq('id', uid)
          .maybeSingle();
      if (row != null && row['is_grandfathered'] == true) {
        return AccessDecision.grantedGrandfathered;
      }
    } catch (_) {
      // Не удалось проверить флаг из-за сети — не блокируем человека молча
      // по этой причине, просто идём дальше к проверке подписки ниже (не
      // менее строгий путь, не откроет доступ по ошибке).
    }

    // 2) Привязываем RevenueCat к текущему Supabase-пользователю — важно
    // для восстановления покупок на другом устройстве и чтобы вебхук от
    // RevenueCat потом мог сопоставить подписку с нужным аккаунтом.
    try {
      await Purchases.logIn(uid);
    } catch (_) {
      // logIn редко падает; если упал — всё равно попробуем прочитать
      // CustomerInfo ниже (SDK мог быть залогинен ещё с прошлого раза).
    }

    final active = await hasActiveEntitlement();
    return active ? AccessDecision.grantedSubscribed : AccessDecision.requiresPaywall;
  }

  static Future<bool> hasActiveEntitlement() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (_) {
      // Не удалось получить статус подписки (например, нет сети) — по
      // умолчанию НЕ открываем доступ. Это платный контент: сетевая ошибка
      // не должна превращаться в бесплатный проход.
      return false;
    }
  }
}
