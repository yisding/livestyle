import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for notifications setting
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

class SettingsSection extends ConsumerWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Settings section header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0E1A13),
            ),
          ),
        ),
        
        // Notifications setting with toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0E1A13),
                  ),
                ),
              ),
              Switch(
                value: notificationsEnabled,
                onChanged: (value) {
                  ref.read(notificationsEnabledProvider.notifier).state = value;
                },
                activeColor: const Color(0xFF38E07B),
                activeTrackColor: const Color(0xFF38E07B),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFE8F2EC),
              ),
            ],
          ),
        ),
        
        // App Preferences setting
        _buildSettingsItem(
          'App Preferences',
          onTap: () {
            // TODO: Navigate to app preferences screen
            _showComingSoonDialog(context, 'App Preferences');
          },
        ),
        
        // Account Management setting
        _buildSettingsItem(
          'Account Management',
          onTap: () {
            // TODO: Navigate to account management screen
            _showComingSoonDialog(context, 'Account Management');
          },
        ),
        
        // Additional settings items
        _buildSettingsItem(
          'Privacy & Security',
          onTap: () {
            _showComingSoonDialog(context, 'Privacy & Security');
          },
        ),
        
        _buildSettingsItem(
          'Help & Support',
          onTap: () {
            _showComingSoonDialog(context, 'Help & Support');
          },
        ),
        
        _buildSettingsItem(
          'About',
          onTap: () {
            _showAboutDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildSettingsItem(String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF0E1A13),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF0E1A13),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(feature),
          content: Text('$feature is coming soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF51946C)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About LiveStyle'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('LiveStyle - AI-Powered Health & Fitness'),
              SizedBox(height: 8),
              Text('Version 1.0.0'),
              SizedBox(height: 8),
              Text('Your personal AI coaches for nutrition, fitness, and mental well-being.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF51946C)),
              ),
            ),
          ],
        );
      },
    );
  }
}