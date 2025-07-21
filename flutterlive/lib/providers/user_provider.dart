import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';

final userProvider = Provider<User>((ref) {
  return const User(
    name: 'Sarah Johnson',
    imageUrl: 'https://images.unsplash.com/photo-1494790108755-2616b9e2b8b8?w=150&h=150&fit=crop&crop=face',
    age: 28,
    height: '5\'6"',
    weightLossGoal: 'Lose 15 lbs',
  );
});