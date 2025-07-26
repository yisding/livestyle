import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/workout_data.dart';

class WorkoutSummary extends StatelessWidget {
  final WorkoutData workoutData;

  const WorkoutSummary({
    super.key,
    required this.workoutData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Workouts',
                  '${workoutData.weeklyWorkouts}',
                  Icons.fitness_center,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Minutes',
                  '${workoutData.totalMinutes}',
                  Icons.timer,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Calories',
                  '${workoutData.caloriesBurned}',
                  Icons.local_fire_department,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}