import 'package:flutter/foundation.dart';
import '../models/consumption_record.dart';
import 'data_manager.dart';
import 'drink_database_service.dart';

class HomeProvider extends ChangeNotifier {
  final DrinkDatabaseService _drinkDatabase = DrinkDatabaseService();

  List<ConsumptionRecord> _todayRecords = [];
  int _todayTotal = 0;
  int _dailyLimit = 400;
  int _drinkCount = 0;
  bool _isLoading = false;

  List<ConsumptionRecord> get todayRecords => _todayRecords;
  int get todayTotal => _todayTotal;
  int get dailyLimit => _dailyLimit;
  int get drinkCount => _drinkCount;
  bool get isLoading => _isLoading;

  double get progressPercentage {
    return (_todayTotal / _dailyLimit).clamp(0.0, 1.0);
  }

  int get remainingCaffeine {
    return (_dailyLimit - _todayTotal).clamp(0, _dailyLimit);
  }

  bool get isOverLimit {
    return _todayTotal > _dailyLimit;
  }

  Future<void> init() async {
    await _drinkDatabase.loadDrinkDatabase();
    loadTodayData();
    loadDailyLimit();
  }

  void loadTodayData() {
    _isLoading = true;
    notifyListeners();
    
    _todayRecords = DataManager.fetchTodayRecords();
    _calculateTodayTotal();
    
    _isLoading = false;
    notifyListeners();
  }

  void _calculateTodayTotal() {
    _todayTotal = _todayRecords.fold(0, (sum, record) => sum + record.caffeineAmount);
    _drinkCount = _todayRecords.length;
  }

  void loadDailyLimit() {
    final settings = _drinkDatabase.getDefaultSettings();
    if (settings != null) {
      _dailyLimit = settings.dailyCaffeineLimit;
      notifyListeners();
    }
  }

  Future<void> addConsumption(String drinkId, String servingSizeId) async {
    final drink = _drinkDatabase.getDrinkById(drinkId);
    if (drink == null) return;

    final servingSize = drink.servingSizes.firstWhere(
      (size) => size.id == servingSizeId,
      orElse: () => drink.servingSizes.first,
    );

    final caffeineAmount = drink.caffeineAmountFor(servingSize);
    final record = ConsumptionRecord.create(
      drinkId: drinkId,
      servingSizeId: servingSizeId,
      caffeineAmount: caffeineAmount,
    );

    await DataManager.saveConsumptionRecord(record);
    loadTodayData();
  }

  Future<void> deleteRecord(String id) async {
    await DataManager.deleteConsumptionRecord(id);
    loadTodayData();
  }

  String getDrinkName(ConsumptionRecord record) {
    final drink = _drinkDatabase.getDrinkById(record.drinkId);
    return drink?.name ?? 'Unknown Drink';
  }

  String getServingSizeName(ConsumptionRecord record) {
    final drink = _drinkDatabase.getDrinkById(record.drinkId);
    if (drink == null) return '';
    
    final servingSize = drink.servingSizes.firstWhere(
      (size) => size.id == record.servingSizeId,
      orElse: () => drink.servingSizes.first,
    );
    return servingSize.name;
  }
}