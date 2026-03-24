
import 'package:supabase_flutter/supabase_flutter.dart';

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
    if (targetMinutesWeek <= 0) return 0;
    return (spentMinutesWeek / targetMinutesWeek).clamp(0.0, 1.0);
  }
}

class MealEntryData {
  final String id;
  final DateTime entryDate;
  final String mealType;
  final int calories;
  final String description;

  const MealEntryData({
    required this.id,
    required this.entryDate,
    required this.mealType,
    required this.calories,
    required this.description,
  });

  factory MealEntryData.fromMap(Map<String, dynamic> map) {
    return MealEntryData(
      id: map['id'] as String,
      entryDate: DateTime.parse(map['entry_date'] as String),
      mealType: (map['meal_type'] as String?) ?? 'snack',
      calories: ((map['calories'] as num?) ?? 0).round(),
      description: (map['description'] as String?) ?? '',
    );
  }
}

class BurnEntryData {
  final String id;
  final DateTime entryDate;
  final int caloriesBurned;
  final String note;

  const BurnEntryData({
    required this.id,
    required this.entryDate,
    required this.caloriesBurned,
    required this.note,
  });

  factory BurnEntryData.fromMap(Map<String, dynamic> map) {
    return BurnEntryData(
      id: map['id'] as String,
      entryDate: DateTime.parse(map['entry_date'] as String),
      caloriesBurned: ((map['calories_burned'] as num?) ?? 0).round(),
      note: (map['note'] as String?) ?? '',
    );
  }
}

class WaterEntryData {
  final String id;
  final DateTime entryDate;
  final double liters;

  const WaterEntryData({
    required this.id,
    required this.entryDate,
    required this.liters,
  });

  factory WaterEntryData.fromMap(Map<String, dynamic> map) {
    return WaterEntryData(
      id: map['id'] as String,
      entryDate: DateTime.parse(map['entry_date'] as String),
      liters: ((map['liters'] as num?) ?? 0).toDouble(),
    );
  }
}

class HealthDaySummary {
  final int dailyTarget;
  final List<MealEntryData> meals;
  final List<BurnEntryData> burns;
  final List<WaterEntryData> waterEntries;

  const HealthDaySummary({
    required this.dailyTarget,
    required this.meals,
    required this.burns,
    required this.waterEntries,
  });

  int get consumed => meals.fold(0, (s, e) => s + e.calories);
  int get burned => burns.fold(0, (s, e) => s + e.caloriesBurned);
  int get net => consumed - burned;
  int get deltaVsTarget => consumed - dailyTarget;
  double get waterLiters => waterEntries.fold(0.0, (s, e) => s + e.liters);
}

class ExpenseCategoryLite {
  final String id;
  final String name;

  const ExpenseCategoryLite({
    required this.id,
    required this.name,
  });

  factory ExpenseCategoryLite.fromMap(Map<String, dynamic> map) {
    return ExpenseCategoryLite(
      id: map['id'] as String,
      name: (map['name'] as String?) ?? 'Без категории',
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
  });

  factory ShoppingItemData.fromMap(Map<String, dynamic> map) {
    final cat = map['categories'];
    String? categoryName;
    if (cat is Map<String, dynamic>) {
      categoryName = cat['name'] as String?;
    }

    return ShoppingItemData(
      id: map['id'] as String,
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      price: ((map['price'] as num?) ?? 0).toDouble(),
      storeName: (map['store_name'] as String?) ?? '',
      dueDate: map['due_date'] == null
          ? null
          : DateTime.tryParse(map['due_date'] as String),
      expenseCategoryId: map['expense_category_id'] as String?,
      expenseCategoryName: categoryName,
      isBought: (map['is_bought'] as bool?) ?? false,
      isWishlist: (map['is_wishlist'] as bool?) ?? false,
    );
  }
}

