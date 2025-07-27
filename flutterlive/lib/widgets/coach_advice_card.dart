import 'package:flutter/material.dart';
import '../models/coach_advice.dart';
import '../config/theme.dart';

class CoachAdviceCard extends StatelessWidget {
  final CoachAdvice advice;

  const CoachAdviceCard({
    super.key,
    required this.advice,
  });

  String get _coachDisplayName {
    switch (advice.coachType) {
      case 'nutritionist':
        return 'AI Nutritionist';
      case 'trainer':
        return 'AI Personal Trainer';
      case 'therapist':
        return 'AI Therapist';
      default:
        return 'AI Coach';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Coach Type Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          child: Text(
            _coachDisplayName,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.015,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        // Advice Card Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text Content
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personalized Advice',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      advice.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      advice.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              // Coach Image
              Expanded(
                flex: 1,
                child: AspectRatio(
                  aspectRatio: 16 / 9, // Video aspect ratio as shown in design
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      image: advice.imageUrl.isNotEmpty ? DecorationImage(
                        image: NetworkImage(advice.imageUrl),
                        fit: BoxFit.cover,
                      ) : null,
                      color: advice.imageUrl.isEmpty ? const Color(0xFFE8F2EC) : null,
                    ),
                    child: advice.imageUrl.isEmpty ? const Icon(
                      Icons.psychology,
                      size: 32,
                      color: Color(0xFF51946C),
                    ) : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}