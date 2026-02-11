import 'dart:ui';
import 'package:flutter/material.dart';

class NewJarData {
  final String title;
  final double? target;
  final double percent;
  const NewJarData(this.title, this.target, this.percent);
}

class AddJarDialog extends StatefulWidget {
  const AddJarDialog({super.key});

  @override
  State<AddJarDialog> createState() => _AddJarDialogState();
}

class _AddJarDialogState extends State<AddJarDialog> {
  final _title = TextEditingController();
  final _target = TextEditingController();
  final _percent = TextEditingController(text: '0');
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _target.dispose();
    _percent.dispose();
    super.dispose();
  }

  double? _parseDouble(String s) {
    if (s.trim().isEmpty) return null;
    return double.tryParse(s.replaceAll(',', '.'));
  }

  void _submit() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Укажите название');
      return;
    }

    final percent = _parseDouble(_percent.text) ?? 0;
    if (percent < 0 || percent > 100) {
      setState(() => _error = 'Процент должен быть от 0 до 100');
      return;
    }

    final target = _parseDouble(_target.text);
    if (target == null || target <= 0) {
      setState(() => _error = 'Укажите цель (положительное число)');
      return;
    }

    Navigator.pop(context, NewJarData(title, target, percent));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      backgroundColor: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: _NestDialogCard(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      const _IconBadge(icon: Icons.savings_rounded),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Новая копилка',
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF2E4B5A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Настрой сумму и долю от свободных денег',
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Закрыть',
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Fields
                  TextField(
                    controller: _title,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Название',
                      hintText: 'Например: Поездка, Подушка, Дом',
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _percent,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Процент от свободных, %',
                      hintText: '0 — если вручную пополняешь',
                      prefixIcon: Icon(Icons.percent_rounded),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _target,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      labelText: 'Целевая сумма',
                      hintText: 'Например: 5000',
                      helperText: 'Обязательно',
                      prefixIcon: Icon(Icons.account_balance_wallet_rounded),
                    ),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    _ErrorPill(text: _error!),
                  ],

                  const SizedBox(height: 14),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Отмена'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Создать'),
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Nest dialog card (локально, без внешних файлов)
// ============================================================================

class _NestDialogCard extends StatelessWidget {
  final Widget child;
  const _NestDialogCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.82),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFD6E6F5)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A2B5B7A),
                blurRadius: 26,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  const _IconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6E6F5)),
      ),
      child: Center(
        child: Icon(icon, size: 18, color: const Color(0xFF3AA8E6)),
      ),
    );
  }
}

class _ErrorPill extends StatelessWidget {
  final String text;
  const _ErrorPill({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.errorContainer.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.error.withOpacity(0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: cs.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: tt.bodySmall?.copyWith(
                color: cs.onErrorContainer,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
