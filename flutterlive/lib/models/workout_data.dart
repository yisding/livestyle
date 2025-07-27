class WorkoutData {
  final int totalWorkouts;
  final int totalCaloriesBurned;
  final int averageDuration;
  final List<Workout> recentWorkouts;
  final int weeklyWorkouts;
  final int totalMinutes;
  final int caloriesBurned;

  const WorkoutData({
    required this.totalWorkouts,
    required this.totalCaloriesBurned,
    required this.averageDuration,
    required this.recentWorkouts,
    required this.weeklyWorkouts,
    required this.totalMinutes,
    required this.caloriesBurned,
  });
}

class Workout {
  final String name;
  final String date;
  final String duration;
  final int caloriesBurned;
  final String type;

  const Workout({
    required this.name,
    required this.date,
    required this.duration,
    required this.caloriesBurned,
    required this.type,
  });
}