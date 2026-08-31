# Caffeine Tracker Flutter App

A cross-platform caffeine tracking app built with Flutter that helps you monitor your daily caffeine intake from energy drinks, coffee, and other caffeinated beverages.

## Features

- **Quick Entry**: Select drinks from a predefined database with serving sizes
- **Daily Tracking**: Visual progress indicator showing caffeine vs daily limit
- **History**: Browse past consumption with date range filtering
- **Analytics**: Key metrics including all-time highest, weekly records, and trends
- **Custom Drinks**: Add your own drinks with custom caffeine values
- **Data Persistence**: Local storage using Hive database

## Getting Started

### Prerequisites

1. **Install Flutter**: Download and install Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install)
2. **Install IDE**: VS Code, Android Studio, or IntelliJ IDEA with Flutter extension
3. **Set up Development Environment**:
   ```bash
   flutter doctor
   ```
   Follow the instructions to fix any issues

### Running the App

1. **Navigate to the project directory**:
   ```bash
   cd caffeine_tracker_flutter
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate code files** (for JSON serialization):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

   You can run on:
   - **Windows**: `flutter run -d windows`
   - **Android**: `flutter run -d android` (requires emulator or connected device)
   - **Web**: `flutter run -d chrome`
   - **iOS**: Requires Mac (not available on Windows)

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── drink.dart           # Drink, ServingSize, Category models
│   ├── consumption_record.dart # Consumption tracking
│   ├── analytics.dart       # Analytics data models
│   └── consumption_record_adapter.dart # Hive adapter
├── services/                 # Business logic
│   ├── data_manager.dart    # Local storage management
│   ├── drink_database_service.dart # Predefined drinks
│   ├── analytics_calculator.dart # Analytics calculations
│   ├── home_provider.dart   # Home screen state management
│   ├── history_provider.dart # History screen state management
│   ├── analytics_provider.dart # Analytics screen state management
│   └── drink_database_provider.dart # Drink database state management
├── views/                    # UI screens
│   ├── home_view.dart       # Today's tracking
│   ├── drink_selection_view.dart # Drink selection
│   ├── history_view.dart    # History browsing
│   ├── analytics_view.dart # Analytics display
│   └── drink_database_view.dart # Drink database browsing
└── widgets/                  # Reusable widgets
assets/
└── predefined_drinks.json    # Predefined drink database
```

## Key Technologies

- **Flutter**: Cross-platform UI framework
- **Provider**: State management
- **Hive**: Local NoSQL database
- **JSON Annotation**: Code generation for JSON serialization
- **Intl**: Date/time formatting

## Usage

1. **Add Drink**: Tap the + button to select a drink from the database
2. **Choose Size**: Select the appropriate serving size
3. **Track Progress**: View your daily caffeine intake with visual progress ring
4. **View History**: Browse past consumption with different date ranges
5. **Analyze**: Check analytics for trends and patterns

## Predefined Drinks

The app includes 23 popular drinks:
- Energy drinks (Red Bull, Monster, Rockstar, etc.)
- Energy shots (5-Hour Energy)
- Coffee-based energy drinks
- Coffee (various sizes)
- Soda (Diet Coke, Mountain Dew, etc.)
- Supplements (caffeine pills)

## Customization

- **Daily Limit**: Default is 400mg (configurable in settings)
- **Custom Drinks**: Add your own drinks with custom caffeine values
- **Multiple Serving Sizes**: Define different sizes for each drink

## Future Enhancements

- Cloud sync for data backup
- Widgets for quick entry
- Apple Watch/Android Wear integration
- Export to CSV/PDF
- Social sharing
- Notifications and reminders
- Sleep quality correlation

## Troubleshooting

### Build Issues
If you encounter build errors:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Hive Database Issues
If you experience database corruption:
- Delete the app data
- Reinstall the app
- The database will be recreated automatically

### Missing JSON File
Ensure `predefined_drinks.json` is in the `assets/` folder and referenced in `pubspec.yaml`

## License

This project is for personal use and educational purposes.

## Credits

Converted from original iOS SwiftUI design to Flutter cross-platform implementation.