import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nutrition_provider.dart';
import '../models/nutrition_data.dart';

class MealList extends ConsumerWidget {
  const MealList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutritionData = ref.watch(nutritionProvider);
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Meals',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0E1A13),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to add meal screen
                  },
                  child: Text(
                    'Add',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF51946C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: nutritionData.meals.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: Color(0xFFE8F2EC),
              indent: 20,
              endIndent: 20,
            ),
            itemBuilder: (context, index) {
              final meal = nutritionData.meals[index];
              return _buildMealItem(context, meal);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMealItem(BuildContext context, Meal meal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              meal.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F2EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: Color(0xFF51946C),
                    size: 24,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0E1A13),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      meal.time,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF51946C),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF51946C),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${meal.calories} cal',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF0E1A13).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement meal deletion
              _showDeleteConfirmation(context, meal);
            },
            icon: const Icon(
              Icons.close,
              color: Color(0xFF0E1A13),
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Meal meal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Meal'),
          content: Text('Are you sure you want to delete "${meal.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement actual meal deletion logic
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${meal.name} deleted'),
                    backgroundColor: const Color(0xFF51946C),
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}