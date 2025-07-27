class CoachAdvice {
  final String id;
  final String coachType; // "nutritionist", "trainer", "therapist"
  final String title;
  final String description;
  final String imageUrl;
  final String timestamp;
  
  const CoachAdvice({
    required this.id,
    required this.coachType,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.timestamp,
  });
}