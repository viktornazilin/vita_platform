import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/login_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginModel(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _obscure = true;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;
      if (event == AuthChangeEvent.signedIn && session != null && mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Введите email';
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
    if (!ok) return 'Некорректный email';
    return null;
  }

  String? _validatePass(String? v) {
    final s = v ?? '';
    if (s.isEmpty) return 'Введите пароль';
    if (s.length < 6) return 'Минимум 6 символов';
    return null;
  }

  Future<void> _login() async {
    final model = context.read<LoginModel>();
    if (!_formKey.currentState!.validate()) return;

    final success = await model.login(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } else if (model.errorText != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(model.errorText!)),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    final model = context.read<LoginModel>();
    await model.loginWithGoogle();
    // переход произойдёт в onAuthStateChange
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<LoginModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final isWide = w >= 900;
        final cardMaxW = isWide ? 520.0 : 460.0;
        final sidePad = w < 480 ? 12.0 : 24.0;

        final formCard = _AuthCard(
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Лого
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Image.asset('assets/images/logo.png', height: 36),
                  ]),
                  const SizedBox(height: 16),
                  Text(
                    'Войдите в аккаунт',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 18),

                  // Email
                  TextFormField(
                    controller: _emailCtrl,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: _validateEmail,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.alternate_email),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      filled: true,
                    ),
                    onFieldSubmitted: (_) => _passFocus.requestFocus(),
                  ),
                  const SizedBox(height: 12),

                  // Пароль
                  TextFormField(
                    controller: _passCtrl,
                    focusNode: _passFocus,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    validator: _validatePass,
                    onFieldSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                        tooltip: _obscure ? 'Показать пароль' : 'Скрыть пароль',
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      filled: true,
                    ),
                  ),

                  if (model.errorText != null) ...[
                    const SizedBox(height: 10),
                    Text(model.errorText!, style: TextStyle(color: cs.error)),
                  ],

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          // TODO: восстановление пароля
                        },
                        child: const Text('Забыли пароль?'),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/register'),
                        child: const Text('Создать аккаунт'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Кнопка входа
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: model.isLoading
                          ? const Padding(
                              key: ValueKey('loader'),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : FilledButton.icon(
                              key: const ValueKey('loginbtn'),
                              onPressed: _login,
                              icon: const Icon(Icons.login),
                              label: const Text('Войти'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Row(children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('или', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                    ),
                    const Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 12),

                  // Вход через Google
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: model.isLoading ? null : _loginWithGoogle,
                      icon: const Icon(Icons.g_mobiledata),
                      label: const Text('Продолжить с Google'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // ===== Компоновки =====
        if (!isWide) {
          // Мобильный: фоновый градиент + скролл, чтобы не ломаться при клавиатуре
          return Scaffold(
            body: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primaryContainer.withOpacity(0.35),
                    cs.tertiaryContainer.withOpacity(0.35),
                  ],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(sidePad),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: cardMaxW),
                      child: formCard,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // Десктоп/ноутбук: двухколоночная сетка
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // фоновая «дымка»
              IgnorePointer(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(color: Colors.transparent),
                ),
              ),
              Row(
                children: [
                  // Левая колонка-иллюстрация/преимущества
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cs.primaryContainer.withOpacity(0.35),
                            cs.tertiaryContainer.withOpacity(0.35),
                          ],
                        ),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: _HeroPanel(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Правая колонка — форма
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: cardMaxW),
                        child: Padding(
                          padding: EdgeInsets.all(sidePad),
                          child: formCard,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Левая панель для широких экранов: заголовок и плюсы продукта
class _HeroPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Image.asset('assets/images/logo.png', height: 40),
          const SizedBox(width: 10),
          Text('VitaPlatform', style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 16),
        Text(
          'Управляй ресурсами как герой.\nЦели, настроение, финансы — в одном месте.',
          style: tt.titleMedium?.copyWith(color: cs.onSurface.withOpacity(0.8), height: 1.35),
        ),
        const SizedBox(height: 24),
        _Bullet(icon: Icons.flag, text: 'Планирование по дням и блокам жизни'),
        _Bullet(icon: Icons.mood, text: 'Трекер состояния и фокус-времени'),
        _Bullet(icon: Icons.account_balance_wallet, text: 'Доходы/расходы и копилки'),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Bullet({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

/// Карточка с «стеклянным» эффектом и аккуратной обводкой
class _AuthCard extends StatelessWidget {
  final Widget child;
  const _AuthCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(0.90),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: child,
          ),
        ),
      ),
    );
  }
}
