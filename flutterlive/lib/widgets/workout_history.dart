import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/workout_data.dart';

class WorkoutHistory extends StatelessWidget {
  final List<Workout> workouts;

  const WorkoutHistory({
    super.key,
    required this.workouts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          child: Text(
            'Past Workouts',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: workouts.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingSm),
          itemBuilder: (context, index) {
            final workout = workouts[index];
            return _buildWorkoutItem(context, workout);
          },
        ),
      ],
    );
  }

  Widget _buildWorkoutItem(BuildContext context, Workout workout) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              _getWorkoutIcon(workout.name),
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  '${workout.duration} · ${workout.caloriesBurned} kcal',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            workout.date,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWorkoutIcon(String workoutName) {
    final name = workoutName.toLowerCase();
    if (name.contains('run') || name.contains('jog')) {
      return Icons.directions_run;
    } else if (name.contains('strength') || name.contains('weight') || name.contains('lift')) {
      return Icons.fitness_center;
    } else if (name.contains('yoga') || name.contains('stretch')) {
      return Icons.self_improvement;
    } else if (name.contains('bike') || name.contains('cycle')) {
      return Icons.directions_bike;
    } else if (name.contains('swim')) {
      return Icons.pool;
    } else if (name.contains('hiit') || name.contains('cardio')) {
      return Icons.local_fire_department;
    } else {
      return Icons.fitness_center;
    }
  }
}