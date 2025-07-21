import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/nutrition_data.dart';

final nutritionProvider = Provider<NutritionData>((ref) {
  return const NutritionData(
    calorieGoal: 1800,
    caloriesConsumed: 1456,
    proteinGrams: 98,
    carbGrams: 145,
    fatGrams: 52,
    meals: [
      Meal(
        name: 'Greek Yogurt with Berries',
        imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=80&h=80&fit=crop',
        calories: 245,
        time: '8:30 AM',
      ),
      Meal(
        name: 'Grilled Chicken Salad',
        imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=80&h=80&fit=crop',
        calories: 420,
        time: '12:45 PM',
      ),
      Meal(
        name: 'Apple with Almond Butter',
        imageUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=80&h=80&fit=crop',
        calories: 195,
        time: '3:15 PM',
      ),
      Meal(
        name: 'Salmon with Quinoa',
        imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=80&h=80&fit=crop',
        calories: 596,
        time: '7:00 PM',
      ),
    ],
  );
});