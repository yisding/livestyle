# LiveStyle Flutter App - Test Documentation

This document describes all 23 tests in the LiveStyle Flutter application test suite. The tests cover navigation, widget components, responsive layout, and state management functionality.

## Test Overview

- **Total Tests**: 23
- **Test Files**: 4
- **Status**: All tests passing ✅
- **Framework**: Flutter Test with Riverpod state management

## Test Files and Coverage

### 1. Navigation Tests (`navigation_test.dart`)
**8 tests** - Validates app navigation and state preservation

#### Navigation Tests Group (6 tests)
- **`should display home screen by default`**
  - Verifies the app starts on the HomeScreen
  - Checks that other screens are not visible initially
  - Validates bottom navigation bar presence and correct icons

- **`should navigate to nutrition screen when nutrition tab is tapped`**
  - Tests navigation to NutritionScreen via bottom navigation
  - Verifies correct tab highlighting (currentIndex = 1)
  - Uses descendant finder to avoid icon duplication issues

- **`should navigate to workout screen when workout tab is tapped`**
  - Tests navigation to WorkoutScreen via bottom navigation
  - Verifies correct tab highlighting (currentIndex = 2)
  - Ensures proper screen switching

- **`should navigate to profile screen when profile tab is tapped`**
  - Tests navigation to ProfileScreen via bottom navigation
  - Verifies correct tab highlighting (currentIndex = 3)
  - Validates profile screen display

- **`should maintain state when navigating between screens`**
  - Tests navigation flow: Home → Nutrition → Workout → Home
  - Verifies state preservation during navigation
  - Ensures correct tab highlighting throughout navigation

- **`should use IndexedStack to preserve screen state`**
  - Validates IndexedStack widget usage for state preservation
  - Checks that all 4 screens are present in widget tree
  - Verifies correct initial index (0 for home)

#### State Management Tests Group (2 tests)
- **`should preserve Riverpod state across navigation`**
  - Tests Riverpod provider state consistency during navigation
  - Navigates through multiple screens and back to home
  - Ensures provider data remains accessible

### 2. Main Screen Tests (`main_screen_test.dart`)
**6 tests** - Focuses on MainScreen navigation behavior and IndexedStack functionality

#### MainScreen Navigation Tests Group (3 tests)
- **`should have correct initial state`**
  - Verifies BottomNavigationBar and IndexedStack presence
  - Checks IndexedStack has 4 children (screens)
  - Validates initial index is 0 (home screen)

- **`should change IndexedStack index when navigation tabs are tapped`**
  - Tests IndexedStack index changes with navigation
  - Verifies synchronization between BottomNavigationBar.currentIndex and IndexedStack.index
  - Tests all 4 navigation tabs sequentially

- **`should have correct navigation bar items`**
  - Validates BottomNavigationBar has exactly 4 items
  - Checks correct labels: 'Home', 'Nutrition', 'Workout', 'Profile'
  - Ensures proper navigation structure

#### State Preservation Tests Group (3 tests)
- **`should preserve widget state using IndexedStack`**
  - Confirms IndexedStack maintains all 4 child widgets
  - Validates state preservation mechanism
  - Ensures all screens remain in memory

### 3. Widget Component Tests (`widget_component_test.dart`)
**6 tests** - Tests individual widget components and provider integration

#### Widget Component Tests Group (3 tests)
- **`MetricsRow should display health metrics from provider`**
  - Tests MetricsRow widget with health metrics data
  - Verifies display of Weight, BMI, and Body Fat metrics
  - Validates specific test values: '70.0 kg', '23.5', '20.0%'

- **`NutritionSummary should display calorie information`**
  - Tests NutritionSummary widget rendering
  - Verifies 'Daily Calories' text display
  - Ensures widget renders without errors

- **`MacronutrientBreakdown should display macros`**
  - Tests MacronutrientBreakdown widget
  - Verifies display of Protein, Carbs, and Fat information
  - Ensures proper macronutrient data rendering

