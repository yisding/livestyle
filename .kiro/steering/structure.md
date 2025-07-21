# LiveStyle Project Structure

## Root Directory
- **flutterlive/**: Main Flutter application directory
- **designs/**: Design assets and HTML mockups
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

## Design Assets (designs/)
- **designs/code/**: HTML mockups of UI screens (home, nutrition, workout, profile)
- **designs/*.png**: Design screenshots for reference
- Uses Tailwind CSS and Manrope font family
- Color scheme: Primary green (#51946c), background (#f8fbfa), text (#0e1a13)

## Source Code Organization (lib/)

### Current Structure
```
lib/
├── firebase_options.dart  # Firebase configuration
└── main.dart             # Application entry point with Firebase initialization
```

### Recommended Structure for Implementation
```
lib/
├── firebase_options.dart  # Firebase configuration
├── main.dart             # Application entry point
├── config/               # App configuration and constants
├── models/               # Data models (user, nutrition, workout)
├── screens/              # UI screens
│   ├── home/             # Home screen with AI coach recommendations
│   ├── nutrition/        # Nutrition logging and food scanning
│   ├── workout/          # Workout tracking and history
│   └── profile/          # User profile and settings
├── services/             # Business logic and services
│   ├── ai_coaches/       # AI coach implementations (nutritionist, trainer, therapist)
│   ├── health_connect/   # Android Health Connect integration
│   ├── apple_health/     # Apple Health integration
│   └── food_analysis/    # Gemini-powered food image analysis
├── utils/                # Utility functions and helpers
└── widgets/              # Reusable UI components
```

## Architecture Guidelines

- **Clean Architecture**: Separate UI, business logic, and data layers
- **State Management**: Use Provider or Bloc pattern for state management
- **Feature-Based Organization**: Group related files by feature when the app grows
- **Material Design 3**: Follow Material Design 3 principles for UI consistency
- **Firebase Integration**: Centralize Firebase services and AI model access
- **Error Handling**: Implement proper error handling for AI services and health data
- **Platform Channels**: Use platform channels for Health Connect/Apple Health integration

## Platform Support
- **Primary**: Android, iOS
- **Secondary**: Web, macOS
- **Future**: Windows, Linux

## Navigation Structure
Bottom navigation with 4 main tabs:
1. **Home**: User stats and AI coach recommendations
2. **Nutrition**: Food logging with camera scanning
3. **Workout**: Exercise tracking and history
4. **Profile**: User settings and personal information
