import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/consumption_record_adapter.dart';
import 'services/data_manager.dart';
import 'services/home_provider.dart';
import 'services/history_provider.dart';
import 'services/analytics_provider.dart';
import 'services/drink_database_provider.dart';
import 'views/home_view.dart';
import 'views/history_view.dart';
import 'views/analytics_view.dart';
import 'views/drink_database_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ConsumptionRecordAdapter());
  
  // Initialize DataManager
  await DataManager.init();
  
  runApp(const CaffeineTrackerApp());
}

class CaffeineTrackerApp extends StatelessWidget {
  const CaffeineTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => DrinkDatabaseProvider()),
      ],
      child: MaterialApp(
        title: 'Caffeine Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF8F9FE),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Color(0xFF2D3436),
          ),
          cardTheme: const CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            color: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3436),
              letterSpacing: -0.5,
            ),
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3436),
              letterSpacing: -0.3,
            ),
            headlineSmall: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF636E72),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D3436),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF636E72),
            ),
          ),
          navigationBarTheme: NavigationBarThemeData(
            elevation: 0,
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFF6C63FF).withOpacity(0.1),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6C63FF),
                );
              }
              return const TextStyle(
                fontWeight: FontWeight.w400,
                color: Color(0xFF636E72),
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(
                  color: Color(0xFF6C63FF),
                );
              }
              return const IconThemeData(
                color: Color(0xFF636E72),
              );
            }),
          ),
        ),
        home: const MainTabView(),
      ),
    );
  }
}

class MainTabView extends StatefulWidget {
  const MainTabView({Key? key}) : super(key: key);

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeView(),
    const HistoryView(),
    const AnalyticsView(),
    const DrinkDatabaseView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FE),
              Color(0xFFEEF2FF),
              Color(0xFFF8F9FE),
            ],
          ),
        ),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.calendar_today),
              label: 'Today',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart),
              label: 'Analytics',
            ),
            NavigationDestination(
              icon: Icon(Icons.list),
              label: 'Drinks',
            ),
          ],
        ),
      ),
    );
  }
}