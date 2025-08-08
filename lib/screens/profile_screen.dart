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
    if (value == null || (value is String && value.trim().isEmpty)) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(label),
        subtitle: value is List
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: value.map((v) => Text('- $v')).toList(),
              )
            : Text(value.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 28),
            const SizedBox(width: 10),
            const Text('My Profile'),
          ],
        ),
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Аватар + XP
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 40,
                              child: Icon(Icons.person, size: 40),
                            ),
                            const SizedBox(height: 16),
                            _xp != null
                                ? XPProgressBar(xp: _xp!)
                                : const Text(
                                    'XP data not available',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Результаты опроса
                    Text(
                      'Результаты опросника',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),

                    if (_questionnaire == null ||
                        _questionnaire!['has_completed_questionnaire'] != true)
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Вы ещё не прошли опросник.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
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

                    const SizedBox(height: 20),
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
