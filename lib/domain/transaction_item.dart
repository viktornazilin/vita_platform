class TransactionItem {
  final String id;
  final DateTime ts;
  final String kind; // 'income' | 'expense'
  final String categoryId;
  final double amount;
  final String? note;

  TransactionItem({
    required this.id,
    required this.ts,
    required this.kind,
    required this.categoryId,
    required this.amount,
    this.note,
  });
}
