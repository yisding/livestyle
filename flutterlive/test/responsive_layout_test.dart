import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_helpers.dart';

void main() {
  group('Responsive Layout Tests', () {
    testWidgets('should adapt to phone screen size', (WidgetTester tester) async {
      // Set phone screen size
      await tester.binding.setSurfaceSize(const Size(375, 812)); // iPhone X size
      
      await tester.pumpTestApp();

      // Verify the app renders without overflow
      expect(tester.takeException(), isNull);
      
      // Verify bottom navigation bar is present and properly sized
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Verify IndexedStack is present
      expect(find.byType(IndexedStack), findsOneWidget);
      
      // The main test is that the app renders without overflow on different screen sizes
    });

    testWidgets('should adapt to tablet screen size', (WidgetTester tester) async {
      // Set tablet screen size
      await tester.binding.setSurfaceSize(const Size(768, 1024)); // iPad size
      
      await tester.pumpTestApp();

      // Verify the app renders without overflow
      expect(tester.takeException(), isNull);
      
      // Verify bottom navigation bar is present and properly sized
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Verify IndexedStack is present
      expect(find.byType(IndexedStack), findsOneWidget);
      
      // The main test is that the app renders without overflow on different screen sizes
    });

    testWidgets('should handle small screen size without overflow', (WidgetTester tester) async {
      // Set small screen size
      await tester.binding.setSurfaceSize(const Size(320, 568)); // iPhone SE size
      
      await tester.pumpTestApp();

      // Verify the app renders without overflow
      expect(tester.takeException(), isNull);
      
      // Verify bottom navigation bar is present
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Verify IndexedStack is present
      expect(find.byType(IndexedStack), findsOneWidget);
    });

    testWidgets('should handle wide screen size', (WidgetTester tester) async {
      // Set wide screen size (landscape tablet)
      await tester.binding.setSurfaceSize(const Size(1024, 768));
      
      await tester.pumpTestApp();

      // Verify the app renders without overflow
      expect(tester.takeException(), isNull);
      
      // Verify bottom navigation bar is present
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Verify IndexedStack is present
      expect(find.byType(IndexedStack), findsOneWidget);
    });

    testWidgets('should maintain navigation functionality across different screen sizes', (WidgetTester tester) async {
      // Test on phone size
      await tester.binding.setSurfaceSize(const Size(375, 812));
      
      await tester.pumpTestApp();

      // Verify navigation works on phone
      BottomNavigationBar bottomNav = tester.widget(find.byType(BottomNavigationBar));
      expect(bottomNav.currentIndex, equals(0));

      // Change to tablet size
      await tester.binding.setSurfaceSize(const Size(768, 1024));
      await tester.pump();

      // Navigation should still work
      bottomNav = tester.widget(find.byType(BottomNavigationBar));
      expect(bottomNav.currentIndex, equals(0));
      
      // Verify no overflow errors (ignore network image exceptions in tests)
      final exception = tester.takeException();
      if (exception != null && exception.runtimeType.toString() != 'NetworkImageLoadException') {
        fail('Unexpected exception: $exception');
      }
    });
  });

  group('Layout Component Tests', () {
    testWidgets('should use proper layout widgets for responsiveness', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 812));
      
      await tester.pumpTestApp();

      // Verify main Scaffold is used for proper layout structure (there might be nested scaffolds in screens)
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
      
      // Verify IndexedStack is used for screen management
      expect(find.byType(IndexedStack), findsOneWidget);
      
      // Verify BottomNavigationBar is properly positioned
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Find the main scaffold (the one with the bottom navigation bar)
      final scaffolds = tester.widgetList<Scaffold>(find.byType(Scaffold));
      final mainScaffold = scaffolds.firstWhere((scaffold) => scaffold.bottomNavigationBar != null);
      expect(mainScaffold.body, isA<IndexedStack>());
      expect(mainScaffold.bottomNavigationBar, isA<BottomNavigationBar>());
    });
  });
}