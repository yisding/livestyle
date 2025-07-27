import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock progress data provider
final progressDataProvider = Provider<List<ProgressPoint>>((ref) {
  return [
    ProgressPoint(date: DateTime.now().subtract(const Duration(days: 30)), weight: 70.0),
    ProgressPoint(date: DateTime.now().subtract(const Duration(days: 25)), weight: 69.5),
    ProgressPoint(date: DateTime.now().subtract(const Duration(days: 20)), weight: 68.8),
    ProgressPoint(date: DateTime.now().subtract(const Duration(days: 15)), weight: 68.2),
    ProgressPoint(date: DateTime.now().subtract(const Duration(days: 10)), weight: 67.5),
    ProgressPoint(date: DateTime.now().subtract(const Duration(days: 5)), weight: 66.8),
    ProgressPoint(date: DateTime.now(), weight: 65.0),
  ];
});

class ProgressPoint {
  final DateTime date;
  final double weight;

  ProgressPoint({required this.date, required this.weight});
}

class ProgressChart extends ConsumerWidget {
  const ProgressChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressData = ref.watch(progressDataProvider);
    
    if (progressData.isEmpty) {
      return const SizedBox.shrink();
    }

    final startWeight = progressData.first.weight;
    final currentWeight = progressData.last.weight;
    final weightLoss = startWeight - currentWeight;
    final progressPercentage = (weightLoss / 5.0).clamp(0.0, 1.0); // Assuming 5kg goal

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Text(
            'Weight Loss Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0E1A13),
            ),
          ),
          const SizedBox(height: 16),
          
          // Progress stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Start Weight', '${startWeight.toStringAsFixed(1)} kg'),
              _buildStatItem('Current Weight', '${currentWeight.toStringAsFixed(1)} kg'),
              _buildStatItem('Lost', '${weightLoss.toStringAsFixed(1)} kg'),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Goal Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0E1A13),
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progressPercentage,
                backgroundColor: const Color(0xFFE8F2EC),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF51946C)),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                '${(progressPercentage * 100).toStringAsFixed(0)}% of goal achieved',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF51946C),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Simple chart representation
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: SimpleChartPainter(progressData),
              size: const Size(double.infinity, 120),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0E1A13),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF51946C),
          ),
        ),
      ],
    );
  }
}

class SimpleChartPainter extends CustomPainter {
  final List<ProgressPoint> data;

  SimpleChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = const Color(0xFF51946C)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = const Color(0xFF51946C)
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Find min and max values for scaling
    final minWeight = data.map((p) => p.weight).reduce((a, b) => a < b ? a : b);
    final maxWeight = data.map((p) => p.weight).reduce((a, b) => a > b ? a : b);
    final weightRange = maxWeight - minWeight;
    
    if (weightRange == 0) return;

    // Draw the line chart
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i].weight - minWeight) / weightRange) * size.height;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      
      // Draw points
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}