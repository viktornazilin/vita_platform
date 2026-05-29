
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/home_trackers_repo.dart';

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

  Future<void> _copyBasket() async {
    final t = _ShoppingText.of(context);
    final basket = _items.where((e) => !e.isWishlist).toList();

    final text = [
      t.shoppingList,
      '',
      ...basket.map((e) {
        final buffer = StringBuffer('• ${e.title}');
        if (e.price > 0) buffer.write(' — ${e.price.toStringAsFixed(2)} €');
        if (e.storeName.trim().isNotEmpty) buffer.write(' · ${e.storeName}');
        return buffer.toString();
      }),
    ].join('\n');

    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.copied)),
    );
  }

  Future<void> _showItemSheet({
    ShoppingItemData? item,
    required bool isWishlist,
  }) async {
    final t = _ShoppingText.of(context);

    final titleCtrl = TextEditingController(text: item?.title ?? '');
    final descCtrl = TextEditingController(text: item?.description ?? '');
    final priceCtrl = TextEditingController(
      text: item != null && item.price > 0 ? item.price.toStringAsFixed(2) : '',
    );
    final storeCtrl = TextEditingController(text: item?.storeName ?? '');
    DateTime? dueDate = item?.dueDate;
    String? categoryId = item?.expenseCategoryId;

    final result = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final bottom = MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom;

            Future<void> pickDate() async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: ctx,
                initialDate: dueDate ?? now,
                firstDate: DateTime(now.year - 1),
                lastDate: DateTime(now.year + 5),
              );
              if (picked != null) setSheetState(() => dueDate = picked);
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(14, 0, 14, bottom + 14),
              child: _SheetCard(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _SheetHandle(),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item == null
                                  ? (isWishlist ? t.addWishlist : t.addShopping)
                                  : t.edit,
                              style: const TextStyle(
                                fontFamily: 'Playfair Display',
                                color: _LadnaColors.dark,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: titleCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(t.title),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(t.price),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: storeCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(t.store),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: _inputDecoration(t.note),
                      ),
                      const SizedBox(height: 10),
                      if (_categories.isNotEmpty)
                        DropdownButtonFormField<String?>(
                          value: categoryId,
                          decoration: _inputDecoration(t.category),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(t.noCategory),
                            ),
                            ..._categories.map(
                              (e) => DropdownMenuItem<String?>(
                                value: e.id,
                                child: Text(e.name),
                              ),
                            ),
                          ],
                          onChanged: (v) => setSheetState(() => categoryId = v),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: pickDate,
                              icon: const Icon(Icons.event_rounded),
                              label: Text(
                                dueDate == null ? t.dueDate : _formatDate(dueDate!),
                              ),
                            ),
                          ),
                          if (dueDate != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => setSheetState(() => dueDate = null),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: _LadnaColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () async {
                            final title = titleCtrl.text.trim();
                            if (title.isEmpty) return;

                            final price = double.tryParse(priceCtrl.text.trim().replaceAll(',', '.')) ?? 0;

                            if (item == null) {
                              await _repo.createShoppingItem(
                                title: title,
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
                                title: title,
                                description: descCtrl.text.trim(),
                                price: price,
                                storeName: storeCtrl.text.trim(),
                                dueDate: dueDate,
                                expenseCategoryId: categoryId,
                                isBought: item.isBought,
                                isWishlist: isWishlist,
                              );
                            }

                            if (ctx.mounted) Navigator.pop(ctx, true);
                          },
                          child: Text(item == null ? t.add : t.save),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    titleCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    storeCtrl.dispose();

    if (result == true) await _load();
  }

  Future<void> _deleteItem(ShoppingItemData item) async {
    final t = _ShoppingText.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(t.deleteItem),
        content: Text(item.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.delete),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _repo.deleteShoppingItem(item.id);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _ShoppingText.of(context);
    final basket = _items.where((e) => !e.isWishlist).toList();
    final wishlist = _items.where((e) => e.isWishlist).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(t.shoppingList),
        const SizedBox(height: 8),
        _ListCard(
          title: t.products,
          actionLabel: t.add,
          onAdd: () => _showItemSheet(isWishlist: false),
          trailing: IconButton(
            tooltip: t.copy,
            onPressed: basket.isEmpty ? null : _copyBasket,
            icon: const Icon(Icons.content_copy_rounded, size: 18),
          ),
          loading: _loading,
          emptyText: t.noShopping,
          items: basket,
          onToggle: (item, value) async {
            await _repo.toggleShoppingBought(id: item.id, isBought: value);
            await _load();
          },
          onEdit: (item) => _showItemSheet(item: item, isWishlist: false),
          onDelete: _deleteItem,
        ),
        const SizedBox(height: 16),
        _SectionLabel(t.wishlist),
        const SizedBox(height: 8),
        _ListCard(
          title: t.wantToBuy,
          actionLabel: t.add,
          onAdd: () => _showItemSheet(isWishlist: true),
          loading: _loading,
          emptyText: t.noWishlist,
          items: wishlist,
          onToggle: (item, value) async {
            await _repo.toggleShoppingBought(id: item.id, isBought: value);
            await _load();
          },
          onEdit: (item) => _showItemSheet(item: item, isWishlist: true),
          onDelete: _deleteItem,
        ),
      ],
    );
  }
}

