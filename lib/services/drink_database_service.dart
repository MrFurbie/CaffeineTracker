import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/drink.dart';

class DrinkDatabaseService {
  static final DrinkDatabaseService _instance = DrinkDatabaseService._internal();
  factory DrinkDatabaseService() => _instance;
  DrinkDatabaseService._internal();

  DrinkDatabase? _drinkDatabase;

  Future<void> loadDrinkDatabase() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/predefined_drinks.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _drinkDatabase = DrinkDatabase.fromJson(jsonData);
      print('Successfully loaded drink database with ${_drinkDatabase?.drinks.length ?? 0} drinks');
    } catch (e) {
      print('Error loading drink database: $e');
    }
  }

  List<Drink> getAllDrinks() {
    return _drinkDatabase?.drinks ?? [];
  }

  Drink? getDrinkById(String id) {
    try {
      return _drinkDatabase?.drinks.firstWhere((drink) => drink.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Drink> getDrinksByCategory(String category) {
    return _drinkDatabase?.drinks.where((drink) => drink.category == category).toList() ?? [];
  }

  List<DrinkCategory> getAllCategories() {
    return _drinkDatabase?.categories ?? [];
  }

  List<Drink> searchDrinks(String query) {
    final lowerQuery = query.toLowerCase();
    return _drinkDatabase?.drinks.where((drink) =>
        drink.name.toLowerCase().contains(lowerQuery) ||
        drink.brand.toLowerCase().contains(lowerQuery)
    ).toList() ?? [];
  }

  DefaultSettings? getDefaultSettings() {
    return _drinkDatabase?.defaultSettings;
  }

  ServingSize? getServingSize(String drinkId, String servingSizeId) {
    final drink = getDrinkById(drinkId);
    try {
      return drink?.servingSizes.firstWhere((size) => size.id == servingSizeId);
    } catch (e) {
      return null;
    }
  }
}