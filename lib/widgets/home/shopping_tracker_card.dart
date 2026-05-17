
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nest_app/l10n/app_localizations.dart';

import '../../services/home_trackers_repo.dart';
import '../report_section_card.dart';

class ShoppingTrackerCard extends StatefulWidget {
  const ShoppingTrackerCard({super.key});

  @override
  State<ShoppingTrackerCard> createState() => _ShoppingTrackerCardState();
}

class _ShoppingTrackerCardState extends State<ShoppingTrackerCard> {
  final _repo = HomeTrackersRepo();
  bool _loading = true;
  List<ShoppingItemData> _items = const [];
  List<ExpenseCategoryLite> _categories = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _repo.listShoppingItems();
      final categories = await _repo.listExpenseCategories();
      if (!mounted) return;
      setState(() {
        _items = items;
        _categories = categories;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '$dd.$mm.${date.year}';
  }

  String _dueDateLabel(AppLocalizations l, DateTime date) {
    return l.shoppingDueDatePrefix(_formatDate(date));
  }

  Future<void> _copyBasket() async {
    final l = AppLocalizations.of(context)!;
    final basket = _items.where((e) => !e.isWishlist).toList();
    final text = [
      '${l.shoppingBasketCopyHeader}\n',
      ...basket.map((e) {
        final buffer = StringBuffer();
        buffer.writeln('• ${e.title}${e.price > 0 ? ' — ${e.price.toStringAsFixed(2)} €' : ''}');
        if (e.storeName.trim().isNotEmpty) {
          buffer.writeln('  🏬 ${e.storeName}');
        }
        if (e.dueDate != null) {
          buffer.writeln('  📅 ${_dueDateLabel(l, e.dueDate!)}');
        }
        return buffer.toString();
      }),
    ].join('\n');

    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.shoppingBasketCopied)),
    );
  }

  Future<void> _showItemSheet({ShoppingItemData? item, required bool isWishlist}) async {
    final titleCtrl = TextEditingController(text: item?.title ?? '');
    final descCtrl = TextEditingController(text: item?.description ?? '');
    final priceCtrl = TextEditingController(
      text: item == null || item.price == 0 ? '' : item.price.toStringAsFixed(2),
    );
    final storeCtrl = TextEditingController(text: item?.storeName ?? '');
    DateTime? dueDate = item?.dueDate;
    String? categoryId = item?.expenseCategoryId;
    bool isBought = item?.isBought ?? false;
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final l = AppLocalizations.of(ctx)!;
        return StatefulBuilder(
          builder: (ctx, setLocal) => Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item == null
                          ? (isWishlist ? l.shoppingNewWishlistItem : l.shoppingNewPurchase)
                          : l.shoppingEditItem,
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: titleCtrl,
                      decoration: InputDecoration(labelText: l.shoppingFieldTitle),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? l.shoppingEnterTitle : null,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descCtrl,
                      decoration: InputDecoration(labelText: l.shoppingFieldDescription),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l.shoppingFieldPrice),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: storeCtrl,
                      decoration: InputDecoration(labelText: l.shoppingFieldStore),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String?>(
                      value: categoryId,
                      decoration: InputDecoration(labelText: l.shoppingFieldExpenseCategory),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(l.shoppingNoCategory),
                        ),
                        ..._categories.map(
                          (c) => DropdownMenuItem<String?>(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        ),
                      ],
                      onChanged: (v) => setLocal(() => categoryId = v),
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      value: isBought,
                      onChanged: (v) => setLocal(() => isBought = v),
                      contentPadding: EdgeInsets.zero,
                      title: Text(l.shoppingAlreadyBought),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now().add(const Duration(days: 3650)),
                                initialDate: dueDate ?? DateTime.now(),
                              );
                              if (picked != null) {
                                setLocal(() => dueDate = picked);
                              }
                            },
                            icon: const Icon(Icons.event_rounded),
                            label: Text(
                              dueDate == null
                                  ? l.shoppingPurchaseDate
                                  : '${dueDate!.day.toString().padLeft(2, '0')}.${dueDate!.month.toString().padLeft(2, '0')}.${dueDate!.year}',
                            ),
                          ),
                          if (dueDate != null)
                            TextButton(
                              onPressed: () => setLocal(() => dueDate = null),
                              child: Text(l.shoppingReset),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          if (!(formKey.currentState?.validate() ?? false)) return;
                          final price = double.tryParse(
                                priceCtrl.text.trim().replaceAll(',', '.'),
                              ) ??
                              0;
                          if (item == null) {
                            await _repo.createShoppingItem(
                              title: titleCtrl.text.trim(),
                              description: descCtrl.text.trim(),
                              price: price,
                              storeName: storeCtrl.text.trim(),
                              dueDate: dueDate,
                              expenseCategoryId: categoryId,
                              isWishlist: isWishlist,
                            );
                          } else {
                            await _repo.updateShoppingItem(
                              id: item.id,
                              title: titleCtrl.text.trim(),
                              description: descCtrl.text.trim(),
                              price: price,
                              storeName: storeCtrl.text.trim(),
                              dueDate: dueDate,
                              expenseCategoryId: categoryId,
                              isBought: isBought,
                              isWishlist: isWishlist,
                            );
                          }
                          if (!mounted) return;
                          Navigator.pop(ctx);
                          await _load();
                        },
                        icon: const Icon(Icons.save_rounded),
                        label: Text(l.commonSave),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _listSection(String title, List<ShoppingItemData> items, bool isWishlist) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.45),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _showItemSheet(isWishlist: isWishlist),
                icon: const Icon(Icons.add_rounded),
                label: Text(l.commonAdd),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Text(
              l.shoppingEmpty,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          for (final item in items) ...[
            CheckboxListTile(
              value: item.isBought,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (v) async {
                await _repo.toggleShoppingBought(
                  id: item.id,
                  isBought: v ?? false,
                );
                await _load();
              },
              title: Text(
                item.title,
                style: item.isBought
                    ? tt.bodyLarge?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: cs.onSurfaceVariant,
                      )
                    : tt.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                [
                  if (item.storeName.trim().isNotEmpty) item.storeName,
                  if (item.expenseCategoryName?.trim().isNotEmpty ?? false)
                    item.expenseCategoryName!,
                  if (item.price > 0) '${item.price.toStringAsFixed(2)} €',
                  if (item.dueDate != null)
                    _dueDateLabel(l, item.dueDate!),
                ].join(' • '),
              ),
              secondary: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: l.commonEdit,
                    onPressed: () => _showItemSheet(item: item, isWishlist: isWishlist),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: l.commonDelete,
                    onPressed: () async {
                      await _repo.deleteShoppingItem(item.id);
                      await _load();
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final basket = _items.where((e) => !e.isWishlist).toList();
    final wishlist = _items.where((e) => e.isWishlist).toList();

    return ReportSectionCard(
      title: l.shoppingTrackerTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: l.shoppingCopyBasket,
              onPressed: basket.isEmpty ? null : _copyBasket,
              icon: const Icon(Icons.content_copy_rounded),
            ),
          ),
          if (_loading)
            const SizedBox(
              height: 96,
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else ...[
            _listSection(l.shoppingBasketTitle, basket, false),
            const SizedBox(height: 10),
            _listSection(l.shoppingWishlistTitle, wishlist, true),
          ],
        ],
      ),
    );
  }
}
