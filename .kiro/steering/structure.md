# LiveStyle Project Structure

## Root Directory
- **flutterlive/**: Main Flutter application directory
- **designs/**: Design assets and HTML mockups with Tailwind CSS
- **.kiro/**: Kiro IDE configuration and steering files

## Flutter Project Structure (flutterlive/)
- **android/**: Android platform-specific code and configuration
- **ios/**: iOS platform-specific code and configuration  
- **macos/**: macOS platform-specific code and configuration
- **web/**: Web platform-specific code and configuration
- **windows/**: Windows platform-specific code and configuration
- **linux/**: Linux platform-specific code and configuration
- **lib/**: Main Dart source code
- **test/**: Test files for the application
- **assets/**: Static assets (fonts, images)

## Design Assets (designs/)
- **designs/code/**: HTML mockups of UI screens (home, nutrition, workout, profile, food-scanner)
- **designs/*.png**: Design screenshots for reference
- Uses Tailwind CSS and Manrope font family
- Color scheme: Primary green (#51946c), background (#f8fbfa), text (#0e1a13)

## Source Code Organization (lib/)

### Current Structure
```
lib/
├── firebase_options.dart     # Firebase configuration
├── main.dart                # Application entry point with Firebase & MCP initialization
├── config/
│   └── theme.dart           # App theme with Material Design 3
├── models/                  # Data models
│   ├── coach_advice.dart
│   ├── health_metric.dart
│   ├── nutrition_data.dart
│   ├── user.dart
│   └── workout_data.dart
├── providers/               # Riverpod state providers
│   ├── coach_advice_provider.dart
│   ├── health_metrics_provider.dart
│   ├── nutrition_provider.dart
│   ├── user_provider.dart
│   └── workout_provider.dart
├── screens/                 # UI screens organized by feature
│   ├── home/
│   │   └── home_screen.dart
│   ├── nutrition/
│   │   └── nutrition_screen.dart
│   ├── workout/
│   │   └── workout_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   └── food_scanner/
│       └── food_scanner_screen.dart
├── services/                # Business logic and services (empty, ready for implementation)
├── utils/                   # Utility functions and helpers (empty, ready for implementation)
└── widgets/                 # Reusable UI components
    ├── analysis_results.dart
    ├── camera_view.dart
    ├── coach_advice_card.dart
    ├── confirmation_buttons.dart
    ├── macronutrient_breakdown.dart
    ├── meal_list.dart
    ├── metrics_row.dart
    ├── nutrition_summary.dart
    ├── profile_header.dart
    ├── progress_chart.dart
    ├── recommended_workouts.dart
    ├── scan_button.dart
    ├── settings_section.dart
    ├── user_details.dart
    ├── workout_history.dart
    └── workout_summary.dart
```

## Architecture Guidelines

- **Clean Architecture**: Separate UI, business logic, and data layers
- **State Management**: Use Riverpod for state management (flutter_riverpod ^2.6.1)
- **Feature-Based Organization**: Group related files by feature/screen
- **Material Design 3**: Follow Material Design 3 principles with custom theme
- **Firebase Integration**: Centralize Firebase services and AI model access
- **MCP Integration**: Use MCP toolkit for enhanced debugging and inspection
- **Error Handling**: Implement proper error handling with zone guards for AI services
- **Platform Channels**: Ready for Health Connect/Apple Health integration

## Navigation Structure
Bottom navigation with 4 main tabs implemented in MainScreen:
1. **Home**: User stats and AI coach recommendations
2. **Nutrition**: Food logging with camera scanning
3. **Workout**: Exercise tracking and history
4. **Profile**: User settings and personal information

## Testing Structure
- **test/**: Contains comprehensive test suite
- **test/mocks/**: Mock implementations for testing
- **TEST_DOCUMENTATION.md**: Testing guidelines and documentation
- Test categories: main screen, navigation, responsive layout, widget components

## Platform Support
- **Primary**: Android, iOS
- **Secondary**: Web, macOS
- **Future**: Windows, Linux

## Key Conventions
- Use const constructors where possible
- Follow flutter_lints rules
- Organize widgets by feature/screen
- Use Manrope font family consistently
- Implement proper error boundaries with MCP error handling
- Use IndexedStack for bottom navigation to preserve state