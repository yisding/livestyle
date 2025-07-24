import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nutrition_provider.dart';

class NutritionSummary extends ConsumerWidget {
  const NutritionSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutritionData = ref.watch(nutritionProvider);
    final remainingCalories = nutritionData.calorieGoal - nutritionData.caloriesConsumed;
    final progressPercentage = nutritionData.caloriesConsumed / nutritionData.calorieGoal;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Calories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0E1A13),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCalorieInfo(
                context,
                'Goal',
                nutritionData.calorieGoal.toString(),
                const Color(0xFF51946C),
              ),
              _buildCalorieInfo(
                context,
                'Consumed',
                nutritionData.caloriesConsumed.toString(),
                const Color(0xFF0E1A13),
              ),
              _buildCalorieInfo(
                context,
                'Remaining',
                remainingCalories.toString(),
                remainingCalories > 0 ? const Color(0xFF51946C) : Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF0E1A13),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(progressPercentage * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF51946C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progressPercentage.clamp(0.0, 1.0),
                backgroundColor: const Color(0xFFE8F2EC),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF51946C)),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieInfo(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF0E1A13).withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}