// lib/services/home_trackers_repo.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/security/secure_crypto_service.dart';

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}

class ExpenseCategoryLite {
  final String id;
  final String name;

  const ExpenseCategoryLite({required this.id, required this.name});

  factory ExpenseCategoryLite.fromMap(Map<String, dynamic> map) {
    return ExpenseCategoryLite(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
    );
  }
}

class ShoppingItemData {
  final String id;
  final String title;
  final String description;
  final double price;
  final String storeName;
  final DateTime? dueDate;
  final String? expenseCategoryId;
  final String? expenseCategoryName;
  final bool isBought;
  final bool isWishlist;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ShoppingItemData({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.storeName,
    required this.dueDate,
    required this.expenseCategoryId,
    required this.expenseCategoryName,
    required this.isBought,
    required this.isWishlist,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShoppingItemData.fromMap(Map<String, dynamic> map) {
    final category = map['categories'];

    String? categoryName;
    if (category is Map) {
      categoryName = (category['name'] ?? '').toString();
    }

    return ShoppingItemData(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      storeName: (map['store_name'] ?? '').toString(),
      dueDate: _parseDateTime(map['due_date']),
      expenseCategoryId: map['expense_category_id']?.toString(),
      expenseCategoryName: categoryName == null || categoryName.trim().isEmpty
          ? null
          : categoryName.trim(),
      isBought: (map['is_bought'] as bool?) ?? false,
      isWishlist: (map['is_wishlist'] as bool?) ?? false,
      createdAt: _parseDateTime(map['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(map['updated_at']),
    );
  }
}

class HobbySummary {
  final String hobbyId;
  final String hobbyTitle;
  final int targetMinutesWeek;
  final int spentMinutesToday;
  final int spentMinutesWeek;

  const HobbySummary({
    required this.hobbyId,
    required this.hobbyTitle,
    required this.targetMinutesWeek,
    required this.spentMinutesToday,
    required this.spentMinutesWeek,
  });

  double get weekProgress {
    if (targetMinutesWeek <= 0) return 0.0;
    return (spentMinutesWeek / targetMinutesWeek).clamp(0.0, 1.0).toDouble();
  }
}

class HealthMealData {
  final String id;
  final String mealType;
  final int calories;
  final String description;

  const HealthMealData({
    required this.id,
    required this.mealType,
    required this.calories,
    required this.description,
  });

  factory HealthMealData.fromMap(Map<String, dynamic> map) {
    return HealthMealData(
      id: (map['id'] ?? '').toString(),
      mealType: (map['meal_type'] ?? '').toString(),
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      description: (map['description'] ?? '').toString(),
    );
  }
}

class HealthBurnData {
  final String id;
  final int caloriesBurned;
  final String note;

  const HealthBurnData({
    required this.id,
    required this.caloriesBurned,
    required this.note,
  });

  factory HealthBurnData.fromMap(Map<String, dynamic> map) {
    return HealthBurnData(
      id: (map['id'] ?? '').toString(),
      caloriesBurned: (map['calories_burned'] as num?)?.toInt() ?? 0,
      note: (map['note'] ?? '').toString(),
    );
  }
}

class HealthDaySummary {
  final int dailyTarget;
  final int consumed;
  final int burned;
  final int net;
  final int deltaVsTarget;
  final double waterLiters;
  final List<HealthMealData> meals;
  final List<HealthBurnData> burns;

  const HealthDaySummary({
    required this.dailyTarget,
    required this.consumed,
    required this.burned,
    required this.net,
    required this.deltaVsTarget,
    required this.waterLiters,
    required this.meals,
    required this.burns,
  });
}

class HomeTrackersRepo {
  HomeTrackersRepo({
    SupabaseClient? client,
    SecureCryptoService? crypto,
  })  : _client = client ?? Supabase.instance.client,
        _crypto = crypto ?? SecureCryptoService();

  final SupabaseClient _client;
  final SecureCryptoService _crypto;

  String get _uid {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.trim().isEmpty) {
      throw Exception('User is not authenticated');
    }
    return userId;
  }

  String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  DateTime _dayStart(DateTime date) => DateTime(date.year, date.month, date.day);

  DateTime _weekStart(DateTime date) {
    final d = _dayStart(date);
    return d.subtract(Duration(days: d.weekday - DateTime.monday));
  }

  DateTime _weekEndExclusive(DateTime date) =>
      _weekStart(date).add(const Duration(days: 7));

  String _normText(String? value) => (value ?? '').trim();

  String? _normOrNull(String? value) {
    final normalized = _normText(value);
    return normalized.isEmpty ? null : normalized;
  }

  Future<Map<String, dynamic>> _encryptShoppingPayload({
    required String title,
    String? description,
    String? storeName,
  }) {
    return _crypto.encryptJson({
      'title': _normText(title),
      'description': _normOrNull(description),
      'store_name': _normOrNull(storeName),
    });
  }

  Future<Map<String, dynamic>> _decryptShoppingRow(
    Map<String, dynamic> row,
  ) async {
    final encryptedPayload = row['encrypted_payload'];

    if (encryptedPayload == null || encryptedPayload is! Map) {
      return row;
    }

    try {
      final decryptedPayload = await _crypto.decryptJson(
        Map<String, dynamic>.from(encryptedPayload),
      );

      final title = decryptedPayload['title'];
      final description = decryptedPayload['description'];
      final storeName = decryptedPayload['store_name'];

      if (title is String && title.trim().isNotEmpty) {
        row['title'] = title.trim();
      }

      row['description'] = description is String && description.trim().isNotEmpty
          ? description.trim()
          : '';

      row['store_name'] = storeName is String && storeName.trim().isNotEmpty
          ? storeName.trim()
          : '';

      return row;
    } catch (_) {
      return row;
    }
  }

  Future<Map<String, dynamic>> _encryptHobbyPayload({
    required String title,
  }) {
    return _crypto.encryptJson({
      'title': _normText(title),
    });
  }

  Future<Map<String, dynamic>> _decryptHobbyRow(
    Map<String, dynamic> row,
  ) async {
    final encryptedPayload = row['encrypted_payload'];

    if (encryptedPayload == null || encryptedPayload is! Map) {
      return row;
    }

    try {
      final decryptedPayload = await _crypto.decryptJson(
        Map<String, dynamic>.from(encryptedPayload),
      );

      final title = decryptedPayload['title'];

      if (title is String && title.trim().isNotEmpty) {
        row['title'] = title.trim();
      }

      return row;
    } catch (_) {
      // Старые записи или записи, зашифрованные другим локальным ключом,
      // оставляем как есть, чтобы экран не падал.
      return row;
    }
  }

  Future<Map<String, dynamic>> _encryptHobbyEntryPayload({
    String? note,
  }) {
    return _crypto.encryptJson({
      'note': _normOrNull(note),
    });
  }

  Future<Map<String, dynamic>> _decryptHobbyEntryRow(
    Map<String, dynamic> row,
  ) async {
    final encryptedPayload = row['encrypted_payload'];

    if (encryptedPayload == null || encryptedPayload is! Map) {
      return row;
    }

    try {
      final decryptedPayload = await _crypto.decryptJson(
        Map<String, dynamic>.from(encryptedPayload),
      );

      final note = decryptedPayload['note'];

      row['note'] = note is String && note.trim().isNotEmpty
          ? note.trim()
          : '';

      return row;
    } catch (_) {
      // Старые записи или записи, зашифрованные другим локальным ключом,
      // оставляем как есть, чтобы экран не падал.
      return row;
    }
  }

  Future<Map<String, dynamic>> _encryptMealPayload({
    String? description,
  }) {
    return _crypto.encryptJson({
      'description': _normOrNull(description),
    });
  }

  Future<Map<String, dynamic>> _decryptMealRow(
    Map<String, dynamic> row,
  ) async {
    final encryptedPayload = row['encrypted_payload'];

    if (encryptedPayload == null || encryptedPayload is! Map) {
      return row;
    }

    try {
      final decryptedPayload = await _crypto.decryptJson(
        Map<String, dynamic>.from(encryptedPayload),
      );

      final description = decryptedPayload['description'];

      row['description'] =
          description is String && description.trim().isNotEmpty
              ? description.trim()
              : '';

      return row;
    } catch (_) {
      // Старые записи или записи, зашифрованные другим локальным ключом,
      // оставляем как есть, чтобы экран не падал.
      return row;
    }
  }

  Future<Map<String, dynamic>> _encryptBurnPayload({
    String? note,
  }) {
    return _crypto.encryptJson({
      'note': _normOrNull(note),
    });
  }

  Future<Map<String, dynamic>> _decryptBurnRow(
    Map<String, dynamic> row,
  ) async {
    final encryptedPayload = row['encrypted_payload'];

    if (encryptedPayload == null || encryptedPayload is! Map) {
      return row;
    }

    try {
      final decryptedPayload = await _crypto.decryptJson(
        Map<String, dynamic>.from(encryptedPayload),
      );

      final note = decryptedPayload['note'];

      row['note'] = note is String && note.trim().isNotEmpty
          ? note.trim()
          : '';

      return row;
    } catch (_) {
      // Старые записи или записи, зашифрованные другим локальным ключом,
      // оставляем как есть, чтобы экран не падал.
      return row;
    }
  }

  Future<List<ShoppingItemData>> listShoppingItems() async {
    final rows = await _client
        .from('shopping_items')
        .select(
          'id,user_id,title,description,price,store_name,due_date,expense_category_id,is_bought,is_wishlist,created_at,updated_at,encrypted_payload,categories(name)',
        )
        .eq('user_id', _uid)
        .order('is_bought', ascending: true)
        .order('due_date', ascending: true)
        .order('created_at', ascending: false);

    final out = <ShoppingItemData>[];

    for (final raw in rows as List) {
      final row = Map<String, dynamic>.from(raw as Map);
      final decryptedRow = await _decryptShoppingRow(row);
      out.add(ShoppingItemData.fromMap(decryptedRow));
    }

    return out;
  }

  Future<List<ExpenseCategoryLite>> listExpenseCategories() async {
    final rows = await _client
        .from('categories')
        .select('id,name')
        .eq('user_id', _uid)
        .eq('kind', 'expense')
        .order('name', ascending: true);

    return (rows as List)
        .map((raw) => ExpenseCategoryLite.fromMap(
              Map<String, dynamic>.from(raw as Map),
            ))
        .where((category) => category.id.isNotEmpty)
        .toList();
  }

  Future<void> createShoppingItem({
    required String title,
    String? description,
    double price = 0,
    String? storeName,
    DateTime? dueDate,
    String? expenseCategoryId,
    bool isWishlist = false,
  }) async {
    final normalizedTitle = _normText(title);
    if (normalizedTitle.isEmpty) throw Exception('Title cannot be empty');

    final encryptedPayload = await _encryptShoppingPayload(
      title: normalizedTitle,
      description: description,
      storeName: storeName,
    );

    await _client.from('shopping_items').insert({
      'user_id': _uid,
      'title': '[encrypted]',
      'description': null,
      'store_name': null,
      'price': price < 0 ? 0 : price,
      'due_date': dueDate?.toUtc().toIso8601String(),
      'expense_category_id': _normOrNull(expenseCategoryId),
      'is_bought': false,
      'is_wishlist': isWishlist,
      'encrypted_payload': encryptedPayload,
      'encryption_version': 1,
    });
  }

  Future<void> updateShoppingItem({
    required String id,
    required String title,
    String? description,
    double price = 0,
    String? storeName,
    DateTime? dueDate,
    String? expenseCategoryId,
    bool isBought = false,
    bool isWishlist = false,
  }) async {
    final normalizedTitle = _normText(title);
    if (normalizedTitle.isEmpty) throw Exception('Title cannot be empty');

    final encryptedPayload = await _encryptShoppingPayload(
      title: normalizedTitle,
      description: description,
      storeName: storeName,
    );

    await _client
        .from('shopping_items')
        .update({
          'title': '[encrypted]',
          'description': null,
          'store_name': null,
          'price': price < 0 ? 0 : price,
          'due_date': dueDate?.toUtc().toIso8601String(),
          'expense_category_id': _normOrNull(expenseCategoryId),
          'is_bought': isBought,
          'is_wishlist': isWishlist,
          'encrypted_payload': encryptedPayload,
          'encryption_version': 1,
        })
        .eq('id', id)
        .eq('user_id', _uid);
  }

  Future<void> toggleShoppingBought({
    required String id,
    required bool isBought,
  }) async {
    await _client
        .from('shopping_items')
        .update({'is_bought': isBought})
        .eq('id', id)
        .eq('user_id', _uid);
  }

  Future<void> deleteShoppingItem(String id) async {
    await _client
        .from('shopping_items')
        .delete()
        .eq('id', id)
        .eq('user_id', _uid);
  }

  Future<List<HobbySummary>> listHobbySummariesForWeek(DateTime anchor) async {
    final start = _weekStart(anchor);
    final end = _weekEndExclusive(anchor);
    final today = _dayStart(anchor);

    final hobbiesRaw = await _client
        .from('hobby_profiles')
        .select('id,title,target_minutes_week,encrypted_payload')
        .eq('user_id', _uid)
        .order('created_at', ascending: true);

    final entriesRaw = await _client
        .from('hobby_entries')
        .select('hobby_id,entry_date,minutes_spent')
        .eq('user_id', _uid)
        .gte('entry_date', start.toIso8601String())
        .lt('entry_date', end.toIso8601String());

    final spentWeek = <String, int>{};
    final spentToday = <String, int>{};

    for (final raw in entriesRaw as List) {
      final row = Map<String, dynamic>.from(raw as Map);
      final hobbyId = (row['hobby_id'] ?? '').toString();
      if (hobbyId.isEmpty) continue;

      final minutes = (row['minutes_spent'] as num?)?.toInt() ?? 0;
      spentWeek[hobbyId] = (spentWeek[hobbyId] ?? 0) + minutes;

      final date = _parseDateTime(row['entry_date']);
      if (date != null && _dateOnly(date) == _dateOnly(today)) {
        spentToday[hobbyId] = (spentToday[hobbyId] ?? 0) + minutes;
      }
    }

    final out = <HobbySummary>[];

    for (final raw in hobbiesRaw as List) {
      final row = Map<String, dynamic>.from(raw as Map);
      final decryptedRow = await _decryptHobbyRow(row);
      final hobbyId = (decryptedRow['id'] ?? '').toString();

      out.add(
        HobbySummary(
          hobbyId: hobbyId,
          hobbyTitle: (decryptedRow['title'] ?? '').toString(),
          targetMinutesWeek:
              (decryptedRow['target_minutes_week'] as num?)?.toInt() ?? 0,
          spentMinutesToday: spentToday[hobbyId] ?? 0,
          spentMinutesWeek: spentWeek[hobbyId] ?? 0,
        ),
      );
    }

    return out;
  }

  Future<void> createHobby({
    required String title,
    required int targetMinutesWeek,
  }) async {
    final normalizedTitle = _normText(title);
    if (normalizedTitle.isEmpty) throw Exception('Hobby title cannot be empty');

    final encryptedPayload = await _encryptHobbyPayload(
      title: normalizedTitle,
    );

    await _client.from('hobby_profiles').insert({
      'user_id': _uid,

      // Technical fallback. Real title is stored in encrypted_payload.
      'title': '[encrypted]',

      'target_minutes_week': targetMinutesWeek < 0 ? 0 : targetMinutesWeek,
      'encrypted_payload': encryptedPayload,
      'encryption_version': 1,
    });
  }

  Future<void> addHobbyEntry({
    required String hobbyId,
    required DateTime entryDate,
    required int minutesSpent,
    String? note,
  }) async {
    final normalizedNote = _normText(note);
    final encryptedPayload = await _encryptHobbyEntryPayload(
      note: normalizedNote,
    );

    await _client.from('hobby_entries').insert({
      'user_id': _uid,
      'hobby_id': hobbyId,
      'entry_date': entryDate.toIso8601String(),
      'minutes_spent': minutesSpent < 0 ? 0 : minutesSpent,

      // Technical fallback. Real note is stored in encrypted_payload.
      'note': normalizedNote.isEmpty ? '' : '[encrypted]',

      'encrypted_payload': encryptedPayload,
      'encryption_version': 1,
    });
  }

  Future<void> deleteHobby(String hobbyId) async {
    await _client
        .from('hobby_profiles')
        .delete()
        .eq('id', hobbyId)
        .eq('user_id', _uid);
  }

  Future<HealthDaySummary> loadHealthDaySummary(DateTime date) async {
    final start = _dayStart(date);
    final end = start.add(const Duration(days: 1));

    final profile = await _client
        .from('health_profiles')
        .select('daily_calorie_target')
        .eq('user_id', _uid)
        .maybeSingle();

    final mealsRaw = await _client
        .from('meal_entries')
        .select('id,meal_type,calories,description,encrypted_payload')
        .eq('user_id', _uid)
        .gte('entry_date', start.toIso8601String())
        .lt('entry_date', end.toIso8601String())
        .order('created_at', ascending: false);

    final burnsRaw = await _client
        .from('calorie_burn_entries')
        .select('id,calories_burned,note,encrypted_payload')
        .eq('user_id', _uid)
        .gte('entry_date', start.toIso8601String())
        .lt('entry_date', end.toIso8601String())
        .order('created_at', ascending: false);

    final waterRaw = await _client
        .from('water_entries')
        .select('liters')
        .eq('user_id', _uid)
        .gte('entry_date', start.toIso8601String())
        .lt('entry_date', end.toIso8601String());

    final meals = <HealthMealData>[];

    for (final raw in mealsRaw as List) {
      final row = Map<String, dynamic>.from(raw as Map);
      final decryptedRow = await _decryptMealRow(row);
      meals.add(HealthMealData.fromMap(decryptedRow));
    }

    final burns = <HealthBurnData>[];

    for (final raw in burnsRaw as List) {
      final row = Map<String, dynamic>.from(raw as Map);
      final decryptedRow = await _decryptBurnRow(row);
      burns.add(HealthBurnData.fromMap(decryptedRow));
    }

    final consumed = meals.fold<int>(0, (sum, item) => sum + item.calories);
    final burned = burns.fold<int>(0, (sum, item) => sum + item.caloriesBurned);
    final dailyTarget = (profile?['daily_calorie_target'] as num?)?.toInt() ?? 0;

    final waterLiters = (waterRaw as List).fold<double>(0, (sum, raw) {
      final row = Map<String, dynamic>.from(raw as Map);
      return sum + ((row['liters'] as num?)?.toDouble() ?? 0.0);
    });

    final net = consumed - burned;
    final deltaVsTarget = dailyTarget <= 0 ? net : net - dailyTarget;

    return HealthDaySummary(
      dailyTarget: dailyTarget,
      consumed: consumed,
      burned: burned,
      net: net,
      deltaVsTarget: deltaVsTarget,
      waterLiters: waterLiters,
      meals: meals,
      burns: burns,
    );
  }

  Future<void> upsertDailyCalorieTarget(int value) async {
    await _client.from('health_profiles').upsert({
      'user_id': _uid,
      'daily_calorie_target': value < 0 ? 0 : value,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }

  Future<void> addMeal({
    required DateTime entryDate,
    required String mealType,
    required int calories,
    required String description,
  }) async {
    final normalizedDescription = _normText(description);
    final encryptedPayload = await _encryptMealPayload(
      description: normalizedDescription,
    );

    await _client.from('meal_entries').insert({
      'user_id': _uid,
      'entry_date': entryDate.toIso8601String(),
      'meal_type': mealType,
      'calories': calories < 0 ? 0 : calories,

      // Technical fallback. Real description is stored in encrypted_payload.
      'description': normalizedDescription.isEmpty ? '' : '[encrypted]',

      'encrypted_payload': encryptedPayload,
      'encryption_version': 1,
    });
  }

  Future<void> addBurn({
    required DateTime entryDate,
    required int caloriesBurned,
    String? note,
  }) async {
    final normalizedNote = _normText(note);
    final encryptedPayload = await _encryptBurnPayload(
      note: normalizedNote,
    );

    await _client.from('calorie_burn_entries').insert({
      'user_id': _uid,
      'entry_date': entryDate.toIso8601String(),
      'calories_burned': caloriesBurned < 0 ? 0 : caloriesBurned,

      // Technical fallback. Real note is stored in encrypted_payload.
      'note': normalizedNote.isEmpty ? '' : '[encrypted]',

      'encrypted_payload': encryptedPayload,
      'encryption_version': 1,
    });
  }

  Future<void> addWater({
    required DateTime entryDate,
    required double liters,
  }) async {
    final start = _dayStart(entryDate);
    final end = start.add(const Duration(days: 1));

    await _client
        .from('water_entries')
        .delete()
        .eq('user_id', _uid)
        .gte('entry_date', start.toIso8601String())
        .lt('entry_date', end.toIso8601String());

    await _client.from('water_entries').insert({
      'user_id': _uid,
      'entry_date': entryDate.toIso8601String(),
      'liters': liters < 0 ? 0 : liters,
    });
  }

  Future<void> deleteMeal(String id) async {
    await _client.from('meal_entries').delete().eq('id', id).eq('user_id', _uid);
  }

  Future<void> deleteBurn(String id) async {
    await _client
        .from('calorie_burn_entries')
        .delete()
        .eq('id', id)
        .eq('user_id', _uid);
  }
}
