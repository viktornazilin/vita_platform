class SpaceMember {
  final String id;
  final String spaceId;
  final String userId;
  final String role;
  final String status;
  final String? invitedBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  final String? email;
  final String? name;

  const SpaceMember({
    required this.id,
    required this.spaceId,
    required this.userId,
    required this.role,
    required this.status,
    required this.invitedBy,
    required this.createdAt,
    required this.updatedAt,
    this.email,
    this.name,
  });

  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'owner' || role == 'admin';
  bool get isActive => status == 'active';

  factory SpaceMember.fromMap(Map<String, dynamic> map) {
    final userMap = map['users'];
    final profileMap = map['profiles'];

    String? extractedEmail;
    String? extractedName;

    if (userMap is Map<String, dynamic>) {
      extractedEmail = userMap['email'] as String?;
      extractedName = userMap['name'] as String?;
    }

    if (profileMap is Map<String, dynamic>) {
      extractedEmail ??= profileMap['email'] as String?;
      extractedName ??= profileMap['name'] as String?;
    }

    return SpaceMember(
      id: map['id'] as String,
      spaceId: map['space_id'] as String,
      userId: map['user_id'] as String,
      role: (map['role'] ?? 'member') as String,
      status: (map['status'] ?? 'active') as String,
      invitedBy: map['invited_by'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.parse(map['updated_at'] as String),
      email: extractedEmail,
      name: extractedName,
    );
  }
}
