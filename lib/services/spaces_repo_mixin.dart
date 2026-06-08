import '../models/ladna_space.dart';
import '../models/space_invite.dart';
import '../models/space_member.dart';

import 'core/base_repo.dart';

abstract class SpacesRepo {
  Future<List<LadnaSpace>> listSpaces();

  Future<String> createSpace({
    required String name,
    String? description,
    String icon,
    String? color,
    DateTime? validUntil,
  });

  Future<void> updateSpace({
    required String spaceId,
    required String name,
    String? description,
    String icon,
    String? color,
    DateTime? validUntil,
  });

  Future<void> deleteSpace(String spaceId);

  Future<void> leaveSpace(String spaceId);

  Future<List<SpaceMember>> listSpaceMembers(String spaceId);

  Future<void> inviteUserToSpace({
    required String spaceId,
    required String email,
    String role,
  });

  Future<List<SpaceInvite>> listIncomingSpaceInvites();

  Future<void> acceptSpaceInvite(String inviteId);

  Future<void> declineSpaceInvite(String inviteId);

  Future<void> removeSpaceMember({
    required String spaceId,
    required String userId,
  });
}

mixin SpacesRepoMixin on BaseRepo implements SpacesRepo {
  String _normText(String? value) => (value ?? '').trim();

  String? _normOrNull(String? value) {
    final normalized = _normText(value);
    return normalized.isEmpty ? null : normalized;
  }

  String _dateOnlyIso(DateTime value) {
    final d = DateTime(value.year, value.month, value.day);
    return d.toIso8601String().split('T').first;
  }

  String? _dateOnlyIsoOrNull(DateTime? value) {
    if (value == null) return null;
    return _dateOnlyIso(value);
  }

  String _normEmail(String value) => value.trim().toLowerCase();

  String get _currentEmail {
    final email = client.auth.currentUser?.email;
    if (email == null || email.trim().isEmpty) {
      throw Exception('Email пользователя недоступен');
    }
    return email.trim().toLowerCase();
  }

  @override
  Future<List<LadnaSpace>> listSpaces() async {
    final today = _dateOnlyIso(DateTime.now());
    final res = await client
        .from('spaces')
        .select()
        .or('valid_until.is.null,valid_until.gte.$today')
        .order('created_at', ascending: false);

    return (res as List).map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      return LadnaSpace.fromMap(map);
    }).where((space) => space.isActive).toList();
  }

  @override
  Future<String> createSpace({
    required String name,
    String? description,
    String icon = '🏠',
    String? color,
    DateTime? validUntil,
  }) async {
    final normalizedName = _normText(name);

    if (normalizedName.isEmpty) {
      throw Exception('Введите название пространства');
    }

    final normalizedIcon = _normText(icon).isEmpty ? '🏠' : _normText(icon);

    final inserted = await client
        .from('spaces')
        .insert({
          'name': normalizedName,
          'description': _normOrNull(description),
          'icon': normalizedIcon,
          'color': _normOrNull(color),
          'owner_id': uid,
          'valid_until': _dateOnlyIsoOrNull(validUntil),
        })
        .select('id')
        .single();

    return inserted['id'] as String;
  }

  @override
  Future<void> updateSpace({
    required String spaceId,
    required String name,
    String? description,
    String icon = '🏠',
    String? color,
    DateTime? validUntil,
  }) async {
    final normalizedName = _normText(name);

    if (normalizedName.isEmpty) {
      throw Exception('Введите название пространства');
    }

    final normalizedIcon = _normText(icon).isEmpty ? '🏠' : _normText(icon);

    await client.from('spaces').update({
      'name': normalizedName,
      'description': _normOrNull(description),
      'icon': normalizedIcon,
      'color': _normOrNull(color),
      'valid_until': _dateOnlyIsoOrNull(validUntil),
    }).eq('id', spaceId);
  }

  @override
  Future<void> deleteSpace(String spaceId) async {
    await client.from('spaces').delete().eq('id', spaceId);
  }

  @override
  Future<void> leaveSpace(String spaceId) async {
    await client
        .from('space_members')
        .delete()
        .eq('space_id', spaceId)
        .eq('user_id', uid);
  }

  @override
  Future<List<SpaceMember>> listSpaceMembers(String spaceId) async {
    final res = await client
        .from('space_members')
        .select()
        .eq('space_id', spaceId)
        .eq('status', 'active')
        .order('created_at', ascending: true);

    return (res as List).map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      return SpaceMember.fromMap(map);
    }).toList();
  }

  @override
  Future<void> inviteUserToSpace({
    required String spaceId,
    required String email,
    String role = 'member',
  }) async {
    final normalizedEmail = _normEmail(email);

    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw Exception('Введите корректный email');
    }

    if (!['admin', 'member', 'viewer'].contains(role)) {
      throw Exception('Некорректная роль участника');
    }

    final existing = await client
        .from('space_invites')
        .select('id')
        .eq('space_id', spaceId)
        .ilike('email', normalizedEmail)
        .eq('status', 'pending')
        .limit(1);

    if ((existing as List).isNotEmpty) {
      throw Exception('Приглашение для этого пользователя уже отправлено');
    }

    await client.from('space_invites').insert({
      'space_id': spaceId,
      'email': normalizedEmail,
      'invited_by': uid,
      'role': role,
      'status': 'pending',
    });
  }

  @override
  Future<List<SpaceInvite>> listIncomingSpaceInvites() async {
    final email = _currentEmail;

    final res = await client
        .from('space_invites')
        .select('*, spaces(*)')
        .ilike('email', email)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (res as List).map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      return SpaceInvite.fromMap(map);
    }).where((invite) => invite.space == null || invite.space!.isActive).toList();
  }

  @override
  Future<void> acceptSpaceInvite(String inviteId) async {
    final inviteRow = await client
        .from('space_invites')
        .select()
        .eq('id', inviteId)
        .single();

    final invite = SpaceInvite.fromMap(
      Map<String, dynamic>.from(inviteRow as Map),
    );

    await client.from('space_members').upsert({
      'space_id': invite.spaceId,
      'user_id': uid,
      'role': invite.role,
      'status': 'active',
      'invited_by': invite.invitedBy,
    }, onConflict: 'space_id,user_id');

    await client.from('space_invites').update({
      'status': 'accepted',
      'accepted_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', inviteId);
  }

  @override
  Future<void> declineSpaceInvite(String inviteId) async {
    await client
        .from('space_invites')
        .update({'status': 'declined'}).eq('id', inviteId);
  }

  @override
  Future<void> removeSpaceMember({
    required String spaceId,
    required String userId,
  }) async {
    await client
        .from('space_members')
        .delete()
        .eq('space_id', spaceId)
        .eq('user_id', userId);
  }
}
