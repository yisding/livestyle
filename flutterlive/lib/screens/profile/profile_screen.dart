import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/user_details.dart';
import '../../widgets/progress_chart.dart';
import '../../widgets/settings_section.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FBFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF0E1A13),
          ),
          onPressed: () {
            // TODO: Handle back navigation
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0E1A13),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User details section
            const UserDetails(),
            
            const SizedBox(height: 16),
            
            // Progress chart section
            const ProgressChart(),
            
            const SizedBox(height: 16),
            
            // Settings section
            const SettingsSection(),
            
            // Bottom padding for safe area
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}