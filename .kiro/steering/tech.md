# LiveStyle Technical Stack

## Framework & Languages
- **Flutter**: Primary framework for cross-platform development
- **Dart**: Programming language used with Flutter
- **Firebase**: Backend services integration

## Dependencies
- **flutter**: Core Flutter framework
- **cupertino_icons**: ^1.0.8 - iOS style icons
- **firebase_core**: ^3.15.1 - Firebase integration
- **flutter_lints**: ^5.0.0 - Linting rules for code quality

## Development Environment
- **Dart SDK**: ^3.8.1
- **Flutter**: Latest stable channel recommended

## Build & Run Commands

### Setup
```bash
# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade
```

### Development
```bash
# Run in debug mode
flutter run

# Run on specific device
flutter run -d [device_id]

# Hot reload (when app is running)
r

# Hot restart (when app is running)
R
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart
```

### Building
```bash
# Build APK for Android
flutter build apk

# Build App Bundle for Android
flutter build appbundle

# Build for iOS
flutter build ios

# Build for web
flutter build web
```

## Firebase Configuration
- Firebase configuration files are included for Android, iOS, and macOS
- The app initializes Firebase in the main.dart file

## Code Style
- Follow the Flutter linting rules defined in analysis_options.yaml
- Use const constructors when possible
- Follow Material Design 3 guidelines for UI components