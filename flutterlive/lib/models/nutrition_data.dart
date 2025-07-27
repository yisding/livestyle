class NutritionData {
  final int totalCalories;
  final int targetCalories;
  final int proteinGrams;
  final int carbGrams;
  final int fatGrams;
  final List<Meal> meals;
  
  // Additional properties for nutrition summary
  final int calorieGoal;
  final int caloriesConsumed;

  const NutritionData({
    required this.totalCalories,
    required this.targetCalories,
    required this.proteinGrams,
    required this.carbGrams,
    required this.fatGrams,
    required this.meals,
    required this.calorieGoal,
    required this.caloriesConsumed,
  });
}

class Meal {
  final String name;
  final String time;
  final int calories;
  final String imageUrl;

  const Meal({
    required this.name,
    required this.time,
    required this.calories,
    required this.imageUrl,
  });
}