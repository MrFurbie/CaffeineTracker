// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:caffeine_tracker_flutter/main.dart';
import 'package:caffeine_tracker_flutter/models/consumption_record_adapter.dart';
import 'package:caffeine_tracker_flutter/services/data_manager.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize Hive for testing
    await Hive.initFlutter();
    Hive.registerAdapter(ConsumptionRecordAdapter());
    await DataManager.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const CaffeineTrackerApp());

    // Verify that the app starts with the main tab view
    expect(find.byType(MainTabView), findsOneWidget);
    
    // Verify that navigation bar is present
    expect(find.byType(NavigationBar), findsOneWidget);
    
    // Verify that the "Today" tab is selected (first tab)
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Drinks'), findsOneWidget);
  });
}
