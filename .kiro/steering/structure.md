# LiveStyle Project Structure

## Root Directory
- **android/**: Android platform-specific code and configuration
- **ios/**: iOS platform-specific code and configuration
- **lib/**: Main Dart code for the application
- **macos/**: macOS platform-specific code and configuration
- **web/**: Web platform-specific code and configuration
- **windows/**: Windows platform-specific code and configuration
- **linux/**: Linux platform-specific code and configuration
- **test/**: Test files for the application
- **designs/**: Design assets and mockups

## Design Assets
- **designs/code/**: HTML mockups of UI screens
- **designs/*.png**: Design screenshots for reference

## Source Code Organization

### Current Structure
```
lib/
├── firebase_options.dart  # Firebase configuration
└── main.dart             # Application entry point
```

### Planned Structure (for implementation)
```
lib/
├── firebase_options.dart  # Firebase configuration
├── main.dart             # Application entry point
├── config/               # App configuration
├── models/               # Data models
├── screens/              # UI screens
│   ├── home/             # Home screen
│   ├── nutrition/        # Nutrition tracking screen
│   ├── workout/          # Workout tracking screen
│   └── profile/          # User profile screen
├── services/             # Business logic and services
│   ├── ai_coaches/       # AI coach implementations
│   ├── health_connect/   # Health data integration
│   └── image_analysis/   # Food image analysis
├── utils/                # Utility functions
└── widgets/              # Reusable UI components
```

## Architecture Guidelines

- Follow a clean architecture approach with separation of concerns
- Use provider or bloc pattern for state management
- Keep UI components separate from business logic
- Organize code by feature when possible
- Use dependency injection for service access

## Platform Support
- Android
- iOS
- Web
- macOS
