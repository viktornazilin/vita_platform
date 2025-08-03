import 'package:flutter/material.dart';
import '../models/life_block.dart';
import '../services/user_service.dart';

class OnboardingQuestionnaireScreen extends StatefulWidget {
  const OnboardingQuestionnaireScreen({super.key});

  @override
  State<OnboardingQuestionnaireScreen> createState() =>
      _OnboardingQuestionnaireScreenState();
}

class _OnboardingQuestionnaireScreenState
    extends State<OnboardingQuestionnaireScreen> {
  final Set<LifeBlock> _selectedBlocks = {};
  final UserService _userService = UserService();

  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _healthController = TextEditingController();
  final TextEditingController _goalsController = TextEditingController();
  final TextEditingController _dreamsController = TextEditingController();
  final TextEditingController _strengthsController = TextEditingController();
  final TextEditingController _weaknessesController = TextEditingController();
  final List<String> _selectedPriorities = [];

  final List<String> _prioritiesOptions = [
    'Здоровье',
    'Карьера',
    'Деньги',
    'Семья',
    'Развитие',
    'Любовь',
    'Творчество',
    'Баланс',
  ];

  void _toggleBlock(LifeBlock block) {
    setState(() {
      _selectedBlocks.contains(block)
          ? _selectedBlocks.remove(block)
          : _selectedBlocks.add(block);
    });
  }

  void _togglePriority(String priority) {
    setState(() {
      _selectedPriorities.contains(priority)
          ? _selectedPriorities.remove(priority)
          : _selectedPriorities.add(priority);
    });
  }

  void _submit() {
    // Пример сохранения данных пользователя через UserService
    final user = _userService.currentUser;
    if (user != null) {
      user.age = int.tryParse(_ageController.text);
      user.health = _healthController.text;
      user.goals = _goalsController.text;
      user.dreams = _dreamsController.text;
      user.strengths = _strengthsController.text;
      user.weaknesses = _weaknessesController.text;
      user.priorities = _selectedPriorities;
      user.lifeBlocks = _selectedBlocks.toList();

      _userService.saveUser(user);
      _userService.markQuestionnaireComplete();
    }

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _ageController.dispose();
    _healthController.dispose();
    _goalsController.dispose();
    _dreamsController.dispose();
    _strengthsController.dispose();
    _weaknessesController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добро пожаловать')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Какие сферы жизни вы хотите отслеживать?'),
            ...LifeBlock.values.map((block) {
              final selected = _selectedBlocks.contains(block);
              return CheckboxListTile(
                value: selected,
                title: Text(getBlockLabel(block)),
                onChanged: (_) => _toggleBlock(block),
              );
            }),

            _buildSectionTitle('2. Возраст'),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ваш возраст',
              ),
            ),

            _buildSectionTitle('3. Есть ли у вас проблемы со здоровьем?'),
            TextField(
              controller: _healthController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Опишите кратко',
              ),
            ),

            _buildSectionTitle('4. Какие у вас цели на ближайшие 5 лет?'),
            TextField(
              controller: _goalsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Жизненные цели',
              ),
            ),

            _buildSectionTitle('5. О чём вы мечтаете?'),
            TextField(
              controller: _dreamsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Мечты',
              ),
            ),

            _buildSectionTitle('6. Что для вас сейчас важнее всего?'),
            Wrap(
              spacing: 8,
              children: _prioritiesOptions.map((priority) {
                final selected = _selectedPriorities.contains(priority);
                return FilterChip(
                  label: Text(priority),
                  selected: selected,
                  onSelected: (_) => _togglePriority(priority),
                );
              }).toList(),
            ),

            _buildSectionTitle('7. Ваши сильные стороны'),
            TextField(
              controller: _strengthsController,
              decoration: const InputDecoration(
                labelText: 'Например: целеустремлённость, эмпатия',
              ),
            ),

            _buildSectionTitle('8. Ваши слабые стороны'),
            TextField(
              controller: _weaknessesController,
              decoration: const InputDecoration(
                labelText: 'Например: прокрастинация, тревожность',
              ),
            ),

            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Завершить опрос'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
