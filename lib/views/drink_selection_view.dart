import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drink.dart';
import '../services/home_provider.dart';
import '../services/drink_database_provider.dart';
import 'custom_drink_view.dart';
import 'barcode_scanner_view.dart';

class DrinkSelectionView extends StatefulWidget {
  const DrinkSelectionView({Key? key}) : super(key: key);

  @override
  State<DrinkSelectionView> createState() => _DrinkSelectionViewState();
}

class _DrinkSelectionViewState extends State<DrinkSelectionView> {
  String _searchQuery = '';
  DrinkCategory? _selectedCategory;
  ServingSize? _selectedServingSize;

  @override
  Widget build(BuildContext context) {
    return Consumer<DrinkDatabaseProvider>(
      builder: (context, drinkProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Add Drink'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BarcodeScannerView()),
                    );
                  },
                  child: const Text(
                    'Scan',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CustomDrinkView()),
                    );
                  },
                  child: const Text(
                    'Custom',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildSearchBar(),
              _buildCategoryFilter(drinkProvider),
              Expanded(
                child: _buildDrinkList(drinkProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              const Color(0xFFF8F9FE),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search drinks...',
            hintStyle: const TextStyle(color: Color(0xFF636E72)),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF6C63FF)),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFF6C63FF)),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(DrinkDatabaseProvider provider) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _CategoryChip(
            name: 'All',
            isSelected: _selectedCategory == null,
            onTap: () {
              setState(() {
                _selectedCategory = null;
                provider.selectAllCategories();
              });
            },
          ),
          ...provider.categories.map((category) => _CategoryChip(
            name: category.name,
            isSelected: _selectedCategory?.id == category.id,
            onTap: () {
              setState(() {
                _selectedCategory = category;
                provider.filterByCategory(category);
              });
            },
          )),
        ],
      ),
    );
  }

  Widget _buildDrinkList(DrinkDatabaseProvider provider) {
    final filteredDrinks = _searchQuery.isEmpty
        ? provider.filteredDrinks
        : provider.filteredDrinks.where((drink) =>
            drink.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            drink.brand.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredDrinks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 50, color: Colors.grey),
            SizedBox(height: 16),
            Text('No drinks found', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Try a different search term or category'),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredDrinks.length,
      itemBuilder: (context, index) {
        final drink = filteredDrinks[index];
        return _DrinkCard(
          drink: drink,
          onTap: () {
            setState(() {
              _selectedServingSize = drink.servingSizes.first;
            });
            _showServingSizeDialog(drink);
          },
        );
      },
    );
  }

  void _showServingSizeDialog(Drink drink) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(drink.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Size'),
            const SizedBox(height: 16),
            ...drink.servingSizes.map((size) => _ServingSizeCard(
              size: size,
              baseCaffeine: drink.baseCaffeine,
              isSelected: _selectedServingSize?.id == size.id,
              onTap: () {
                setState(() {
                  _selectedServingSize = size;
                });
              },
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _selectedServingSize != null
                ? () {
                    final homeProvider = context.read<HomeProvider>();
                    homeProvider.addConsumption(drink.id, _selectedServingSize!.id);
                    Navigator.pop(context); // Close serving size dialog
                    Navigator.pop(context); // Close drink selection
                  }
                : null,
            child: Text('Add ${drink.name}'),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : const Color(0xFF636E72),
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: const Color(0xFF6C63FF),
        checkmarkColor: Colors.white,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: isSelected ? Colors.transparent : const Color(0xFF6C63FF).withOpacity(0.3),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _DrinkCard extends StatelessWidget {
  final Drink drink;
  final VoidCallback onTap;

  const _DrinkCard({
    required this.drink,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF8F9FE),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForCategory(drink.category),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${drink.baseCaffeine} mg',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                drink.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3436),
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                drink.brand,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF636E72),
                ),
              ),
              if (drink.servingSizes.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${drink.servingSizes.length} sizes available',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'energy_drink':
        return Icons.bolt;
      case 'energy_shot':
        return Icons.water_drop;
      case 'coffee_energy':
      case 'coffee':
        return Icons.coffee;
      case 'soda':
        return Icons.local_drink;
      case 'supplement':
        return Icons.medication;
      default:
        return Icons.circle;
    }
  }
}

class _ServingSizeCard extends StatelessWidget {
  final ServingSize size;
  final int baseCaffeine;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServingSizeCard({
    required this.size,
    required this.baseCaffeine,
    required this.isSelected,
    required this.onTap,
  });

  int get totalCaffeine => (baseCaffeine * size.caffeineMultiplier).round();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    size.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${size.volumeML} ml',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$totalCaffeine mg',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (size.caffeineMultiplier != 1.0)
                  Text(
                    '${(size.caffeineMultiplier * 100).toInt()}%',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}