class Jar {
  final String id;
  final String title;
  final double? targetAmount;
  final double currentAmount;
  final double percentOfFree; // 0..100
  final bool active;

  Jar({
    required this.id,
    required this.title,
    required this.currentAmount,
    required this.percentOfFree,
    this.targetAmount,
    this.active = true,
  });

  Jar copyWith({double? currentAmount}) => Jar(
    id: id,
    title: title,
    targetAmount: targetAmount,
    currentAmount: currentAmount ?? this.currentAmount,
    percentOfFree: percentOfFree,
    active: active,
  );
}
