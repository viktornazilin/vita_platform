import 'package:flutter/material.dart';
import '../main.dart';
import '../models/xp.dart';
import '../widgets/xp_progress_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  XP? _xp;
  Map<String, dynamic>? _questionnaire;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final xpData = await dbRepo.getXP();
      final questionnaire = await dbRepo.getQuestionnaireResults();
      if (!mounted) return;
      setState(() {
        _xp = xpData;
        _questionnaire = questionnaire;
      });
    } catch (e) {
      _showError('Ошибка загрузки: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildField(String label, dynamic value) {
    if (value == null) return const SizedBox.shrink();

    // Пустая строка?
    if (value is String && value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    // Список значений?
    if (value is List) {
      final list = value.cast<dynamic>();
      if (list.isEmpty) return const SizedBox.shrink();
      return Card(
        child: ListTile(
          title: Text(label),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list.map((v) => Text('- $v')).toList(),
          ),
        ),
      );
    }

    // Обычное значение
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: Text(value.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.person, size: 40),
                    ),
                    const SizedBox(height: 16),

                    if (_xp != null)
                      XPProgressBar(xp: _xp!)
                    else
                      const Text(
                        'XP data not available',
                        style: TextStyle(color: Colors.grey),
                      ),

                    const SizedBox(height: 24),
                    const Text(
                      'Результаты опросника',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),

                    if (_questionnaire == null ||
                        _questionnaire!['has_completed_questionnaire'] != true)
                      const Text(
                        'Вы ещё не прошли опросник.',
                        style: TextStyle(color: Colors.grey),
                      )
                    else ...[
                      _buildField('Возраст', _questionnaire!['age']),
                      _buildField('Здоровье', _questionnaire!['health']),
                      _buildField('Цели', _questionnaire!['goals']),
                      _buildField('Мечты', _questionnaire!['dreams']),
                      _buildField('Сильные стороны', _questionnaire!['strengths']),
                      _buildField('Слабые стороны', _questionnaire!['weaknesses']),
                      _buildField('Приоритеты', _questionnaire!['priorities']),
                      _buildField('Сферы жизни', _questionnaire!['life_blocks']),
                    ],

                    const SizedBox(height: 16),
                    // Доп. кнопка до настроек (на всякий случай)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.settings),
                      label: const Text('Открыть настройки'),
                      onPressed: () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
