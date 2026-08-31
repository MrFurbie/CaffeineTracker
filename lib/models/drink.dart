class Drink {
  final String id;
  final String name;
  final String brand;
  final String category;
  final int baseCaffeine;
  final List<ServingSize> servingSizes;
  final String? icon;
  final bool isCustom;

  Drink({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.baseCaffeine,
    required this.servingSizes,
    this.icon,
    this.isCustom = false,
  });

  int caffeineAmountFor(ServingSize servingSize) {
    return (baseCaffeine * servingSize.caffeineMultiplier).round();
  }

  factory Drink.fromJson(Map<String, dynamic> json) {
    return Drink(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      category: json['category'] as String,
      baseCaffeine: json['baseCaffeine'] as int,
      servingSizes: (json['servingSizes'] as List)
          .map((e) => ServingSize.fromJson(e as Map<String, dynamic>))
          .toList(),
      icon: json['icon'] as String?,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'baseCaffeine': baseCaffeine,
      'servingSizes': servingSizes.map((e) => e.toJson()).toList(),
      'icon': icon,
      'isCustom': isCustom,
    };
  }
}

class ServingSize {
  final String id;
  final String name;
  final int volumeML;
  final double caffeineMultiplier;

  ServingSize({
    required this.id,
    required this.name,
    required this.volumeML,
    required this.caffeineMultiplier,
  });

  factory ServingSize.fromJson(Map<String, dynamic> json) {
    return ServingSize(
      id: json['id'] as String,
      name: json['name'] as String,
      volumeML: json['volumeML'] as int,
      caffeineMultiplier: (json['caffeineMultiplier'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'volumeML': volumeML,
      'caffeineMultiplier': caffeineMultiplier,
    };
  }
}

class DrinkCategory {
  final String id;
  final String name;
  final String icon;

  DrinkCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory DrinkCategory.fromJson(Map<String, dynamic> json) {
    return DrinkCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }
}

class DefaultSettings {
  final int dailyCaffeineLimit;
  final int recommendedLimit;
  final String units;

  DefaultSettings({
    required this.dailyCaffeineLimit,
    required this.recommendedLimit,
    required this.units,
  });

  factory DefaultSettings.fromJson(Map<String, dynamic> json) {
    return DefaultSettings(
      dailyCaffeineLimit: json['dailyCaffeineLimit'] as int,
      recommendedLimit: json['recommendedLimit'] as int,
      units: json['units'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyCaffeineLimit': dailyCaffeineLimit,
      'recommendedLimit': recommendedLimit,
      'units': units,
    };
  }
}

class DrinkDatabase {
  final List<Drink> drinks;
  final List<DrinkCategory> categories;
  final DefaultSettings defaultSettings;

  DrinkDatabase({
    required this.drinks,
    required this.categories,
    required this.defaultSettings,
  });

  factory DrinkDatabase.fromJson(Map<String, dynamic> json) {
    return DrinkDatabase(
      drinks: (json['drinks'] as List)
          .map((e) => Drink.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List)
          .map((e) => DrinkCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      defaultSettings: DefaultSettings.fromJson(
          json['defaultSettings'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drinks': drinks.map((e) => e.toJson()).toList(),
      'categories': categories.map((e) => e.toJson()).toList(),
      'defaultSettings': defaultSettings.toJson(),
    };
  }
}