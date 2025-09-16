import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/register_model.dart';
import '../services/user_service.dart'; // <-- добавили

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    // После Google OAuth/любой авторизации решаем маршрут по флагам профиля
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;
      if (event == AuthChangeEvent.signedIn && session != null && mounted) {
        await _routeAfterAuth();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _routeAfterAuth() async {
    final userService = UserService();        // singleton
    await userService.refreshCurrentUser();   // подтянет профиль и СИНКНЕТ гостевой драфт
    if (!mounted) return;

    // 1) Эпичный пролог
    if (!userService.hasSeenEpicIntro) {
      Navigator.pushNamedAndRemoveUntil(context, '/intro', (_) => false);
      return;
    }

    // 2) Архетип
    final hasArchetype =
        (userService.selectedArchetype != null && userService.selectedArchetype!.isNotEmpty);
    if (!hasArchetype) {
      Navigator.pushNamedAndRemoveUntil(context, '/archetype', (_) => false);
      return;
    }

    // 3) Опросник
    if (userService.hasCompletedQuestionnaire) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (_) => false);
    }
  }

  Future<void> _onRegister() async {
    final model = context.read<RegisterModel>();
    final success = await model.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      confirmPassword: _confirmPasswordCtrl.text.trim(),
    );
    if (success && mounted) {
      await _routeAfterAuth(); // <-- вместо прямого '/onboarding'
    }
  }

  Future<void> _registerWithGoogle() async {
    await context.read<RegisterModel>().registerWithGoogle();
    // переход выполнит _routeAfterAuth() из onAuthStateChange
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterModel(),
      child: Consumer<RegisterModel>(
        builder: (context, model, _) {
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Image.asset('assets/images/logo.png', height: 28),
                  const SizedBox(width: 10),
                  const Text('Регистрация'),
                ],
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Имя'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordCtrl,
                        decoration: const InputDecoration(labelText: 'Пароль'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmPasswordCtrl,
                        decoration: const InputDecoration(labelText: 'Подтвердите пароль'),
                        obscureText: true,
                      ),
                      if (model.error != null) ...[
                        const SizedBox(height: 12),
                        Text(model.error!, style: const TextStyle(color: Colors.red)),
                      ],
                      const SizedBox(height: 20),

                      model.loading
                          ? const CircularProgressIndicator()
                          : FilledButton(
                              onPressed: _onRegister,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Зарегистрироваться'),
                            ),

                      const SizedBox(height: 16),
                      Row(children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('или'),
                        ),
                        Expanded(child: Divider()),
                      ]),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: model.loading ? null : _registerWithGoogle,
                          icon: const Icon(Icons.g_mobiledata),
                          label: const Text('Зарегистрироваться через Google'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
