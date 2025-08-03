import 'package:flutter/material.dart';
import '../services/user_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _userService = UserService();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  Future<void> _register() async {
    await _userService.register(_nameCtrl.text, _emailCtrl.text, _passCtrl.text);
    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _register, child: const Text('Register'))
          ],
        ),
      ),
    );
  }
}
