import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_helpers.dart';

void main() {
  group('MainScreen Navigation Tests', () {
    testWidgets('should have correct initial state', (WidgetTester tester) async {
      await tester.pumpTestApp();

      // Verify bottom navigation bar exists
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Verify IndexedStack exists for state preservation
      expect(find.byType(IndexedStack), findsOneWidget);
      
      // Get the IndexedStack and verify it has 4 children
      final IndexedStack indexedStack = tester.widget(find.byType(IndexedStack));
      expect(indexedStack.children.length, equals(4));
      expect(indexedStack.index, equals(0)); // Should start at home (index 0)
    });

    testWidgets('should change IndexedStack index when navigation tabs are tapped', (WidgetTester tester) async {
      await tester.pumpTestApp();

      // Get initial state
      BottomNavigationBar bottomNav = tester.widget(find.byType(BottomNavigationBar));
      IndexedStack indexedStack = tester.widget(find.byType(IndexedStack));
      
      expect(bottomNav.currentIndex, equals(0));
      expect(indexedStack.index, equals(0));

      // Tap second tab (Nutrition) - tap on the bottom navigation bar specifically
      final bottomNavFinder = find.byType(BottomNavigationBar);
      await tester.tap(find.descendant(
        of: bottomNavFinder,
        matching: find.byIcon(Icons.restaurant),
      ));
      await tester.pump();

      // Verify state changed
      bottomNav = tester.widget(find.byType(BottomNavigationBar));
      indexedStack = tester.widget(find.byType(IndexedStack));
      
      expect(bottomNav.currentIndex, equals(1));
      expect(indexedStack.index, equals(1));

      // Tap third tab (Workout) - tap on the bottom navigation bar specifically
      await tester.tap(find.descendant(
        of: bottomNavFinder,
        matching: find.byIcon(Icons.fitness_center),
      ));
      await tester.pump();

      // Verify state changed
      bottomNav = tester.widget(find.byType(BottomNavigationBar));
      indexedStack = tester.widget(find.byType(IndexedStack));
      
      expect(bottomNav.currentIndex, equals(2));
      expect(indexedStack.index, equals(2));

      // Tap fourth tab (Profile) - tap on the bottom navigation bar specifically
      await tester.tap(find.descendant(
        of: bottomNavFinder,
        matching: find.byIcon(Icons.person),
      ));
      await tester.pump();

      // Verify state changed
      bottomNav = tester.widget(find.byType(BottomNavigationBar));
      indexedStack = tester.widget(find.byType(IndexedStack));
      
      expect(bottomNav.currentIndex, equals(3));
      expect(indexedStack.index, equals(3));

      // Go back to first tab (Home) - tap on the bottom navigation bar specifically
      await tester.tap(find.descendant(
        of: bottomNavFinder,
        matching: find.byIcon(Icons.home),
      ));
      await tester.pump();

      // Verify state changed back
      bottomNav = tester.widget(find.byType(BottomNavigationBar));
      indexedStack = tester.widget(find.byType(IndexedStack));
      
      expect(bottomNav.currentIndex, equals(0));
      expect(indexedStack.index, equals(0));
    });

    testWidgets('should have correct navigation bar items', (WidgetTester tester) async {
      await tester.pumpTestApp();

      final BottomNavigationBar bottomNav = tester.widget(find.byType(BottomNavigationBar));
      
      // Verify we have 4 navigation items
      expect(bottomNav.items.length, equals(4));
      
      // Verify the labels
      expect(bottomNav.items[0].label, equals('Home'));
      expect(bottomNav.items[1].label, equals('Nutrition'));
      expect(bottomNav.items[2].label, equals('Workout'));
      expect(bottomNav.items[3].label, equals('Profile'));
    });
  });

  group('State Preservation Tests', () {
    testWidgets('should preserve widget state using IndexedStack', (WidgetTester tester) async {
      await tester.pumpTestApp();

      // Verify IndexedStack preserves all children
      final IndexedStack indexedStack = tester.widget(find.byType(IndexedStack));
      expect(indexedStack.children.length, equals(4));
      
      // All children should be present in the widget tree even when not visible
      // This is the key feature of IndexedStack for state preservation
      expect(indexedStack.children[0], isNotNull); // HomeScreen
      expect(indexedStack.children[1], isNotNull); // NutritionScreen
      expect(indexedStack.children[2], isNotNull); // WorkoutScreen
      expect(indexedStack.children[3], isNotNull); // ProfileScreen
    });
  });
}