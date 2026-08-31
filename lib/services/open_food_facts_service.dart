import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/drink.dart';

class OpenFoodFactsService {
  static const String baseUrl = 'https://world.openfoodfacts.org/api/v2/product';
  
  final Map<String, Drink> _cache = {};

  Future<Drink?> lookupProduct(String barcode) async {
    // Check cache first
    if (_cache.containsKey(barcode)) {
      return _cache[barcode];
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$barcode.json'),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 1 && data['product'] != null) {
          final product = data['product'];
          final drink = _parseProductToDrink(product, barcode);
          
          if (drink != null) {
            _cache[barcode] = drink;
            return drink;
          }
        }
      }
      
      return null;
    } catch (e) {
      // Handle network errors, timeouts, etc.
      return null;
    }
  }

  Drink? _parseProductToDrink(Map<String, dynamic> product, String barcode) {
    try {
      final productName = product['product_name'] as String? ?? 
                         product['product_name_en'] as String? ?? 
                         'Unknown Product';
      
      final brand = product['brands'] as String? ?? 
                   product['brands_tags']?.first as String? ?? 
                   'Unknown Brand';
      
      // Extract caffeine from nutriments
      final nutriments = product['nutriments'] as Map<String, dynamic>?;
      final caffeine100g = nutriments?['caffeine_100g'] as num?;
      
      // If no caffeine data is available, return null
      if (caffeine100g == null || caffeine100g <= 0) {
        return null;
      }

      // Determine category based on product categories
      final categories = product['categories'] as String? ?? 
                       product['categories_tags'] as String? ?? '';
      final category = _determineCategory(categories);

      // Use caffeine per 100g as the base
      final baseCaffeine = caffeine100g.toInt();

      // Create serving sizes based on common caffeine drink sizes
      final servingSizes = _createServingSizes(baseCaffeine);

      return Drink(
        id: barcode,
        name: productName,
        brand: brand,
        category: category,
        baseCaffeine: baseCaffeine.toInt(),
        servingSizes: servingSizes,
        icon: _getIconForCategory(category),
        isCustom: true,
      );
    } catch (e) {
      return null;
    }
  }

  String _determineCategory(String categories) {
    final lowerCategories = categories.toLowerCase();
    
    if (lowerCategories.contains('energy') || lowerCategories.contains('energy drink')) {
      return 'energy_drink';
    } else if (lowerCategories.contains('coffee') || lowerCategories.contains('caffeine')) {
      return 'coffee';
    } else if (lowerCategories.contains('soda') || lowerCategories.contains('carbonated')) {
      return 'soda';
    } else if (lowerCategories.contains('tea')) {
      return 'coffee';
    } else if (lowerCategories.contains('shot')) {
      return 'energy_shot';
    } else {
      return 'energy_drink'; // Default to energy drink for caffeinated products
    }
  }

  String? _getIconForCategory(String category) {
    switch (category) {
      case 'energy_drink':
        return 'bolt';
      case 'energy_shot':
        return 'water_drop';
      case 'coffee':
        return 'coffee';
      case 'soda':
        return 'local_drink';
      default:
        return 'bolt';
    }
  }

  List<ServingSize> _createServingSizes(int baseCaffeine) {
    // Create serving sizes based on common caffeine drink containers
    final servingSizes = <ServingSize>[];
    
    // Default serving size (100ml as base)
    servingSizes.add(ServingSize(
      id: 'standard',
      name: 'Standard (100ml)',
      volumeML: 100,
      caffeineMultiplier: 1.0,
    ));

    // Add common sizes based on caffeine content
    if (baseCaffeine >= 80) {
      // Energy drink sizes
      servingSizes.add(ServingSize(
        id: 'can',
        name: 'Can (250ml)',
        volumeML: 250,
        caffeineMultiplier: 2.5,
      ));
      
      servingSizes.add(ServingSize(
        id: 'large',
        name: 'Large (473ml)',
        volumeML: 473,
        caffeineMultiplier: 4.73,
      ));
    } else {
      // Coffee sizes
      servingSizes.add(ServingSize(
        id: 'small',
        name: 'Small (150ml)',
        volumeML: 150,
        caffeineMultiplier: 1.5,
      ));
      
      servingSizes.add(ServingSize(
        id: 'medium',
        name: 'Medium (240ml)',
        volumeML: 240,
        caffeineMultiplier: 2.4,
      ));
      
      servingSizes.add(ServingSize(
        id: 'large',
        name: 'Large (350ml)',
        volumeML: 350,
        caffeineMultiplier: 3.5,
      ));
    }

    return servingSizes;
  }

  void clearCache() {
    _cache.clear();
  }
}