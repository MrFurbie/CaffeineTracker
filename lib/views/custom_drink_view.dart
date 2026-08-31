import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drink.dart';
import '../services/drink_database_provider.dart';

class CustomDrinkView extends StatefulWidget {
  const CustomDrinkView({Key? key}) : super(key: key);

  @override
  State<CustomDrinkView> createState() => _CustomDrinkViewState();
}

class _CustomDrinkViewState extends State<CustomDrinkView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _caffeineController = TextEditingController();
  DrinkCategory? _selectedCategory;
  final List<_ServingSizeInput> _servingSizes = [];

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _caffeineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DrinkDatabaseProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Custom Drink'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  gradient: _isValid
                      ? const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                        )
                      : LinearGradient(
                          colors: [
                            const Color(0xFF6C63FF).withOpacity(0.3),
                            const Color(0xFF4CAF50).withOpacity(0.3),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: _isValid ? () => _saveCustomDrink(provider) : null,
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildBasicInformation(),
                const SizedBox(height: 24),
                _buildCaffeineContent(),
                const SizedBox(height: 24),
                _buildServingSizes(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBasicInformation() {
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
              ).createShader(bounds),
              child: const Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Drink Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a drink name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _brandController,
              decoration: InputDecoration(
                labelText: 'Brand',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a brand';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DrinkCategory>(
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              initialValue: _selectedCategory,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Select Category'),
                ),
                ...context.read<DrinkDatabaseProvider>().categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.name),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaffeineContent() {
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
              ).createShader(bounds),
              child: const Text(
                'Caffeine Content',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _caffeineController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Base Caffeine',
                      suffixText: 'mg',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter caffeine amount';
                      }
                      final caffeine = int.tryParse(value);
                      if (caffeine == null || caffeine <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServingSizes() {
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
              ).createShader(bounds),
              child: const Text(
                'Serving Sizes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_servingSizes.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.coffee,
                        size: 40,
                        color: const Color(0xFF6C63FF).withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No serving sizes added',
                        style: TextStyle(
                          color: Color(0xFF636E72),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._servingSizes.map((size) => _ServingSizeCard(
                size: size,
                onDelete: () {
                  setState(() {
                    _servingSizes.remove(size);
                  });
                },
              )),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton.icon(
                onPressed: () => _showAddServingSizeDialog(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add Serving Size',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _isValid {
    return _nameController.text.isNotEmpty &&
           _brandController.text.isNotEmpty &&
           _selectedCategory != null &&
           _caffeineController.text.isNotEmpty &&
           int.tryParse(_caffeineController.text)! > 0 &&
           _servingSizes.isNotEmpty;
  }

  void _saveCustomDrink(DrinkDatabaseProvider provider) {
    if (!_formKey.currentState!.validate()) return;

    final baseCaffeine = int.parse(_caffeineController.text);
    final servingSizes = _servingSizes.map((input) {
      return ServingSize(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: input.name,
        volumeML: int.parse(input.volumeML),
        caffeineMultiplier: double.parse(input.caffeineMultiplier),
      );
    }).toList();

    final customDrink = Drink(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      brand: _brandController.text,
      category: _selectedCategory!.id,
      baseCaffeine: baseCaffeine,
      servingSizes: servingSizes,
      icon: 'custom_icon',
      isCustom: true,
    );

    provider.addCustomDrink(customDrink);
    Navigator.pop(context);
  }

  void _showAddServingSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddServingSizeDialog(
        onAdd: (size) {
          setState(() {
            _servingSizes.add(size);
          });
        },
      ),
    );
  }
}

class _ServingSizeInput {
  final String id;
  String name;
  String volumeML;
  String caffeineMultiplier;

  _ServingSizeInput({
    required this.id,
    required this.name,
    required this.volumeML,
    required this.caffeineMultiplier,
  });
}

class _ServingSizeCard extends StatelessWidget {
  final _ServingSizeInput size;
  final VoidCallback onDelete;

  const _ServingSizeCard({
    required this.size,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF).withOpacity(0.05),
            const Color(0xFF4CAF50).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_cafe,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    size.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  Text(
                    '${size.volumeML} ml',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF636E72),
                    ),
                  ),
                  if (double.parse(size.caffeineMultiplier) != 1.0)
                    Text(
                      '${(double.parse(size.caffeineMultiplier) * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.delete, color: Color(0xFFFF6B6B)),
                onPressed: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddServingSizeDialog extends StatefulWidget {
  final Function(_ServingSizeInput) onAdd;

  const _AddServingSizeDialog({required this.onAdd});

  @override
  State<_AddServingSizeDialog> createState() => _AddServingSizeDialogState();
}

class _AddServingSizeDialogState extends State<_AddServingSizeDialog> {
  final _nameController = TextEditingController();
  final _volumeController = TextEditingController();
  final _multiplierController = TextEditingController(text: '1.0');

  @override
  void dispose() {
    _nameController.dispose();
    _volumeController.dispose();
    _multiplierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: const Text(
        'Add Serving Size',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF2D3436),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name (e.g., Can, Bottle)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FE),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _volumeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Volume',
                suffixText: 'ml',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FE),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _multiplierController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Caffeine Multiplier',
                suffixText: 'x',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FE),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Example: 2.0 for double the base caffeine',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Quick Multipliers',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((multiplier) {
                return FilterChip(
                  label: Text('${(multiplier * 100).toInt()}%'),
                  selected: false,
                  onSelected: (_) {
                    _multiplierController.text = multiplier.toString();
                  },
                  selectedColor: const Color(0xFF6C63FF),
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF636E72),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: _isValid
                ? const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                  )
                : LinearGradient(
                    colors: [
                      const Color(0xFF6C63FF).withOpacity(0.3),
                      const Color(0xFF4CAF50).withOpacity(0.3),
                    ],
                  ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton(
            onPressed: _isValid ? () => _addServingSize() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: const Text(
              'Add',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool get _isValid {
    return _nameController.text.isNotEmpty &&
           _volumeController.text.isNotEmpty &&
           int.tryParse(_volumeController.text)! > 0 &&
           double.tryParse(_multiplierController.text)! > 0;
  }

  void _addServingSize() {
    final size = _ServingSizeInput(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      volumeML: _volumeController.text,
      caffeineMultiplier: _multiplierController.text,
    );
    widget.onAdd(size);
    Navigator.pop(context);
  }
}