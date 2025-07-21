import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/health_metric.dart';
import '../providers/health_metrics_provider.dart';
import '../config/theme.dart';

class MetricsRow extends ConsumerWidget {
  const MetricsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(healthMetricsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: Row(
        children: metrics.map((metric) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXs),
            child: _MetricCard(metric: metric),
          ),
        )).toList(),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final HealthMetric metric;

  const _MetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: const Color(0xFFD1E6D9), // Light green border from design
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            metric.name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            metric.value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            metric.change,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: metric.isPositiveChange 
                ? const Color(0xFFE72A08) // Red color for weight loss (positive change)
                : AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}