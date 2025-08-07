import 'package:flutter/material.dart';
import '../models/life_block.dart';
import '../services/user_service.dart';
import '../main.dart';

class OnboardingQuestionnaireScreen extends StatefulWidget {
  const OnboardingQuestionnaireScreen({super.key});

  @override
  State<OnboardingQuestionnaireScreen> createState() =>
      _OnboardingQuestionnaireScreenState();
}

class _OnboardingQuestionnaireScreenState
    extends State<OnboardingQuestionnaireScreen> {
  final Set<LifeBlock> _selectedBlocks = {};
  final _userService = UserService();

  final _ageController = TextEditingController();
  final _healthController = TextEditingController();
  final _goalsController = TextEditingController();
  final _dreamsController = TextEditingController();
  final _strengthsController = TextEditingController();
  final _weaknessesController = TextEditingController();
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

  bool _isLoading = false;
  String? _errorText;

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

  Future<void> _submit() async {
    final id = _userService.currentUser?['id'];
    if (id == null) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await _userService.updateUserDetails({
        'age': int.tryParse(_ageController.text),
        'health': _healthController.text,
        'goals': _goalsController.text,
        'dreams': _dreamsController.text,
        'strengths': _strengthsController.text,
        'weaknesses': _weaknessesController.text,
        'priorities': _selectedPriorities,
        'life_blocks': _selectedBlocks.map((e) => e.name).toList(),
        'has_completed_questionnaire': true,
      });

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _errorText = 'Ошибка при сохранении: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
    appBar: AppBar(
      backgroundColor: Colors.teal,
      elevation: 0,
      title: Row(
        children: [
          Image.asset('assets/images/logo.png', height: 32),
          const SizedBox(width: 10),
          const Text(
            'Welcome',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: '1. Какие сферы жизни вы хотите отслеживать?',
            child: Column(
              children: LifeBlock.values.map((block) {
                final selected = _selectedBlocks.contains(block);
                return CheckboxListTile(
                  value: selected,
                  title: Text(getBlockLabel(block)),
                  activeColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onChanged: (_) => _toggleBlock(block),
                );
              }).toList(),
            ),
          ),

          _buildSectionCard(
            title: '2. Возраст',
            child: TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ваш возраст',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          _buildSectionCard(
            title: '3. Есть ли у вас проблемы со здоровьем?',
            child: TextField(
              controller: _healthController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Опишите кратко',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          _buildSectionCard(
            title: '4. Какие у вас цели на ближайшие 5 лет?',
            child: TextField(
              controller: _goalsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Жизненные цели',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          _buildSectionCard(
            title: '5. О чём вы мечтаете?',
            child: TextField(
              controller: _dreamsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Мечты',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          _buildSectionCard(
            title: '6. Что для вас сейчас важнее всего?',
            child: Wrap(
              spacing: 8,
              children: _prioritiesOptions.map((priority) {
                final selected = _selectedPriorities.contains(priority);
                return FilterChip(
                  label: Text(priority),
                  selected: selected,
                  selectedColor: Colors.teal.withOpacity(0.2),
                  checkmarkColor: Colors.teal,
                  onSelected: (_) => _togglePriority(priority),
                );
              }).toList(),
            ),
          ),

          _buildSectionCard(
            title: '7. Ваши сильные стороны',
            child: TextField(
              controller: _strengthsController,
              decoration: const InputDecoration(
                labelText: 'Например: целеустремлённость, эмпатия',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          _buildSectionCard(
            title: '8. Ваши слабые стороны',
            child: TextField(
              controller: _weaknessesController,
              decoration: const InputDecoration(
                labelText: 'Например: прокрастинация, тревожность',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(height: 24),
          if (_errorText != null)
            Text(
              _errorText!,
              style: const TextStyle(color: Colors.red),
            ),
          const SizedBox(height: 12),
          Center(
            child: _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check),
                    label: const Text('Завершить опрос'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSectionCard({required String title, required Widget child}) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ),
  );
}
