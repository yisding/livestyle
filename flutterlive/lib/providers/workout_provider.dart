import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_data.dart';

final workoutProvider = Provider<WorkoutData>((ref) {
  return WorkoutData(
    totalWorkouts: 15,
    totalCaloriesBurned: 3450,
    averageDuration: 45,
    weeklyWorkouts: 5,
    totalMinutes: 225,
    caloriesBurned: 1200,
    recentWorkouts: [
      Workout(
        name: 'Morning Run',
        date: 'Today',
        duration: '30 min',
        caloriesBurned: 250,
        type: 'Cardio',
      ),
      Workout(
        name: 'Upper Body Strength',
        date: 'Yesterday',
        duration: '45 min',
        caloriesBurned: 180,
        type: 'Strength',
      ),
      Workout(
        name: 'Yoga Flow',
        date: '2 days ago',
        duration: '60 min',
        caloriesBurned: 120,
        type: 'Flexibility',
      ),
    ],
  );
});