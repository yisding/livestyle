import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/nutrition_summary.dart';
import '../../widgets/macronutrient_breakdown.dart';
import '../../widgets/meal_list.dart';
import '../../widgets/scan_button.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FBFA),
        elevation: 0,
        title: Text(
          'Nutrition Log',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0E1A13),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Color(0xFF0E1A13),
          ),
          onPressed: () {
            // TODO: Implement menu functionality
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement add meal functionality
            },
            child: Text(
              'Add',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF51946C),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const NutritionSummary(),
            const SizedBox(height: 8),
            const MacronutrientBreakdown(),
            const SizedBox(height: 8),
            const MealList(),
            const SizedBox(height: 100), // Space for floating action button
          ],
        ),
      ),
      floatingActionButton: const ScanButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}