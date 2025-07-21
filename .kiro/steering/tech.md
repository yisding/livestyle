# LiveStyle Technical Stack

## Framework & Languages
- **Flutter**: Primary framework for cross-platform development (Android, iOS, Web, macOS)
- **Dart**: Programming language (SDK ^3.8.1)
- **Firebase**: Backend services integration with AI capabilities

## Dependencies
- **flutter**: Core Flutter framework
- **cupertino_icons**: ^1.0.8 - iOS style icons
- **firebase_core**: ^3.15.1 - Firebase integration
- **firebase_ai**: ^2.2.1 - Firebase AI services (Gemini 2.5 Pro)
- **flutter_lints**: ^5.0.0 - Linting rules for code quality

## AI Integration
- **Gemini 2.5 Pro**: Primary AI model for coaches and food analysis
- **Firebase AI**: Used for generative AI capabilities
- Three AI coaches: nutritionist, personal trainer, psychotherapist

## Build & Run Commands

### Setup
```bash
# Navigate to Flutter project
cd flutterlive

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

# Build for macOS
flutter build macos
```

## Firebase Configuration
- Firebase configuration files included for all platforms (Android, iOS, macOS, Web)
- Firebase initialized in main.dart with DefaultFirebaseOptions
- Google Services configuration files present for each platform

## Code Style & Standards
- Follow Flutter linting rules defined in analysis_options.yaml
- Use const constructors when possible
- Follow Material Design 3 guidelines for UI components
- Use Manrope font family for consistent typography
- Implement proper error handling for AI service calls