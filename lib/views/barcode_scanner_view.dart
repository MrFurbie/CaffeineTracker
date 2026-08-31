import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart' as handler;
import '../models/drink.dart';
import '../services/barcode_scanner_service.dart';
import '../services/open_food_facts_service.dart';
import '../services/home_provider.dart';
import '../services/drink_database_provider.dart';
import 'custom_drink_view.dart';

class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({Key? key}) : super(key: key);

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  final BarcodeScannerService _scannerService = BarcodeScannerService();
  final OpenFoodFactsService _openFoodFactsService = OpenFoodFactsService();
  
  bool _isScanning = false;
  bool _isLoading = false;
  bool _hasPermission = false;
  bool _isPermanentlyDenied = false;
  String? _errorMessage;
  Drink? _foundDrink;
  ServingSize? _selectedServingSize;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndStartScanner();
  }

  Future<void> _checkPermissionAndStartScanner() async {
    final hasPermission = await _scannerService.isCameraPermissionGranted();
    
    if (hasPermission) {
      setState(() {
        _hasPermission = true;
        _isScanning = true;
      });
    } else {
      await _requestPermission();
    }
  }

  Future<void> _requestPermission() async {
    final granted = await _scannerService.requestCameraPermission();
    
    if (granted) {
      setState(() {
        _hasPermission = true;
        _isScanning = true;
      });
    } else {
      final isPermanentlyDenied = await _scannerService.isCameraPermanentlyDenied();
      setState(() {
        _isPermanentlyDenied = isPermanentlyDenied;
        _hasPermission = false;
      });
    }
  }

  Future<void> _handleBarcodeCapture(BarcodeCapture capture) async {
    if (_isLoading || !_isScanning) return;

    final barcode = capture.barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() {
      _isScanning = false;
      _isLoading = true;
      _errorMessage = null;
    });

    final drink = await _openFoodFactsService.lookupProduct(barcode.rawValue!);

    setState(() {
      _isLoading = false;
      _foundDrink = drink;
      
      if (drink != null) {
        _selectedServingSize = drink.servingSizes.first;
      } else {
        _errorMessage = 'No caffeine information found for this product';
      }
    });
  }

  void _showServingSizeDialog() {
    if (_foundDrink == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_foundDrink!.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Size'),
            const SizedBox(height: 16),
            ..._foundDrink!.servingSizes.map((size) => _ServingSizeCard(
              size: size,
              baseCaffeine: _foundDrink!.baseCaffeine,
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
                    final drinkProvider = context.read<DrinkDatabaseProvider>();
                    
                    // Add the drink to custom drinks if not already there
                    drinkProvider.addCustomDrink(_foundDrink!);
                    
                    // Add consumption
                    homeProvider.addConsumption(_foundDrink!.id, _selectedServingSize!.id);
                    Navigator.pop(context); // Close serving size dialog
                    Navigator.pop(context); // Close scanner view
                  }
                : null,
            child: Text('Add ${_foundDrink!.name}'),
          ),
        ],
      ),
    );
  }

  void _navigateToCustomDrink() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CustomDrinkView()),
    );
  }

  void _resetScanner() {
    setState(() {
      _isScanning = true;
      _foundDrink = null;
      _selectedServingSize = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_foundDrink != null) {
      return _buildSuccessState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (!_hasPermission) {
      return _buildPermissionDeniedState();
    }

    return _buildScanner();
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(
          onDetect: _handleBarcodeCapture,
          controller: MobileScannerController(
            detectionSpeed: DetectionSpeed.normal,
            facing: CameraFacing.back,
          ),
        ),
        _buildScannerOverlay(),
      ],
    );
  }

  Widget _buildScannerOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF6C63FF),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 50,
                    color: Color(0xFF6C63FF),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Align barcode within frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
          ),
          SizedBox(height: 16),
          Text(
            'Looking up drink information...',
            style: TextStyle(fontSize: 16, color: Color(0xFF636E72)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8F9FE),
            Color(0xFFEEF2FF),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withValues(alpha:0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _foundDrink!.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3436),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _foundDrink!.brand,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF636E72),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_foundDrink!.baseCaffeine} mg per 100ml',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _resetScanner,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Scan Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: const Color(0xFF2D3436),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showServingSizeDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Drink'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8F9FE),
            Color(0xFFEEF2FF),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Color(0xFFFF6B6B),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Caffeine Information Found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3436),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'This product may not contain caffeine or data is unavailable.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF636E72),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _resetScanner,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Scan Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: const Color(0xFF2D3436),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _navigateToCustomDrink,
                    icon: const Icon(Icons.edit),
                    label: const Text('Add Manually'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8F9FE),
            Color(0xFFEEF2FF),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 80,
                  color: Color(0xFFFF6B6B),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Camera Permission Required',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3436),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _isPermanentlyDenied
                    ? 'Camera permission was permanently denied. Please enable it in app settings to use barcode scanning.'
                    : 'Camera permission is required to scan barcodes. Please grant permission to continue.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF636E72),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_isPermanentlyDenied)
                ElevatedButton.icon(
                  onPressed: () async {
                    final opened = await handler.openAppSettings();
                    if (opened) {
                      // Will need to check permission again when app returns
                    }
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Open Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: _requestPermission,
                  icon: const Icon(Icons.camera),
                  label: const Text('Grant Permission'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                  ),
                ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _navigateToCustomDrink,
                icon: const Icon(Icons.edit),
                label: const Text('Add Drink Manually'),
              ),
            ],
          ),
        ),
      ),
    );
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
        color: isSelected ? Colors.blue.withValues(alpha:0.1) : Colors.grey[100],
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