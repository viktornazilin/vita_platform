import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/life_block.dart';
import '../models/onboarding_questionnaire_model.dart';

class OnboardingQuestionnaireScreen extends StatelessWidget {
  const OnboardingQuestionnaireScreen({super.key});

  static const _prioritiesOptions = [
    'Здоровье', 'Карьера', 'Деньги', 'Семья',
    'Развитие', 'Любовь', 'Творчество', 'Баланс',
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingQuestionnaireModel(),
      child: const _OnboardingQuestionnaireView(),
    );
  }
}

class _OnboardingQuestionnaireView extends StatefulWidget {
  const _OnboardingQuestionnaireView();

  @override
  State<_OnboardingQuestionnaireView> createState() =>
      _OnboardingQuestionnaireViewState();
}

class _OnboardingQuestionnaireViewState
    extends State<_OnboardingQuestionnaireView> {
  final _ageController = TextEditingController();
  final _healthController = TextEditingController();
  final _goalsController = TextEditingController();
  final _dreamsController = TextEditingController();
  final _strengthsController = TextEditingController();
  final _weaknessesController = TextEditingController();

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

  Future<void> _submit(BuildContext context) async {
    final model = context.read<OnboardingQuestionnaireModel>();
    model.age = _ageController.text;
    model.health = _healthController.text;
    model.goals = _goalsController.text;
    model.dreams = _dreamsController.text;
    model.strengths = _strengthsController.text;
    model.weaknesses = _weaknessesController.text;

    final success = await model.submit();
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<OnboardingQuestionnaireModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 10),
            const Text('Welcome', style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white,
            )),
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
                  final selected = model.selectedBlocks.contains(block);
                  return CheckboxListTile(
                    value: selected,
                    title: Text(getBlockLabel(block)),
                    activeColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onChanged: (_) => model.toggleBlock(block),
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
                children: OnboardingQuestionnaireScreen._prioritiesOptions.map((priority) {
                  final selected = model.selectedPriorities.contains(priority);
                  return FilterChip(
                    label: Text(priority),
                    selected: selected,
                    selectedColor: Colors.teal.withOpacity(0.2),
                    checkmarkColor: Colors.teal,
                    onSelected: (_) => model.togglePriority(priority),
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
            if (model.errorText != null)
              Text(model.errorText!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            Center(
              child: model.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: () => _submit(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Завершить опрос'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 16,
            )),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
