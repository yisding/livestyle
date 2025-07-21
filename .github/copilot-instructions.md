# LiveStyle AI Development Guide

## Project Overview

LiveStyle is a Flutter application focused on intensive lifestyle intervention for weight loss, featuring three AI coaches (nutritionist, personal trainer, psychotherapist) that provide personalized advice 3x daily. The app integrates with Health Connect/Apple Health and uses AI for food analysis and metabolic rate estimation.

## Architecture & Key Components

### Core App Structure
- **Main Flutter App**: `/flutterlive/` - Material Design 3 Flutter app with Firebase integration
- **Design References**: `/designs/` - HTML prototypes with Tailwind CSS showing target UI/UX
- **Firebase Project**: `nomadlander-livestyle` - configured for Android/iOS/web platforms

### Design System
- **Typography**: Manrope + Noto Sans font stack
- **Color Scheme**: Primary `#f8fbfa` (light green), accent `#38e07b` (bright green), text `#0e1a13` (dark green)
- **Layout**: Mobile-first with responsive breakpoints using container queries (`@container`)

### Key Screens (based on designs/)
1. **Home Screen** - User profile, daily stats, AI coach summaries
2. **Nutrition Log** - Food tracking with AI calorie estimation
3. **Food Scanner** - Camera integration for food photo analysis
4. **Profile** - User settings and progress tracking
5. **Workout** - Exercise tracking and AI trainer recommendations

## Development Patterns

### Flutter Project Structure
```
flutterlive/lib/
├── main.dart              # App entry point with Firebase initialization
├── firebase_options.dart  # Auto-generated Firebase configuration
└── [future structure]     # Organize by feature: screens/, services/, models/
```

### Firebase Integration
- **Project ID**: `nomadlander-livestyle`
- **Platforms**: Android, iOS, macOS, Web configured
- **Required Setup**: Firebase Core initialized in `main.dart` before `runApp()`

### UI Implementation Guidelines
- **Reference HTML Designs**: Use `/designs/code/*.html` as UI specification
- **Responsive Layout**: Implement `@container` query equivalents using Flutter's responsive widgets
- **Icon System**: Use SVG icons matching the design system (gear, camera, list, etc.)
- **Background Images**: Handle user profile photos and food images with proper aspect ratios

## AI Integration Points

### Data Flow Architecture
1. **Health Data Input** → Health Connect/Apple Health integration
2. **Food Photos** → OpenAI vision models for calorie/macro estimation  
3. **User Data** → AI coaches (nutritionist, trainer, therapist) for daily advice
4. **Weight Tracking** → BMR estimation and calorie deficit calculations

### Key AI Features to Implement
- Camera integration for food scanning (`food-scanner.html` reference)
- Health data aggregation from platform health APIs
- Daily AI coach advice synthesis (3x daily for each coach)
- Metabolic rate estimation based on food/weight/body fat data
- Workout optimization and plateau detection

## Development Workflow

### Build & Run Commands
```bash
cd flutterlive/
flutter pub get              # Install dependencies
flutter run                  # Run on connected device/emulator
flutter build android/ios    # Production builds
```

### Firebase Setup
- Firebase CLI configured for project `nomadlander-livestyle`
- Configuration files auto-generated in platform directories
- Use `firebase deploy` for cloud functions if implemented

### Design Implementation Process
1. Reference HTML designs in `/designs/code/` for pixel-perfect UI
2. Extract color values, typography, and spacing from Tailwind classes
3. Convert responsive `@container` queries to Flutter's layout widgets
4. Match icon styling using Flutter's SVG packages

## Critical Dependencies & Integration

### Current Dependencies (pubspec.yaml)
- `firebase_core: ^3.15.1` - Firebase initialization
- `cupertino_icons: ^1.0.8` - iOS-style icons
- `flutter_lints: ^5.0.0` - Code quality enforcement

### Required Future Integrations
- Health Connect (Android) / HealthKit (iOS) packages
- Camera/image picker for food scanning
- HTTP client for OpenAI API integration
- State management solution (Provider/Riverpod/Bloc)

## Project-Specific Conventions

### File Organization
- Keep design references in `/designs/` for UI specification
- Implement features in `/flutterlive/lib/` with clear separation of concerns
- Use Firebase project configuration as single source of truth

### AI Coach Implementation
- Structure for 3 distinct AI personalities (nutritionist, trainer, therapist)
- Daily advice generation (3x per day per coach)
- Data synthesis from health metrics, food logs, and user progress

### Health Data Privacy
- Implement proper health data permissions and privacy controls
- Ensure HIPAA compliance considerations for health data handling
- Secure API communication with OpenAI services

## Getting Started
1. Ensure Flutter SDK installed and configured
2. Run `cd flutterlive && flutter pub get` to install dependencies
3. Reference `/designs/code/` HTML files for UI implementation guidance
4. Test Firebase connection with existing initialization in `main.dart`
5. Implement screens incrementally, starting with home screen layout
