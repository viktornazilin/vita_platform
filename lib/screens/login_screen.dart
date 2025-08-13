import 'dart:async';
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
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    // Навигация после успешного Google OAuth (и вообще любого входа)
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
    super.dispose();
  }

  Future<void> _login() async {
    final model = context.read<LoginModel>();
    final success = await model.login(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );
    if (success && mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  Future<void> _loginWithGoogle() async {
    await context.read<LoginModel>().loginWithGoogle();
    // переход произойдет в слушателе onAuthStateChange
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<LoginModel>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Image.asset('assets/images/logo.png', height: 32),
                      const SizedBox(width: 10),
                    ]),
                    const SizedBox(height: 18),
                    Text('Войдите в аккаунт', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 18),

                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.alternate_email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                        ),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Пароль',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
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

                    // Кнопка входа по email/паролю
                    SizedBox(
                      width: double.infinity,
                      child: model.isLoading
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
                    Row(children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('или'),
                      ),
                      Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: 12),

                    // Кнопка входа через Google
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: model.isLoading ? null : _loginWithGoogle,
                        icon: const Icon(Icons.g_mobiledata), // можно заменить на SVG-иконку Google
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
    );
  }
}