#### Provider Tests Group (1 test)
- **`should provide consistent data across widgets`**
  - Tests provider data consistency across multiple widgets
  - Uses NutritionSummary and MacronutrientBreakdown together
  - Validates shared provider state

#### Layout Tests Group (2 tests)
- **`widgets should handle different screen sizes`**
  - Tests widget responsiveness on different screen sizes
  - Tests small screen (320x568) and large screen (768x1024)
  - Ensures no overflow or rendering issues

- **`should render widgets without exceptions`**
  - Tests multiple widgets rendering together
  - Combines MetricsRow, NutritionSummary, and MacronutrientBreakdown
  - Validates error-free rendering

### 4. Responsive Layout Tests (`responsive_layout_test.dart`)
**3 tests** - Validates app behavior across different screen sizes

#### Responsive Layout Tests Group (2 tests)
- **`should adapt to phone screen size`**
  - Tests app on phone dimensions (375x812 - iPhone X)
  - Verifies no overflow errors
  - Ensures BottomNavigationBar and IndexedStack presence

- **`should adapt to tablet screen size`**
  - Tests app on tablet dimensions (768x1024 - iPad)
  - Validates responsive behavior on larger screens
  - Checks core navigation components

- **`should handle small screen size without overflow`**
  - Tests app on small screen (320x568 - iPhone SE)
  - Ensures app remains functional on constrained screens
  - Validates layout integrity

- **`should handle wide screen size`**
  - Tests app on wide screen (1024x768 - landscape tablet)
  - Verifies landscape orientation support
  - Ensures navigation functionality

- **`should maintain navigation functionality across different screen sizes`**
  - Tests navigation consistency across screen size changes
  - Validates BottomNavigationBar functionality
  - Handles network image exceptions gracefully

#### Layout Component Tests Group (1 test)
- **`should use proper layout widgets for responsiveness`**
  - Validates proper use of Scaffold, IndexedStack, and BottomNavigationBar
  - Ensures correct widget hierarchy
  - Tests layout structure integrity

## Test Infrastructure

### Test Helpers (`test_helpers.dart`)
- **`createTestApp()`**: Creates properly configured test app with mocked providers
- **`WidgetTesterExtensions.pumpTestApp()`**: Simplified test setup with exception handling
- **Provider Overrides**: Mocks for all required providers (user, coach advice, nutrition, workout, health metrics)

### Mock Data
- **User Data**: Test user with basic profile information
- **Coach Advice**: 3 AI coaches (nutritionist, trainer, therapist) with sample advice
- **Nutrition Data**: Sample meals and macronutrient information
- **Workout Data**: Sample workout history and statistics
- **Health Metrics**: Weight, BMI, and body fat percentage data

### Network Image Handling
- **Empty URL Strategy**: Uses empty strings for image URLs in tests to avoid network requests
- **Fallback UI**: Widgets display placeholder icons when image URLs are empty
- **Exception Handling**: Network image exceptions are handled gracefully in tests

## Key Testing Strategies

1. **Provider Mocking**: All Riverpod providers are overridden with test data
2. **Widget Isolation**: Individual widgets tested in isolation with proper provider context
3. **Navigation Testing**: Uses descendant finders to avoid icon duplication issues
4. **State Preservation**: Validates IndexedStack usage for maintaining widget state
5. **Responsive Design**: Tests multiple screen sizes and orientations
6. **Error Handling**: Graceful handling of network image loading failures

## Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/navigation_test.dart

# Run with verbose output
flutter test --verbose
```

## Test Maintenance

- Tests use the `test_helpers.dart` for consistent setup
- Mock data is centralized in provider overrides
- Network image issues are handled at the widget level
- Tests are designed to be maintainable and readable

All tests pass successfully and provide comprehensive coverage of the LiveStyle app's core functionality.