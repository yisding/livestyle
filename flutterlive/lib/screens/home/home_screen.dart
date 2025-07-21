import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/profile_header.dart';
import '../../widgets/metrics_row.dart';
import '../../widgets/coach_advice_card.dart';
import '../../providers/coach_advice_provider.dart';
import '../../config/theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachAdviceList = ref.watch(coachAdviceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            const ProfileHeader(),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            // Health Metrics Row
            const MetricsRow(),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Coach Advice Cards
            ...coachAdviceList.map((advice) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingLg),
              child: CoachAdviceCard(advice: advice),
            )),
            
            // Bottom padding for better scrolling experience
            const SizedBox(height: AppTheme.spacingXl),
          ],
        ),
      ),
    );
  }
}