class HomeTrackersRepo {
  HomeTrackersRepo({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('User is not authenticated.');
    return id;
  }

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _endOfDayExclusive(DateTime d) =>
      DateTime(d.year, d.month, d.day).add(const Duration(days: 1));

  DateTime _startOfWeek(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  DateTime _endOfWeekExclusive(DateTime d) =>
      _startOfWeek(d).add(const Duration(days: 7));

  Future<List<HobbySummary>> listHobbySummariesForWeek(DateTime anchor) async {
    final userId = _uid;
    final startDay = _startOfDay(anchor);
    final endDay = _endOfDayExclusive(anchor);
    final weekStart = _startOfWeek(anchor);
    final weekEnd = _endOfWeekExclusive(anchor);

    final hobbies = await _client
        .from('hobby_profiles')
        .select('id,title,target_minutes_week')
        .eq('user_id', userId)
        .order('created_at');

    final entries = await _client
        .from('hobby_entries')
        .select('hobby_id,entry_date,minutes_spent')
        .eq('user_id', userId)
        .gte('entry_date', weekStart.toIso8601String())
        .lt('entry_date', weekEnd.toIso8601String());

    final todayTotals = <String, int>{};
    final weekTotals = <String, int>{};

    for (final row in entries) {
      final map = row as Map<String, dynamic>;
      final hobbyId = map['hobby_id'] as String;
      final minutes = ((map['minutes_spent'] as num?) ?? 0).round();
      final ts = DateTime.tryParse(map['entry_date'] as String? ?? '');

      weekTotals[hobbyId] = (weekTotals[hobbyId] ?? 0) + minutes;
      if (ts != null && !ts.isBefore(startDay) && ts.isBefore(endDay)) {
        todayTotals[hobbyId] = (todayTotals[hobbyId] ?? 0) + minutes;
      }
    }

    return [
      for (final row in hobbies)
        HobbySummary(
          hobbyId: row['id'] as String,
          hobbyTitle: (row['title'] as String?) ?? 'Хобби',
          targetMinutesWeek: ((row['target_minutes_week'] as num?) ?? 0).round(),
          spentMinutesToday: todayTotals[row['id'] as String] ?? 0,
          spentMinutesWeek: weekTotals[row['id'] as String] ?? 0,
        ),
    ];
  }

  Future<void> createHobby({
    required String title,
    required int targetMinutesWeek,
  }) async {
    await _client.from('hobby_profiles').insert({
      'user_id': _uid,
      'title': title.trim(),
      'target_minutes_week': targetMinutesWeek,
    });
  }

  Future<void> deleteHobby(String hobbyId) async {
    await _client
        .from('hobby_profiles')
        .delete()
        .eq('id', hobbyId)
        .eq('user_id', _uid);
  }

  Future<void> addHobbyEntry({
    required String hobbyId,
    required DateTime entryDate,
    required int minutesSpent,
    String? note,
  }) async {
    await _client.from('hobby_entries').insert({
      'user_id': _uid,
      'hobby_id': hobbyId,
      'entry_date': entryDate.toIso8601String(),
      'minutes_spent': minutesSpent,
      'note': note?.trim(),
    });
  }

  Future<int> getDailyCalorieTarget() async {
    final rows = await _client
        .from('health_profiles')
        .select('daily_calorie_target')
        .eq('user_id', _uid)
        .limit(1);

    if (rows.isEmpty) return 0;
    return ((rows.first['daily_calorie_target'] as num?) ?? 0).round();
  }

  Future<void> upsertDailyCalorieTarget(int target) async {
    await _client.from('health_profiles').upsert(
      {
        'user_id': _uid,
        'daily_calorie_target': target,
      },
      onConflict: 'user_id',
    );
  }

  Future<HealthDaySummary> loadHealthDaySummary(DateTime day) async {
    final start = _startOfDay(day);
    final end = _endOfDayExclusive(day);
    final target = await getDailyCalorieTarget();

    final mealsRows = await _client
        .from('meal_entries')
        .select()
        .eq('user_id', _uid)
        .gte('entry_date', start.toIso8601String())
        .lt('entry_date', end.toIso8601String())
        .order('entry_date');

    final burnRows = await _client
        .from('calorie_burn_entries')
        .select()
        .eq('user_id', _uid)
        .gte('entry_date', start.toIso8601String())
        .lt('entry_date', end.toIso8601String())
        .order('entry_date');

    final waterRows = await _client
        .from('water_entries')
        .select()
        .eq('user_id', _uid)
        .gte('entry_date', start.toIso8601String())
        .lt('entry_date', end.toIso8601String())
        .order('entry_date');

    return HealthDaySummary(
      dailyTarget: target,
      meals: [
        for (final row in mealsRows)
          MealEntryData.fromMap(row as Map<String, dynamic>),
      ],
      burns: [
        for (final row in burnRows)
          BurnEntryData.fromMap(row as Map<String, dynamic>),
      ],
      waterEntries: [
        for (final row in waterRows)
          WaterEntryData.fromMap(row as Map<String, dynamic>),
      ],
    );
  }

  Future<void> addMeal({
    required DateTime entryDate,
    required String mealType,
    required int calories,
    required String description,
  }) async {
    await _client.from('meal_entries').insert({
      'user_id': _uid,
      'entry_date': entryDate.toIso8601String(),
      'meal_type': mealType,
      'calories': calories,
      'description': description.trim(),
    });
  }

  Future<void> addBurn({
    required DateTime entryDate,
    required int caloriesBurned,
    String? note,
  }) async {
    await _client.from('calorie_burn_entries').insert({
      'user_id': _uid,
      'entry_date': entryDate.toIso8601String(),
      'calories_burned': caloriesBurned,
      'note': note?.trim(),
    });
  }

  Future<void> addWater({
    required DateTime entryDate,
    required double liters,
  }) async {
    final start = _startOfDay(entryDate);
    final end = _endOfDayExclusive(entryDate);

    await _client
        .from('water_entries')
        .delete()
        .eq('user_id', _uid)
        .gte('entry_date', start.toIso8601String())
        .lt('entry_date', end.toIso8601String());

    await _client.from('water_entries').insert({
      'user_id': _uid,
      'entry_date': entryDate.toIso8601String(),
      'liters': liters,
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

  Future<List<ExpenseCategoryLite>> listExpenseCategories() async {
    final rows = await _client
        .from('categories')
        .select('id,name')
        .eq('user_id', _uid)
        .eq('kind', 'expense')
        .order('name');

    return [
      for (final row in rows)
        ExpenseCategoryLite.fromMap(row as Map<String, dynamic>),
    ];
  }

  Future<List<ShoppingItemData>> listShoppingItems() async {
    final rows = await _client
        .from('shopping_items')
        .select(
          'id,title,description,price,store_name,due_date,expense_category_id,is_bought,is_wishlist,categories(name)',
        )
        .eq('user_id', _uid)
        .order('is_wishlist')
        .order('is_bought')
        .order('due_date', ascending: true);

    return [
      for (final row in rows)
        ShoppingItemData.fromMap(row as Map<String, dynamic>),
    ];
  }

  Future<void> createShoppingItem({
    required String title,
    required String description,
    required double price,
    required String storeName,
    DateTime? dueDate,
    String? expenseCategoryId,
    required bool isWishlist,
  }) async {
    await _client.from('shopping_items').insert({
      'user_id': _uid,
      'title': title.trim(),
      'description': description.trim(),
      'price': price,
      'store_name': storeName.trim(),
      'due_date': dueDate?.toIso8601String(),
      'expense_category_id': expenseCategoryId,
      'is_bought': false,
      'is_wishlist': isWishlist,
    });
  }

  Future<void> updateShoppingItem({
    required String id,
    required String title,
    required String description,
    required double price,
    required String storeName,
    DateTime? dueDate,
    String? expenseCategoryId,
    required bool isBought,
    required bool isWishlist,
  }) async {
    await _client.from('shopping_items').update({
      'title': title.trim(),
      'description': description.trim(),
      'price': price,
      'store_name': storeName.trim(),
      'due_date': dueDate?.toIso8601String(),
      'expense_category_id': expenseCategoryId,
      'is_bought': isBought,
      'is_wishlist': isWishlist,
    }).eq('id', id).eq('user_id', _uid);
  }

  Future<void> toggleShoppingBought({
    required String id,
    required bool isBought,
  }) async {
    await _client.from('shopping_items').update({
      'is_bought': isBought,
    }).eq('id', id).eq('user_id', _uid);
  }

  Future<void> deleteShoppingItem(String id) async {
    await _client
        .from('shopping_items')
        .delete()
        .eq('id', id)
        .eq('user_id', _uid);
  }
}
