import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/nutrition_data.dart';

final nutritionProvider = Provider<NutritionData>((ref) {
  return NutritionData(
    totalCalories: 1850,
    targetCalories: 2000,
    proteinGrams: 120,
    carbGrams: 180,
    fatGrams: 65,
    calorieGoal: 2000,
    caloriesConsumed: 1850,
    meals: [
      Meal(
        name: 'Oatmeal with Berries',
        time: '8:00 AM',
        calories: 350,
        imageUrl: 'https://images.unsplash.com/photo-1517686469429-8bdb88b9f907?w=60&h=60&fit=crop',
      ),
      Meal(
        name: 'Grilled Chicken Salad',
        time: '12:30 PM',
        calories: 450,
        imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=60&h=60&fit=crop',
      ),
      Meal(
        name: 'Salmon with Vegetables',
        time: '7:00 PM',
        calories: 550,
        imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=60&h=60&fit=crop',
      ),
    ],
  );
});