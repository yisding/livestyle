class HealthMetric {
  final String name;
  final String value;
  final String change;
  final bool isPositiveChange;
  
  const HealthMetric({
    required this.name,
    required this.value,
    required this.change,
    required this.isPositiveChange,
  });
}