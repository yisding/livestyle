import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/coach_advice.dart';

class RecommendedWorkouts extends StatelessWidget {
  final List<CoachAdvice> trainerAdvice;

  const RecommendedWorkouts({
    super.key,
    required this.trainerAdvice,
  });

  @override
  Widget build(BuildContext context) {
    // Filter for trainer advice only
    final workoutRecommendations = trainerAdvice
        .where((advice) => advice.coachType == 'trainer')
        .toList();

    if (workoutRecommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          child: Text(
            'AI Trainer Recommendations',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: workoutRecommendations.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingMd),
          itemBuilder: (context, index) {
            final advice = workoutRecommendations[index];
            return _buildRecommendationCard(context, advice);
          },
        ),
        const SizedBox(height: AppTheme.spacingMd),
        // Add some suggested workout types
        _buildSuggestedWorkouts(context),
      ],
    );
  }

  Widget _buildRecommendationCard(BuildContext context, CoachAdvice advice) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              image: advice.imageUrl.isNotEmpty ? DecorationImage(
                image: NetworkImage(advice.imageUrl),
                fit: BoxFit.cover,
              ) : null,
              color: advice.imageUrl.isEmpty ? const Color(0xFFE8F2EC) : null,
            ),
            child: advice.imageUrl.isEmpty ? const Icon(
              Icons.psychology,
              size: 24,
              color: Color(0xFF51946C),
            ) : null,
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      color: AppTheme.primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: AppTheme.spacingXs),
                    Text(
                      'AI Trainer',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  advice.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  advice.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textColor.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedWorkouts(BuildContext context) {
    final suggestedWorkouts = [
      {
        'name': 'HIIT Cardio',
        'duration': '20 min',
        'calories': '300 kcal',
        'icon': Icons.local_fire_department,
        'difficulty': 'High',
      },
      {
        'name': 'Strength Training',
        'duration': '45 min',
        'calories': '350 kcal',
        'icon': Icons.fitness_center,
        'difficulty': 'Medium',
      },
      {
        'name': 'Yoga Flow',
        'duration': '30 min',
        'calories': '150 kcal',
        'icon': Icons.self_improvement,
        'difficulty': 'Low',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          child: Text(
            'Suggested Workouts',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: suggestedWorkouts.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingSm),
          itemBuilder: (context, index) {
            final workout = suggestedWorkouts[index];
            return _buildSuggestedWorkoutItem(context, workout);
          },
        ),
      ],
    );
  }

  Widget _buildSuggestedWorkoutItem(BuildContext context, Map<String, dynamic> workout) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
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
              workout['icon'] as IconData,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      workout['name'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSm,
                        vertical: AppTheme.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(workout['difficulty'] as String).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Text(
                        workout['difficulty'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getDifficultyColor(workout['difficulty'] as String),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  '${workout['duration']} · ${workout['calories']}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Icon(
            Icons.arrow_forward_ios,
            color: AppTheme.textColor.withValues(alpha: 0.4),
            size: 16,
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return AppTheme.primaryColor;
    }
  }
}