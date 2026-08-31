import 'package:flutter/foundation.dart';
import '../models/drink.dart';
import 'data_manager.dart';
import 'drink_database_service.dart';

class DrinkDatabaseProvider extends ChangeNotifier {
  final DrinkDatabaseService _drinkDatabase = DrinkDatabaseService();

  List<Drink> _allDrinks = [];
  List<Drink> _filteredDrinks = [];
  List<DrinkCategory> _categories = [];
  DrinkCategory? _selectedCategory;
  String _searchQuery = '';
  List<Drink> _customDrinks = [];
  bool _isLoading = false;

  List<Drink> get allDrinks => _allDrinks;
  List<Drink> get filteredDrinks => _filteredDrinks;
  List<DrinkCategory> get categories => _categories;
  DrinkCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<Drink> get customDrinks => _customDrinks;
  bool get isLoading => _isLoading;

  int get totalDrinkCount => _allDrinks.length + _customDrinks.length;
  int get customDrinkCount => _customDrinks.length;

  Future<void> init() async {
    await loadDrinkDatabase();
    await loadCustomDrinks();
  }

  Future<void> loadDrinkDatabase() async {
    _isLoading = true;
    notifyListeners();

    await _drinkDatabase.loadDrinkDatabase();
    _allDrinks = _drinkDatabase.getAllDrinks();
    _categories = _drinkDatabase.getAllCategories();
    _filteredDrinks = _allDrinks;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCustomDrinks() async {
    _customDrinks = DataManager.fetchCustomDrinks();
    _updateFilteredDrinks();
  }

  void filterByCategory(DrinkCategory category) {
    _selectedCategory = category;
    if (category.id == 'all') {
      _filteredDrinks = [..._allDrinks, ..._customDrinks];
    } else {
      _filteredDrinks = [..._allDrinks, ..._customDrinks]
          .where((drink) => drink.category == category.id)
          .toList();
    }
    notifyListeners();
  }

  void selectAllCategories() {
    _selectedCategory = null;
    _filteredDrinks = [..._allDrinks, ..._customDrinks];
    notifyListeners();
  }

  void searchDrinks(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      if (_selectedCategory != null) {
        filterByCategory(_selectedCategory!);
      } else {
        _filteredDrinks = [..._allDrinks, ..._customDrinks];
      }
    } else {
      final baseDrinks = _drinkDatabase.searchDrinks(query);
      final customMatches = _customDrinks.where((drink) =>
          drink.name.toLowerCase().contains(query.toLowerCase()) ||
          drink.brand.toLowerCase().contains(query.toLowerCase())
      ).toList();
      _filteredDrinks = [...baseDrinks, ...customMatches];
    }
    notifyListeners();
  }

  Future<void> addCustomDrink(Drink drink) async {
    await DataManager.saveCustomDrink(drink);
    await loadCustomDrinks();
  }

  Drink? getDrinkById(String id) {
    final predefinedDrink = _drinkDatabase.getDrinkById(id);
    if (predefinedDrink != null) return predefinedDrink;
    return _customDrinks.firstWhere((drink) => drink.id == id);
  }

  void _updateFilteredDrinks() {
    if (_selectedCategory != null) {
      filterByCategory(_selectedCategory!);
    } else {
      _filteredDrinks = [..._allDrinks, ..._customDrinks];
    }
  }
}