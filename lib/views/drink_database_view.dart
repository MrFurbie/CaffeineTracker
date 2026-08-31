import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drink.dart';
import '../services/drink_database_provider.dart';
import 'custom_drink_view.dart';

class DrinkDatabaseView extends StatefulWidget {
  const DrinkDatabaseView({Key? key}) : super(key: key);

  @override
  State<DrinkDatabaseView> createState() => _DrinkDatabaseViewState();
}

class _DrinkDatabaseViewState extends State<DrinkDatabaseView> {
  String _searchQuery = '';
  DrinkCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DrinkDatabaseProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drink Database'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomDrinkView()),
                );
              },
            ),
          ),
        ],
      ),
      body: Consumer<DrinkDatabaseProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildSearchBar(),
              _buildCategoryFilter(provider),
              Expanded(
                child: _buildDrinkList(provider),
              ),
            ],
          );
        },
      ),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No drinks found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different search term or category',
              style: TextStyle(
                color: Color(0xFF636E72),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredDrinks.length,
      itemBuilder: (context, index) {
        final drink = filteredDrinks[index];
        return _DrinkDetailRow(drink: drink);
      },
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

class _DrinkDetailRow extends StatelessWidget {
  final Drink drink;

  const _DrinkDetailRow({required this.drink});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconForCategory(drink.category),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drink.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  Text(
                    drink.brand,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF636E72),
                    ),
                  ),
                  if (drink.servingSizes.length > 1)
                    Text(
                      '${drink.servingSizes.length} sizes available',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${drink.baseCaffeine} mg',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6C63FF),
                  ),
                ),
                if (drink.isCustom)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Custom',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
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