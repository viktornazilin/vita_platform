import 'ladna_space.dart';

class SpaceInvite {
  final String id;
  final String spaceId;
  final String email;
  final String invitedBy;
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime? acceptedAt;

  final LadnaSpace? space;

  const SpaceInvite({
    required this.id,
    required this.spaceId,
    required this.email,
    required this.invitedBy,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.acceptedAt,
    this.space,
  });

  bool get isPending => status == 'pending';

  factory SpaceInvite.fromMap(Map<String, dynamic> map) {
    LadnaSpace? parsedSpace;

    final spaceMap = map['spaces'];
    if (spaceMap is Map<String, dynamic>) {
      parsedSpace = LadnaSpace.fromMap(spaceMap);
    }

    return SpaceInvite(
      id: map['id'] as String,
      spaceId: map['space_id'] as String,
      email: (map['email'] ?? '') as String,
      invitedBy: map['invited_by'] as String,
      role: (map['role'] ?? 'member') as String,
      status: (map['status'] ?? 'pending') as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      acceptedAt: map['accepted_at'] == null
          ? null
          : DateTime.parse(map['accepted_at'] as String),
      space: parsedSpace,
    );
  }
}
