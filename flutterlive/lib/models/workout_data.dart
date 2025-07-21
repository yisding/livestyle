class WorkoutData {
  final int weeklyWorkouts;
  final int totalMinutes;
  final int caloriesBurned;
  final List<Workout> recentWorkouts;
  
  const WorkoutData({
    required this.weeklyWorkouts,
    required this.totalMinutes,
    required this.caloriesBurned,
    required this.recentWorkouts,
  });
}

class Workout {
  final String name;
  final String duration;
  final int caloriesBurned;
  final String date;
  
  const Workout({
    required this.name,
    required this.duration,
    required this.caloriesBurned,
    required this.date,
  });
}