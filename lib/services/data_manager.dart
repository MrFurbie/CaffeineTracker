import 'package:hive_flutter/hive_flutter.dart';
import '../models/consumption_record.dart';
import '../models/consumption_record_adapter.dart';
import '../models/drink.dart';

class DataManager {
  static const String _consumptionBoxName = 'consumption_records';
  static const String _customDrinksBoxName = 'custom_drinks';
  static const String _settingsBoxName = 'app_settings';

  static Box<ConsumptionRecord>? _consumptionBox;
  static Box? _customDrinksBox;
  static Box<String>? _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(ConsumptionRecordAdapter());
    
    // Open boxes
    _consumptionBox = await Hive.openBox<ConsumptionRecord>(_consumptionBoxName);
    _customDrinksBox = await Hive.openBox(_customDrinksBoxName);
    _settingsBox = await Hive.openBox<String>(_settingsBoxName);
  }

  // Consumption Records
  static Future<void> saveConsumptionRecord(ConsumptionRecord record) async {
    await _consumptionBox?.put(record.id, record);
  }

  static List<ConsumptionRecord> fetchConsumptionRecords() {
    return _consumptionBox?.values.toList() ?? [];
  }

  static List<ConsumptionRecord> fetchTodayRecords() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return _consumptionBox?.values
        .where((record) => 
            record.timestamp.isAfter(todayStart) && 
            record.timestamp.isBefore(todayEnd))
        .toList() ?? [];
  }

  static List<ConsumptionRecord> fetchRecordsForDate(DateTime date) {
    final dateStart = DateTime(date.year, date.month, date.day);
    final dateEnd = dateStart.add(const Duration(days: 1));

    return _consumptionBox?.values
        .where((record) => 
            record.timestamp.isAfter(dateStart) && 
            record.timestamp.isBefore(dateEnd))
        .toList() ?? [];
  }

  static Future<void> deleteConsumptionRecord(String id) async {
    await _consumptionBox?.delete(id);
  }

  // Custom Drinks
  static Future<void> saveCustomDrink(Drink drink) async {
    await _customDrinksBox?.put(drink.id, drink.toJson());
  }

  static List<Drink> fetchCustomDrinks() {
    final drinksJson = _customDrinksBox?.values.toList() ?? [];
    return drinksJson.map((json) => Drink.fromJson(json as Map<String, dynamic>)).toList();
  }

  static Future<void> deleteCustomDrink(String id) async {
    await _customDrinksBox?.delete(id);
  }

  // Settings
  static Future<void> saveSetting(String key, String value) async {
    await _settingsBox?.put(key, value);
  }

  static String? getSetting(String key) {
    return _settingsBox?.get(key);
  }

  static Future<void> clearAllData() async {
    await _consumptionBox?.clear();
    await _customDrinksBox?.clear();
    await _settingsBox?.clear();
  }

  static Future<void> close() async {
    await _consumptionBox?.close();
    await _customDrinksBox?.close();
    await _settingsBox?.close();
  }
}