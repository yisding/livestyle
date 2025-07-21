import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/health_metric.dart';

final healthMetricsProvider = Provider<List<HealthMetric>>((ref) {
  return const [
    HealthMetric(
      name: 'Weight',
      value: '142 lbs',
      change: '-2.3 lbs',
      isPositiveChange: true,
    ),
    HealthMetric(
      name: 'BMI',
      value: '23.1',
      change: '-0.4',
      isPositiveChange: true,
    ),
    HealthMetric(
      name: 'Body Fat',
      value: '22.5%',
      change: '-1.2%',
      isPositiveChange: true,
    ),
  ];
});