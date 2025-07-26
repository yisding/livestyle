import 'package:flutter/material.dart';

enum AnalysisState {
  idle,
  analyzing,
  completed,
  error,
}

class FoodAnalysisResult {
  final String foodName;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double confidence;

  FoodAnalysisResult({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.confidence,
  });
}

class AnalysisResults extends StatelessWidget {
  final AnalysisState state;
  final FoodAnalysisResult? result;
  final String? errorMessage;

  const AnalysisResults({
    super.key,
    required this.state,
    this.result,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case AnalysisState.idle:
        return const SizedBox.shrink();
      
      case AnalysisState.analyzing:
        return _buildLoadingState();
      
      case AnalysisState.completed:
        return _buildResultsState();
      
      case AnalysisState.error:
        return _buildErrorState();
    }
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF51946c),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzing food...',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0e1a13),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we identify your food and calculate nutrition information.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              color: const Color(0xFF0e1a13).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsState() {
    if (result == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Food name and confidence
          Row(
            children: [
              Expanded(
                child: Text(
                  result!.foodName,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0e1a13),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConfidenceColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(result!.confidence * 100).toInt()}% confident',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getConfidenceColor(),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Calories
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF51946c).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Color(0xFF51946c),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${result!.calories} calories',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0e1a13),
                      ),
                    ),
                    Text(
                      'Estimated per serving',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        color: const Color(0xFF0e1a13).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Macronutrients
          Text(
            'Macronutrients',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0e1a13),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildMacroCard('Protein', '${result!.protein.toStringAsFixed(1)}g', const Color(0xFF38e07b)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroCard('Carbs', '${result!.carbs.toStringAsFixed(1)}g', const Color(0xFF51946c)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroCard('Fat', '${result!.fat.toStringAsFixed(1)}g', const Color(0xFF7cb342)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0e1a13).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[400],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Analysis Failed',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0e1a13),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Unable to analyze the food image. Please try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              color: const Color(0xFF0e1a13).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor() {
    if (result == null) return const Color(0xFF51946c);
    
    if (result!.confidence >= 0.8) {
      return const Color(0xFF38e07b); // High confidence - green
    } else if (result!.confidence >= 0.6) {
      return const Color(0xFF51946c); // Medium confidence - primary green
    } else {
      return Colors.orange; // Low confidence - orange
    }
  }
}