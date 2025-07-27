# Implementation Plan

- [x] 1. Set up project structure and theme

  - Create directory structure for screens, widgets, models, and utils
  - Set up theme configuration with custom colors and typography
  - _Requirements: 7.1, 7.2, 7.3, 7.4_

- [x] 1.1 Configure app theme and typography

  - Add Manrope font to pubspec.yaml
  - Create theme configuration with primary colors and text styles
  - Implement custom theme data in MaterialApp
  - _Requirements: 7.1, 7.2_

- [x] 1.2 Create base navigation structure

  - Implement bottom navigation bar with four tabs
  - Create screen containers for each main section
  - Set up navigation state management
  - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [x] 2. Set up Riverpod state management and data models

  - Add flutter_riverpod dependency to pubspec.yaml
  - Configure ProviderScope in main.dart
  - Create model classes for User, HealthMetric, CoachAdvice, NutritionData, WorkoutData
  - Implement Riverpod providers with dummy data for initial development
  - _Requirements: 1.2, 1.3, 1.4, 3.2, 3.3, 5.2, 5.3, 5.4, 6.2_

- [x] 3. Implement Home Screen components and layout

  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 3.1 Create ProfileHeader widget

  - Implement user profile display with image, name, age, height, and weight loss goal
  - Add styling to match design mockup with proper spacing and typography
  - _Requirements: 1.2_

- [x] 3.2 Create MetricsRow widget

  - Implement health metrics cards displaying weight, BMI, and body fat percentage
  - Show current values and changes with proper styling
  - _Requirements: 1.3_

- [x] 3.3 Create CoachAdviceCard widget

  - Implement AI coach advice cards with coach image, title, and description
  - Support different coach types (nutritionist, trainer, therapist)
  - _Requirements: 1.4_

- [x] 3.4 Assemble complete HomeScreen

  - Combine ProfileHeader, MetricsRow, and CoachAdviceCard widgets
  - Implement proper scrolling and responsive layout
  - Connect with Riverpod providers using ConsumerWidget
  - _Requirements: 1.1, 7.4_

- [x] 4. Implement Nutrition Screen
  - _Requirements: 3.1, 3.2, 3.3, 3.4_
- [x] 4.1 Create NutritionSummary widget

  - Implement daily calorie goal and consumption display
  - Add styling to match design mockup
  - _Requirements: 3.2_

- [x] 4.2 Create MacronutrientBreakdown widget

  - Implement macronutrient distribution display
  - Add styling to match design mockup
  - _Requirements: 3.3_

- [x] 4.3 Create MealList widget

  - Implement list of meals with details
  - Add styling to match design mockup
  - _Requirements: 3.1_

- [x] 4.4 Create ScanButton widget

  - Implement floating action button for food scanning
  - Add navigation to food scanner screen
  - _Requirements: 3.4_

- [x] 4.5 Assemble NutritionScreen with components

  - Combine NutritionSummary, MacronutrientBreakdown, MealList, and ScanButton widgets
  - Connect with Riverpod nutrition providers using ConsumerWidget
  - Ensure responsive layout for different screen sizes
  - _Requirements: 3.1, 7.4_

- [x] 5. Implement Food Scanner Screen

  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 5.1 Create CameraView widget

  - Implement camera interface for capturing food images
  - Add styling to match design mockup
  - _Requirements: 4.2_

- [x] 5.2 Create AnalysisResults widget

  - Implement results display for food analysis
  - Add loading state and results presentation
  - _Requirements: 4.3, 4.4_

- [x] 5.3 Create ConfirmationButtons widget

  - Implement buttons for confirming or retaking images
  - Add styling to match design mockup
  - _Requirements: 4.4_

- [x] 5.4 Assemble FoodScannerScreen with components

  - Combine CameraView, AnalysisResults, and ConfirmationButtons widgets
  - Ensure responsive layout for different screen sizes
  - _Requirements: 4.1, 7.4_

- [x] 6. Implement Workout Screen

  - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [x] 6.1 Create WorkoutSummary widget

  - Implement workout statistics display
  - Add styling to match design mockup
  - _Requirements: 5.4_

- [x] 6.2 Create WorkoutHistory widget

  - Implement recent workout sessions display
  - Add styling to match design mockup
  - _Requirements: 5.2_

- [x] 6.3 Create RecommendedWorkouts widget

  - Implement AI trainer recommendations display
  - Add styling to match design mockup
  - _Requirements: 5.3_

- [x] 6.4 Assemble WorkoutScreen with components

  - Combine WorkoutSummary, WorkoutHistory, and RecommendedWorkouts widgets
  - Connect with Riverpod workout providers using ConsumerWidget
  - Ensure responsive layout for different screen sizes
  - _Requirements: 5.1, 7.4_

- [x] 7. Implement Profile Screen

  - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [x] 7.1 Create UserDetails widget

  - Implement user information display and editing
  - Add styling to match design mockup
  - _Requirements: 6.2_

- [x] 7.2 Create ProgressChart widget

  - Implement weight loss progress chart
  - Add styling to match design mockup
  - _Requirements: 6.4_

- [x] 7.3 Create SettingsSection widget

  - Implement settings options display
  - Add styling to match design mockup
  - _Requirements: 6.3_

- [x] 7.4 Assemble ProfileScreen with components

  - Combine UserDetails, ProgressChart, and SettingsSection widgets
  - Connect with Riverpod user and progress providers using ConsumerWidget
  - Ensure responsive layout for different screen sizes
  - _Requirements: 6.1, 7.4_

- [x] 8. Fix deprecation warnings and code quality issues

  - _Requirements: 7.3_

- [x] 8.1 Fix withOpacity deprecation warnings

  - Replace all instances of .withOpacity() with .withValues(alpha: value) throughout the codebase
  - Update widgets: analysis_results.dart, camera_view.dart, confirmation_buttons.dart, macronutrient_breakdown.dart, meal_list.dart, nutrition_summary.dart, progress_chart.dart
  - Update food_scanner_screen.dart
  - _Requirements: 7.3_

- [x] 8.2 Fix layout and code quality issues

  - Replace Container() with SizedBox() for whitespace in progress_chart.dart
  - Ensure all code follows Flutter linting rules
  - _Requirements: 7.3, 7.4_

- [x] 9. Integration and testing

  - _Requirements: 2.4, 7.3, 7.4_

- [x] 9.1 Test navigation and state management

  - Verify all screens navigate correctly through bottom navigation
  - Ensure proper Riverpod state preservation during navigation
  - Test state management across screen transitions
  - _Requirements: 2.4_

- [x] 9.2 Test responsive layouts

  - Verify UI components adapt to different screen sizes
  - Fix any layout issues or overflows
  - Test on different device sizes (phone, tablet)
  - _Requirements: 7.4_

- [x] 9.3 Perform widget tests
  - Write tests for key UI components
  - Verify navigation and Riverpod state management
  - Test provider behavior and state updates
  - _Requirements: 7.3_
