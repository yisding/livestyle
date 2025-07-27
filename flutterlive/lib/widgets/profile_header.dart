import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../config/theme.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Row(
        children: [
          // Profile Image
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: user.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(user.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: user.imageUrl.isEmpty ? const Color(0xFFE8F2EC) : null,
            ),
            child: user.imageUrl.isEmpty
                ? const Icon(Icons.person, size: 64, color: Color(0xFF51946C))
                : null,
          ),
          const SizedBox(width: AppTheme.spacingMd),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.015,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  '${user.age}, ${user.height}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppTheme.primaryColor),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  'Goal: ${user.weightLossGoal}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppTheme.primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
