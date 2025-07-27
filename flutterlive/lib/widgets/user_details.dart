import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';

class UserDetails extends ConsumerWidget {
  const UserDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Column(
      children: [
        // Profile section with image and name
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile image
              Container(
                width: 128,
                height: 128,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE8F2EC),
                ),
                child: ClipOval(
                  child: Image.network(
                    user.imageUrl,
                    width: 128,
                    height: 128,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 128,
                        height: 128,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE8F2EC),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 64,
                          color: Color(0xFF51946C),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Name and membership status
              Column(
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0E1A13),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Premium Member',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF51946C),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Personal Information section
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0E1A13),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // Personal information items
        _buildInfoItem('Height', user.height),
        _buildInfoItem('Weight', '65 kg'), // TODO: Add weight to User model
        _buildInfoItem('Age', '${user.age} years'),
        _buildInfoItem('Fitness Goal', user.weightLossGoal),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0E1A13),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF51946C),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Color(0xFF0E1A13),
            size: 24,
          ),
        ],
      ),
    );
  }
}