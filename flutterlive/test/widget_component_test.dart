import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterlive/widgets/metrics_row.dart';
import 'package:flutterlive/widgets/nutrition_summary.dart';
import 'package:flutterlive/widgets/macronutrient_breakdown.dart';
import 'test_helpers.dart';

void main() {
  group('Widget Component Tests', () {
    testWidgets('MetricsRow should display health metrics from provider', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        home: const Scaffold(
          body: MetricsRow(),
        ),
      ));

      // Verify metrics from provider are displayed
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('BMI'), findsOneWidget);
      expect(find.text('Body Fat'), findsOneWidget);
      
      // Verify actual values from provider (using test data)
      expect(find.text('70.0 kg'), findsOneWidget);
      expect(find.text('23.5'), findsOneWidget);
      expect(find.text('20.0%'), findsOneWidget);
    });



    testWidgets('NutritionSummary should display calorie information', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        home: const Scaffold(
          body: NutritionSummary(),
        ),
      ));

      // Verify calorie information is displayed
      expect(find.text('Daily Calories'), findsOneWidget);
      // Just verify the widget renders without checking specific values
      expect(find.byType(NutritionSummary), findsOneWidget);
    });

    testWidgets('MacronutrientBreakdown should display macros', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        home: const Scaffold(
          body: MacronutrientBreakdown(),
        ),
      ));

      // Verify macronutrient information is displayed
      expect(find.text('Protein'), findsAtLeastNWidgets(1));
      expect(find.text('Carbs'), findsAtLeastNWidgets(1));
      expect(find.text('Fat'), findsAtLeastNWidgets(1));
      
      // Just verify the widget renders
      expect(find.byType(MacronutrientBreakdown), findsOneWidget);
    });
  });

  group('Provider Tests', () {
    testWidgets('should provide consistent data across widgets', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        home: const Scaffold(
          body: Column(
            children: [
              NutritionSummary(),
              MacronutrientBreakdown(),
            ],
          ),
        ),
      ));

      // Verify both widgets can access provider data
      expect(find.text('Daily Calories'), findsOneWidget);
      expect(find.text('Protein'), findsAtLeastNWidgets(1));
      expect(find.text('Carbs'), findsAtLeastNWidgets(1));
      expect(find.text('Fat'), findsAtLeastNWidgets(1));
    });
  });

  group('Layout Tests', () {
    testWidgets('widgets should handle different screen sizes', (WidgetTester tester) async {
      // Test with small screen
      await tester.binding.setSurfaceSize(const Size(320, 568));
      
      await tester.pumpWidget(createTestApp(
        home: const Scaffold(
          body: MetricsRow(),
        ),
      ));

      // Verify widget renders without overflow
      expect(find.text('Weight'), findsOneWidget);
      
      // Test with larger screen
      await tester.binding.setSurfaceSize(const Size(768, 1024));
      await tester.pump();
      
      // Should still render correctly
      expect(find.text('Weight'), findsOneWidget);
    });

    testWidgets('should render widgets without exceptions', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        home: const Scaffold(
          body: Column(
            children: [
              MetricsRow(),
              NutritionSummary(),
              MacronutrientBreakdown(),
            ],
          ),
        ),
      ));

      // Verify all widgets render
      expect(find.byType(MetricsRow), findsOneWidget);
      expect(find.byType(NutritionSummary), findsOneWidget);
      expect(find.byType(MacronutrientBreakdown), findsOneWidget);
    });
  });
}