class _ListCard extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAdd;
  final Widget? trailing;
  final bool loading;
  final String emptyText;
  final List<ShoppingItemData> items;
  final void Function(ShoppingItemData item, bool value) onToggle;
  final void Function(ShoppingItemData item) onEdit;
  final void Function(ShoppingItemData item) onDelete;

  const _ListCard({
    required this.title,
    required this.actionLabel,
    required this.onAdd,
    required this.loading,
    required this.emptyText,
    required this.items,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 8, 11),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: _LadnaColors.dark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
                TextButton(
                  onPressed: onAdd,
                  child: Text(actionLabel),
                ),
              ],
            ),
          ),
          const _SoftDivider(),
          if (loading)
            const SizedBox(
              height: 96,
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                emptyText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _LadnaColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            for (var i = 0; i < items.length; i++) ...[
              _ShoppingRow(
                item: items[i],
                onToggle: (value) => onToggle(items[i], value),
                onEdit: () => onEdit(items[i]),
                onDelete: () => onDelete(items[i]),
              ),
              if (i != items.length - 1) const _SoftDivider(),
            ],
        ],
      ),
    );
  }
}

class _ShoppingRow extends StatelessWidget {
  final ShoppingItemData item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ShoppingRow({
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bought = item.isBought;
    final meta = [
      if (item.storeName.trim().isNotEmpty) item.storeName.trim(),
      if (item.expenseCategoryName?.trim().isNotEmpty ?? false) item.expenseCategoryName!.trim(),
      if (item.price > 0) '${item.price.toStringAsFixed(2)} €',
      if (item.dueDate != null) _formatDate(item.dueDate!),
    ].join(' • ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 9, 8, 9),
      child: Row(
        children: [
          Checkbox(
            value: bought,
            activeColor: _LadnaColors.primary,
            shape: const CircleBorder(),
            onChanged: (v) => onToggle(v ?? false),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onEdit,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: bought ? _LadnaColors.muted : _LadnaColors.dark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      decoration: bought ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                  ),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _LadnaColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded, size: 18),
            color: _LadnaColors.muted,
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: _LadnaColors.muted,
          ),
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _LadnaColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _LadnaColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SheetCard extends StatelessWidget {
  final Widget child;

  const _SheetCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _LadnaColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _LadnaColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: _LadnaColors.dark.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: _LadnaColors.muted,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: _LadnaColors.border);
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: _LadnaColors.surfaceLight,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _LadnaColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _LadnaColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _LadnaColors.primary, width: 1.4),
    ),
  );
}

String _formatDate(DateTime date) {
  final dd = date.day.toString().padLeft(2, '0');
  final mm = date.month.toString().padLeft(2, '0');
  return '$dd.$mm.${date.year}';
}

class _LadnaColors {
  static const Color surface = Color(0xFFF5F3FA);
  static const Color surfaceLight = Color(0xFFFAFAFE);
  static const Color border = Color(0xFFE0DCF0);
  static const Color primary = Color(0xFF6B54C0);
  static const Color dark = Color(0xFF160E38);
  static const Color muted = Color(0xFF9090A8);
}

class _ShoppingText {
  final Locale locale;

  const _ShoppingText(this.locale);

  static _ShoppingText of(BuildContext context) => _ShoppingText(Localizations.localeOf(context));

  bool get _ru => locale.languageCode == 'ru';
  bool get _de => locale.languageCode == 'de';
  bool get _fr => locale.languageCode == 'fr';
  bool get _es => locale.languageCode == 'es';
  bool get _tr => locale.languageCode == 'tr';

