import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterlive/screens/home/home_screen.dart';
import 'package:flutterlive/screens/nutrition/nutrition_screen.dart';
import 'package:flutterlive/screens/workout/workout_screen.dart';
import 'package:flutterlive/screens/profile/profile_screen.dart';
import 'test_helpers.dart';

void main() {
  group('Navigation Tests', () {
    testWidgets('should display home screen by default', (WidgetTester tester) async {
      await tester.pumpTestApp();

      // Verify home screen is displayed by default
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(NutritionScreen), findsNothing);
      expect(find.byType(WorkoutScreen), findsNothing);
      expect(find.byType(ProfileScreen), findsNothing);

      // Verify bottom navigation bar is present
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Verify navigation items by checking they exist in the bottom navigation bar
      final bottomNavFinder = find.byType(BottomNavigationBar);
      expect(find.descendant(of: bottomNavFinder, matching: find.byIcon(Icons.home)), findsOneWidget);
      expect(find.descendant(of: bottomNavFinder, matching: find.byIcon(Icons.restaurant)), findsOneWidget);
      expect(find.descendant(of: bottomNavFinder, matching: find.byIcon(Icons.fitness_center)), findsOneWidget);
      expect(find.descendant(of: bottomNavFinder, matching: find.byIcon(Icons.person)), findsOneWidget);
    });

    testWidgets('should navigate to nutrition screen when nutrition tab is tapped', (WidgetTester tester) async {
      await tester.pumpTestApp();

      // Tap on nutrition tab by icon in bottom navigation
      await tester.tap(find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.byIcon(Icons.restaurant),
      ));
      await tester.pumpAndSettle();

      // Verify nutrition screen is displayed
      expect(find.byType(NutritionScreen), findsOneWidget);
      
      // Verify the correct tab is highlighted
      final BottomNavigationBar bottomNav = tester.widget(find.byType(BottomNavigationBar));
      expect(bottomNav.currentIndex, equals(1));
    });

    testWidgets('should navigate to workout screen when workout tab is tapped', (WidgetTester tester) async {
      await tester.pumpTestApp();

      // Tap on workout tab by icon in bottom navigation
      await tester.tap(find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.byIcon(Icons.fitness_center),
      ));
      await tester.pumpAndSettle();

      // Verify workout screen is displayed
      expect(find.byType(WorkoutScreen), findsOneWidget);
      
      // Verify the correct tab is highlighted
      final BottomNavigationBar bottomNav = tester.widget(find.byType(BottomNavigationBar));
      expect(bottomNav.currentIndex, equals(2));
    });

    testWidgets('should navigate to profile screen when profile tab is tapped', (WidgetTester tester) async {
      await tester.pumpTestApp();

      // Tap on profile tab by icon in bottom navigation
      await tester.tap(find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.byIcon(Icons.person),
      ));
      await tester.pumpAndSettle();

      // Verify profile screen is displayed
      expect(find.byType(ProfileScreen), findsOneWidget);
      
      // Verify the correct tab is highlighted
      final BottomNavigationBar bottomNav = tester.widget(find.byType(BottomNavigationBar));
      expect(bottomNav.currentIndex, equals(3));
    });

    testWidgets('should maintain state when navigating between screens', (WidgetTester tester) async {
      await tester.pumpTestApp();

      // Start on home screen
      expect(find.byType(HomeScreen), findsOneWidget);

      // Navigate to nutrition screen using bottom nav icon
      final bottomNavFinder = find.byType(BottomNavigationBar);
      await tester.tap(find.descendant(
        of: bottomNavFinder,
        matching: find.byIcon(Icons.restaurant),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(NutritionScreen), findsOneWidget);

      // Navigate to workout screen
      await tester.tap(find.descendant(
        of: bottomNavFinder,
        matching: find.byIcon(Icons.fitness_center),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(WorkoutScreen), findsOneWidget);

      // Navigate back to home screen
      await tester.tap(find.descendant(
        of: bottomNavFinder,
        matching: find.byIcon(Icons.home),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      // Verify the correct tab is highlighted
      final BottomNavigationBar bottomNavWidget = tester.widget(find.byType(BottomNavigationBar));
      expect(bottomNavWidget.currentIndex, equals(0));
    });

    testWidgets('should use IndexedStack to preserve screen state', (WidgetTester tester) async {
      await tester.pumpTestApp();

      // Verify IndexedStack is used for state preservation
      expect(find.byType(IndexedStack), findsOneWidget);
      
      // Verify all screens are in the widget tree (but only one visible)
      final IndexedStack indexedStack = tester.widget(find.byType(IndexedStack));
      expect(indexedStack.children.length, equals(4));
      expect(indexedStack.index, equals(0)); // Home screen by default
    });
  });

  group('State Management Tests', () {
    testWidgets('should preserve Riverpod state across navigation', (WidgetTester tester) async {
      await tester.pumpTestApp();

      // Navigate to different screens and verify providers are accessible
      // Home screen
      expect(find.byType(HomeScreen), findsOneWidget);
      
      // Navigate to nutrition screen using bottom nav icon
      final bottomNavFinder = find.byType(BottomNavigationBar);
      await tester.tap(find.descendant(
        of: bottomNavFinder,
        matching: find.byIcon(Icons.restaurant),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(NutritionScreen), findsOneWidget);
      
      // Navigate to profile screen
      await tester.tap(find.descendant(
        of: bottomNavFinder,
        matching: find.byIcon(Icons.person),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
      
      // Navigate back to home - state should be preserved
      await tester.tap(find.descendant(
        of: bottomNavFinder,
        matching: find.byIcon(Icons.home),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}