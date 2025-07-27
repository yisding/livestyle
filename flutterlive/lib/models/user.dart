class User {
  final String id;
  final String name;
  final String imageUrl;
  final String age; // Changed to String to match test
  final String height;
  final String weightLossGoal;
  
  const User({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.age,
    required this.height,
    required this.weightLossGoal,
  });
}