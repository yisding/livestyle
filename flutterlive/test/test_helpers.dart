import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterlive/main.dart';
import 'package:flutterlive/providers/user_provider.dart';
import 'package:flutterlive/providers/coach_advice_provider.dart';
import 'package:flutterlive/providers/nutrition_provider.dart';
import 'package:flutterlive/providers/workout_provider.dart';
import 'package:flutterlive/providers/health_metrics_provider.dart';
import 'package:flutterlive/widgets/progress_chart.dart';
import 'package:flutterlive/widgets/settings_section.dart';
import 'package:flutterlive/models/user.dart';
import 'package:flutterlive/models/coach_advice.dart';
import 'package:flutterlive/models/nutrition_data.dart';
import 'package:flutterlive/models/workout_data.dart';
import 'package:flutterlive/models/health_metric.dart';

/// Test helper to create a properly configured test app with mocked providers
Widget createTestApp({Widget? home}) {
  return ProviderScope(
    overrides: [
      // Override user provider with test data
      userProvider.overrideWith((ref) => const User(
        id: 'test-user',
        name: 'Test User',
        age: '25',
        height: '5\'10"',
        weightLossGoal: 'Lose 20 lbs',
        imageUrl: '', // Empty URL to avoid network requests in tests
      )),
      // Override coach advice provider with test data
      coachAdviceProvider.overrideWith((ref) => [
        const CoachAdvice(
          id: '1',
          coachType: 'nutritionist',
          title: 'Test Nutrition Advice',
          description: 'Test description',
          imageUrl: '', // Empty URL to avoid network requests in tests
          timestamp: '2 hours ago',
        ),
        const CoachAdvice(
          id: '2',
          coachType: 'trainer',
          title: 'Test Workout Advice',
          description: 'Test description',
          imageUrl: '', // Empty URL to avoid network requests in tests
          timestamp: '4 hours ago',
        ),
        const CoachAdvice(
          id: '3',
          coachType: 'therapist',
          title: 'Test Mental Health Advice',
          description: 'Test description',
          imageUrl: '', // Empty URL to avoid network requests in tests
          timestamp: '6 hours ago',
        ),
      ]),
      // Override nutrition provider with test data
      nutritionProvider.overrideWith((ref) => const NutritionData(
        totalCalories: 1200,
        targetCalories: 1500,
        proteinGrams: 80,
        carbGrams: 120,
        fatGrams: 40,
        calorieGoal: 1500,
        caloriesConsumed: 1200,
        meals: [
          Meal(
            name: 'Test Breakfast',
            time: '8:00 AM',
            calories: 400,
            imageUrl: '', // Empty URL to avoid network requests in tests
          ),
          Meal(
            name: 'Test Lunch',
            time: '12:00 PM',
            calories: 500,
            imageUrl: '', // Empty URL to avoid network requests in tests
          ),
          Meal(
            name: 'Test Dinner',
            time: '7:00 PM',
            calories: 300,
            imageUrl: '', // Empty URL to avoid network requests in tests
          ),
        ],
      )),
      // Override progress data provider with test data
      progressDataProvider.overrideWith((ref) => [
        ProgressPoint(date: DateTime.now().subtract(const Duration(days: 7)), weight: 70.0),
        ProgressPoint(date: DateTime.now(), weight: 68.0),
      ]),
      // Override notifications provider with test data
      notificationsEnabledProvider.overrideWith((ref) => true),
      // Override workout provider with test data
      workoutProvider.overrideWith((ref) => const WorkoutData(
        totalWorkouts: 10,
        totalCaloriesBurned: 2500,
        averageDuration: 40,
        weeklyWorkouts: 5,
        totalMinutes: 200,
        caloriesBurned: 1200,
        recentWorkouts: [
          Workout(
            name: 'Test Workout',
            date: 'Today',
            duration: '30 min',
            caloriesBurned: 200,
            type: 'Cardio',
          ),
        ],
      )),
      // Override health metrics provider with test data
      healthMetricsProvider.overrideWith((ref) => [
        const HealthMetric(
          name: 'Weight',
          value: '70.0 kg',
          change: '-1.0 kg',
          isPositiveChange: true,
        ),
        const HealthMetric(
          name: 'BMI',
          value: '23.5',
          change: '-0.5',
          isPositiveChange: true,
        ),
        const HealthMetric(
          name: 'Body Fat',
          value: '20.0%',
          change: '-1.0%',
          isPositiveChange: true,
        ),
      ]),
    ],
    child: MaterialApp(
      home: home ?? const MainScreen(),
    ),
  );
}

/// Extension to help with test setup
extension WidgetTesterExtensions on WidgetTester {
  /// Pump a widget with proper test setup and wait for settlement
  Future<void> pumpTestApp({Widget? home}) async {
    await pumpWidget(createTestApp(home: home));
    await pumpAndSettle();
    
    // Clear any network image exceptions that are expected in tests
    Exception? exception;
    do {
      exception = takeException();
    } while (exception != null && exception.toString().contains('NetworkImageLoadException'));
    
    // If there's a non-network exception, put it back
    if (exception != null && !exception.toString().contains('NetworkImageLoadException')) {
      // Re-throw the exception if it's not a network image exception
      throw exception;
    }
  }
}