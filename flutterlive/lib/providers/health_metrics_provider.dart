import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/health_metric.dart';

final healthMetricsProvider = Provider<List<HealthMetric>>((ref) {
  return [
    HealthMetric(
      name: 'Weight',
      value: '65.0 kg',
      change: '-2.5 kg',
      isPositiveChange: true, // Weight loss is positive
    ),
    HealthMetric(
      name: 'BMI',
      value: '22.1',
      change: '-0.8',
      isPositiveChange: true, // BMI reduction is positive
    ),
    HealthMetric(
      name: 'Body Fat',
      value: '18.5%',
      change: '-1.2%',
      isPositiveChange: true, // Body fat reduction is positive
    ),
  ];
});