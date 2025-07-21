import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_data.dart';

final workoutProvider = Provider<WorkoutData>((ref) {
  return const WorkoutData(
    weeklyWorkouts: 5,
    totalMinutes: 240,
    caloriesBurned: 1850,
    recentWorkouts: [
      Workout(
        name: 'Morning Run',
        duration: '35 min',
        caloriesBurned: 420,
        date: 'Today',
      ),
      Workout(
        name: 'Strength Training',
        duration: '45 min',
        caloriesBurned: 380,
        date: 'Yesterday',
      ),
      Workout(
        name: 'Yoga Flow',
        duration: '30 min',
        caloriesBurned: 180,
        date: '2 days ago',
      ),
      Workout(
        name: 'HIIT Cardio',
        duration: '25 min',
        caloriesBurned: 350,
        date: '3 days ago',
      ),
    ],
  );
});