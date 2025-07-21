import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coach_advice.dart';

final coachAdviceProvider = Provider<List<CoachAdvice>>((ref) {
  return const [
    CoachAdvice(
      coachType: 'nutritionist',
      title: 'Great progress on your calorie goals!',
      description: 'You\'ve been consistent with staying under your daily calorie target. Consider adding more protein to help with muscle recovery.',
      imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=60&h=60&fit=crop&crop=face',
    ),
    CoachAdvice(
      coachType: 'trainer',
      title: 'Time to increase workout intensity',
      description: 'Your body is adapting well to your current routine. Let\'s add 10 minutes to your cardio sessions this week.',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=60&h=60&fit=crop&crop=face',
    ),
    CoachAdvice(
      coachType: 'therapist',
      title: 'Mindful eating reminder',
      description: 'Remember to eat slowly and pay attention to hunger cues. This helps with portion control and digestion.',
      imageUrl: 'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=60&h=60&fit=crop&crop=face',
    ),
  ];
});