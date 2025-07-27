import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nutrition_provider.dart';

class MacronutrientBreakdown extends ConsumerWidget {
  const MacronutrientBreakdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutritionData = ref.watch(nutritionProvider);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Macronutrients',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0E1A13),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMacroCard(
                  context,
                  'Protein',
                  '${nutritionData.proteinGrams}g',
                  const Color(0xFF51946C),
                  Icons.fitness_center,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroCard(
                  context,
                  'Carbs',
                  '${nutritionData.carbGrams}g',
                  const Color(0xFF7FB069),
                  Icons.grain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroCard(
                  context,
                  'Fat',
                  '${nutritionData.fatGrams}g',
                  const Color(0xFFA8D5BA),
                  Icons.water_drop,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMacroProgressBars(context, nutritionData),
        ],
      ),
    );
  }

  Widget _buildMacroCard(BuildContext context, String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0E1A13),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF0E1A13).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroProgressBars(BuildContext context, nutritionData) {
    // Calculate total macros for percentage calculation
    final totalMacros = nutritionData.proteinGrams + nutritionData.carbGrams + nutritionData.fatGrams;
    final proteinPercentage = nutritionData.proteinGrams / totalMacros;
    final carbPercentage = nutritionData.carbGrams / totalMacros;
    final fatPercentage = nutritionData.fatGrams / totalMacros;

    return Column(
      children: [
        _buildProgressRow(
          context,
          'Protein',
          proteinPercentage,
          const Color(0xFF51946C),
          '${(proteinPercentage * 100).toInt()}%',
        ),
        const SizedBox(height: 8),
        _buildProgressRow(
          context,
          'Carbs',
          carbPercentage,
          const Color(0xFF7FB069),
          '${(carbPercentage * 100).toInt()}%',
        ),
        const SizedBox(height: 8),
        _buildProgressRow(
          context,
          'Fat',
          fatPercentage,
          const Color(0xFFA8D5BA),
          '${(fatPercentage * 100).toInt()}%',
        ),
      ],
    );
  }

  Widget _buildProgressRow(BuildContext context, String label, double percentage, Color color, String percentageText) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF0E1A13).withValues(alpha: 0.7),
            ),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: const Color(0xFFE8F2EC),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            percentageText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}