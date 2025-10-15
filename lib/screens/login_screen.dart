import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  bool _busy = false; // локальная блокировка для reset/login

  @override
  void initState() {
    super.initState();

    // Навигация после входа и обработка ссылки из письма "reset password"
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      if (!mounted) return;

      if (data.event == AuthChangeEvent.passwordRecovery) {
        // Пользователь пришёл по письму "Reset password" → ведём на экран смены пароля
        Navigator.of(context).pushNamedAndRemoveUntil('/password-reset', (_) => false);
        return;
      }

      if (data.event == AuthChangeEvent.signedIn && data.session != null) {
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

  // ───────────── Helpers ─────────────

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
    if (_busy) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);
    final model = context.read<LoginModel>();

    final ok = await model.login(_emailCtrl.text.trim(), _passCtrl.text);

    if (!mounted) return;
    setState(() => _busy = false);

    if (ok) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } else if (model.errorText != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(model.errorText!)));
    }
  }

  Future<void> _loginWithGoogle() async {
    if (_busy) return;
    setState(() => _busy = true);
    await context.read<LoginModel>().loginWithGoogle();
    if (!mounted) return;
    setState(() => _busy = false);
    // дальнейший переход произойдёт в onAuthStateChange
  }

  /// Запуск восстановления: спрашиваем email, валидируем и шлём письмо через Supabase
  Future<void> _startPasswordReset() async {
    if (_busy) return;

    final emailController = TextEditingController(text: _emailCtrl.text.trim());
    final formKey = GlobalKey<FormState>();

    final email = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Восстановление пароля'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            validator: _validateEmail,
            decoration: const InputDecoration(
              labelText: 'Ваш email',
              border: OutlineInputBorder(),
            ),
            onFieldSubmitted: (_) {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, emailController.text.trim());
              }
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, emailController.text.trim());
              }
            },
            child: const Text('Отправить'),
          ),
        ],
      ),
    );

    if (email == null || email.isEmpty) return;

    setState(() => _busy = true);
    final client = Supabase.instance.client;

    // redirectTo:
    //  - Web: открываем хеш-маршрут /#/password-reset, чтобы приложение поймало состояние recovery
    //  - Mobile/desktop: deeplink (добавьте схему в Supabase → Authentication → URL Configuration)
    final String redirectTo = kIsWeb
        ? Uri.base.origin + '/#/password-reset'
        : 'vitaplatform://auth-callback';

    try {
      await client.auth.resetPasswordForEmail(email, redirectTo: redirectTo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Письмо для смены пароля отправлено. Проверьте почту.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось отправить письмо: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ───────────── UI ─────────────

  @override
  Widget build(BuildContext context) {
    final model = context.watch<LoginModel>();
    final isLoading = model.isLoading || _busy;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE9FFF8), Color(0xFFF7F9FF)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Image.asset('assets/images/logo.png', height: 32),
                        const SizedBox(width: 10),
                      ]),
                      const SizedBox(height: 18),
                      Text('Войдите в аккаунт',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 18),

                      // Email
                      TextFormField(
                        controller: _emailCtrl,
                        focusNode: _emailFocus,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: _validateEmail,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.alternate_email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
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
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
                          filled: true,
                        ),
                      ),

                      if (model.errorText != null) ...[
                        const SizedBox(height: 10),
                        Text(model.errorText!, style: const TextStyle(color: Colors.red)),
                      ],

                      const SizedBox(height: 14),
                      Row(
                        children: [
                          TextButton(
                            onPressed: isLoading ? null : _startPasswordReset,
                            child: const Text('Забыли пароль?'),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: isLoading ? null : () => Navigator.pushNamed(context, '/register'),
                            child: const Text('Создать аккаунт'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Email/Password login
                      SizedBox(
                        width: double.infinity,
                        child: isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : FilledButton.icon(
                                onPressed: _login,
                                icon: const Icon(Icons.login),
                                label: const Text('Войти'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                      ),

                      const SizedBox(height: 12),
                      Row(children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text('или',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(color: Colors.black54)),
                        ),
                        const Expanded(child: Divider()),
                      ]),
                      const SizedBox(height: 12),

                      // Google login
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: isLoading ? null : _loginWithGoogle,
                          icon: const Icon(Icons.g_mobiledata),
                          label: const Text('Продолжить с Google'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
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
