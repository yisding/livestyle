class NutritionData {
  final int calorieGoal;
  final int caloriesConsumed;
  final int proteinGrams;
  final int carbGrams;
  final int fatGrams;
  final List<Meal> meals;
  
  const NutritionData({
    required this.calorieGoal,
    required this.caloriesConsumed,
    required this.proteinGrams,
    required this.carbGrams,
    required this.fatGrams,
    required this.meals,
  });
}

class Meal {
  final String name;
  final String imageUrl;
  final int calories;
  final String time;
  
  const Meal({
    required this.name,
    required this.imageUrl,
    required this.calories,
    required this.time,
  });
}