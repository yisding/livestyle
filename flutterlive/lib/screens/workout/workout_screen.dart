import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/workout_provider.dart';
import '../../providers/coach_advice_provider.dart';
import '../../widgets/workout_summary.dart';
import '../../widgets/workout_history.dart';
import '../../widgets/recommended_workouts.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutData = ref.watch(workoutProvider);
    final coachAdvice = ref.watch(coachAdviceProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Workout'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Add new workout functionality
            },
            icon: const Icon(Icons.add),
            color: AppTheme.textColor,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's workout section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
              child: Text(
                'Today',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            // Show today's workout if available
            if (workoutData.recentWorkouts.isNotEmpty && 
                workoutData.recentWorkouts.first.date == 'Today')
              Container(
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
                      child: const Icon(
                        Icons.directions_run,
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
                            workoutData.recentWorkouts.first.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingXs),
                          Text(
                            '${workoutData.recentWorkouts.first.duration} · ${workoutData.recentWorkouts.first.caloriesBurned} kcal',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Workout Summary
            WorkoutSummary(workoutData: workoutData),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Workout History
            WorkoutHistory(
              workouts: workoutData.recentWorkouts
                  .where((workout) => workout.date != 'Today')
                  .toList(),
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // AI Trainer Recommendations
            RecommendedWorkouts(trainerAdvice: coachAdvice),
            
            const SizedBox(height: AppTheme.spacingXl),
          ],
        ),
      ),
    );
  }
}