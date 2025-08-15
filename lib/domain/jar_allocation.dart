class JarAllocation {
  final String jarId;
  final double amount;

  JarAllocation({required this.jarId, required this.amount});

  factory JarAllocation.fromMap(Map<String, dynamic> map) {
    return JarAllocation(
      jarId: map['jar_id'] as String,
      amount: (map['amount'] as num).toDouble(),
    );
  }
}