  String get shoppingList => _ru ? 'Список покупок' : _de ? 'Einkaufsliste' : _fr ? 'Liste de courses' : _es ? 'Lista de compras' : _tr ? 'Alışveriş listesi' : 'Shopping list';
  String get products => _ru ? 'Продукты' : _de ? 'Produkte' : _fr ? 'Produits' : _es ? 'Productos' : _tr ? 'Ürünler' : 'Products';
  String get wishlist => _ru ? 'Вишлист' : _de ? 'Wunschliste' : _fr ? 'Wishlist' : _es ? 'Wishlist' : _tr ? 'İstek listesi' : 'Wishlist';
  String get wantToBuy => _ru ? 'Хочу купить' : _de ? 'Möchte kaufen' : _fr ? 'À acheter' : _es ? 'Quiero comprar' : _tr ? 'Satın almak istiyorum' : 'Want to buy';
  String get add => _ru ? '+ Добавить' : _de ? '+ Hinzufügen' : _fr ? '+ Ajouter' : _es ? '+ Añadir' : _tr ? '+ Ekle' : '+ Add';
  String get addShopping => _ru ? 'Добавить покупку' : _de ? 'Einkauf hinzufügen' : _fr ? 'Ajouter un achat' : _es ? 'Añadir compra' : _tr ? 'Alışveriş ekle' : 'Add item';
  String get addWishlist => _ru ? 'Добавить в вишлист' : _de ? 'Zur Wunschliste hinzufügen' : _fr ? 'Ajouter à la wishlist' : _es ? 'Añadir a wishlist' : _tr ? 'İstek listesine ekle' : 'Add to wishlist';
  String get edit => _ru ? 'Редактировать' : _de ? 'Bearbeiten' : _fr ? 'Modifier' : _es ? 'Editar' : _tr ? 'Düzenle' : 'Edit';
  String get save => _ru ? 'Сохранить' : _de ? 'Speichern' : _fr ? 'Enregistrer' : _es ? 'Guardar' : _tr ? 'Kaydet' : 'Save';
  String get title => _ru ? 'Название' : _de ? 'Name' : _fr ? 'Nom' : _es ? 'Nombre' : _tr ? 'Başlık' : 'Title';
  String get price => _ru ? 'Цена' : _de ? 'Preis' : _fr ? 'Prix' : _es ? 'Precio' : _tr ? 'Fiyat' : 'Price';
  String get store => _ru ? 'Магазин' : _de ? 'Geschäft' : _fr ? 'Magasin' : _es ? 'Tienda' : _tr ? 'Mağaza' : 'Store';
  String get note => _ru ? 'Заметка' : _de ? 'Notiz' : _fr ? 'Note' : _es ? 'Nota' : _tr ? 'Not' : 'Note';
  String get category => _ru ? 'Категория' : _de ? 'Kategorie' : _fr ? 'Catégorie' : _es ? 'Categoría' : _tr ? 'Kategori' : 'Category';
  String get noCategory => _ru ? 'Без категории' : _de ? 'Keine Kategorie' : _fr ? 'Sans catégorie' : _es ? 'Sin categoría' : _tr ? 'Kategorisiz' : 'No category';
  String get dueDate => _ru ? 'Дата' : _de ? 'Datum' : _fr ? 'Date' : _es ? 'Fecha' : _tr ? 'Tarih' : 'Date';
  String get copied => _ru ? 'Список скопирован' : _de ? 'Liste kopiert' : _fr ? 'Liste copiée' : _es ? 'Lista copiada' : _tr ? 'Liste kopyalandı' : 'List copied';
  String get copy => _ru ? 'Скопировать' : _de ? 'Kopieren' : _fr ? 'Copier' : _es ? 'Copiar' : _tr ? 'Kopyala' : 'Copy';
  String get noShopping => _ru ? 'Список покупок пуст' : _de ? 'Einkaufsliste ist leer' : _fr ? 'La liste est vide' : _es ? 'La lista está vacía' : _tr ? 'Liste boş' : 'Shopping list is empty';
  String get noWishlist => _ru ? 'Вишлист пуст' : _de ? 'Wunschliste ist leer' : _fr ? 'Wishlist vide' : _es ? 'Wishlist vacía' : _tr ? 'İstek listesi boş' : 'Wishlist is empty';
  String get deleteItem => _ru ? 'Удалить пункт?' : _de ? 'Eintrag löschen?' : _fr ? 'Supprimer l’élément ?' : _es ? '¿Eliminar elemento?' : _tr ? 'Öğe silinsin mi?' : 'Delete item?';
  String get delete => _ru ? 'Удалить' : _de ? 'Löschen' : _fr ? 'Supprimer' : _es ? 'Eliminar' : _tr ? 'Sil' : 'Delete';
  String get cancel => _ru ? 'Отмена' : _de ? 'Abbrechen' : _fr ? 'Annuler' : _es ? 'Cancelar' : _tr ? 'İptal' : 'Cancel';
}
