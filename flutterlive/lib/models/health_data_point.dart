import 'package:cloud_firestore/cloud_firestore.dart';

/// Enumeration of supported health data types
enum HealthDataType {
  weight,
  bodyFatPercentage,
  bmi,
  steps,
  heartRate,
  workout,
  calories,
  sleep,
  bloodPressure,
  bloodGlucose,
}

/// Enumeration of health data sources
enum HealthDataSource {
  healthConnect,
  manual,
  imported,
}

/// Extension to convert HealthDataType enum to string
extension HealthDataTypeExtension on HealthDataType {
  String get name {
    switch (this) {
      case HealthDataType.weight:
        return 'weight';
      case HealthDataType.bodyFatPercentage:
        return 'bodyFatPercentage';
      case HealthDataType.bmi:
        return 'bmi';
      case HealthDataType.steps:
        return 'steps';
      case HealthDataType.heartRate:
        return 'heartRate';
      case HealthDataType.workout:
        return 'workout';
      case HealthDataType.calories:
        return 'calories';
      case HealthDataType.sleep:
        return 'sleep';
      case HealthDataType.bloodPressure:
        return 'bloodPressure';
      case HealthDataType.bloodGlucose:
        return 'bloodGlucose';
    }
  }

  static HealthDataType fromString(String value) {
    switch (value) {
      case 'weight':
        return HealthDataType.weight;
      case 'bodyFatPercentage':
        return HealthDataType.bodyFatPercentage;
      case 'bmi':
        return HealthDataType.bmi;
      case 'steps':
        return HealthDataType.steps;
      case 'heartRate':
        return HealthDataType.heartRate;
      case 'workout':
        return HealthDataType.workout;
      case 'calories':
        return HealthDataType.calories;
      case 'sleep':
        return HealthDataType.sleep;
      case 'bloodPressure':
        return HealthDataType.bloodPressure;
      case 'bloodGlucose':
        return HealthDataType.bloodGlucose;
      default:
        throw ArgumentError('Unknown HealthDataType: $value');
    }
  }
}

/// Extension to convert HealthDataSource enum to string
extension HealthDataSourceExtension on HealthDataSource {
  String get name {
    switch (this) {
      case HealthDataSource.healthConnect:
        return 'healthConnect';
      case HealthDataSource.manual:
        return 'manual';
      case HealthDataSource.imported:
        return 'imported';
    }
  }

  static HealthDataSource fromString(String value) {
    switch (value) {
      case 'healthConnect':
        return HealthDataSource.healthConnect;
      case 'manual':
        return HealthDataSource.manual;
      case 'imported':
        return HealthDataSource.imported;
      default:
        throw ArgumentError('Unknown HealthDataSource: $value');
    }
  }
}

/// Unified model for health data from any source
class HealthDataPoint {
  final String id;
  final HealthDataType type;
  final double value;
  final String? unit;
  final DateTime timestamp;
  final DateTime? endTime;
  final HealthDataSource source;
  final Map<String, dynamic>? metadata;
  final String? healthConnectId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HealthDataPoint({
    required this.id,
    required this.type,
    required this.value,
    this.unit,
    required this.timestamp,
    this.endTime,
    required this.source,
    this.metadata,
    this.healthConnectId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create HealthDataPoint from Firestore document
  factory HealthDataPoint.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return HealthDataPoint(
      id: data['id'] as String,
      type: HealthDataTypeExtension.fromString(data['type'] as String),
      value: (data['value'] as num).toDouble(),
      unit: data['unit'] as String?,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      endTime: data['endTimestamp'] != null 
          ? (data['endTimestamp'] as Timestamp).toDate() 
          : null,
      source: HealthDataSourceExtension.fromString(data['source'] as String? ?? 'manual'),
      metadata: data['metadata'] as Map<String, dynamic>?,
      healthConnectId: data['healthConnectId'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert HealthDataPoint to Firestore document data
  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      'id': id,
      'type': type.name,
      'value': value,
      'timestamp': Timestamp.fromDate(timestamp),
      'source': source.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };

    if (unit != null) {
      data['unit'] = unit;
    }

    if (endTime != null) {
      data['endTimestamp'] = Timestamp.fromDate(endTime!);
    }

    if (metadata != null) {
      data['metadata'] = metadata;
    }

    if (healthConnectId != null) {
      data['healthConnectId'] = healthConnectId;
    }

    return data;
  }

  /// Create a copy of this HealthDataPoint with updated fields
  HealthDataPoint copyWith({
    String? id,
    HealthDataType? type,
    double? value,
    String? unit,
    DateTime? timestamp,
    DateTime? endTime,
    HealthDataSource? source,
    Map<String, dynamic>? metadata,
    String? healthConnectId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthDataPoint(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      timestamp: timestamp ?? this.timestamp,
      endTime: endTime ?? this.endTime,
      source: source ?? this.source,
      metadata: metadata ?? this.metadata,
      healthConnectId: healthConnectId ?? this.healthConnectId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get duration for time-based data points
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(timestamp);
  }

  /// Check if this data point represents a workout session
  bool get isWorkout => type == HealthDataType.workout;

  /// Check if this data point has a duration
  bool get hasDuration => endTime != null;

  /// Get a human-readable description of the data point
  String get description {
    final valueStr = unit != null ? '$value $unit' : value.toString();
    final typeStr = type.name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)!.toLowerCase()}',
    ).trim();
    
    return '$typeStr: $valueStr';
  }

  /// Get formatted timestamp string
  String get formattedTimestamp {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} '
           '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is HealthDataPoint &&
        other.id == id &&
        other.type == type &&
        other.value == value &&
        other.unit == unit &&
        other.timestamp == timestamp &&
        other.endTime == endTime &&
        other.source == source &&
        other.healthConnectId == healthConnectId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      type,
      value,
      unit,
      timestamp,
      endTime,
      source,
      healthConnectId,
    );
  }

  @override
  String toString() {
    return 'HealthDataPoint('
           'id: $id, '
           'type: ${type.name}, '
           'value: $value, '
           'unit: $unit, '
           'timestamp: $timestamp, '
           'source: ${source.name}'
           ')';
  }
}

/// Utility class for creating HealthDataPoint instances
class HealthDataPointFactory {
  /// Create a weight data point
  static HealthDataPoint createWeight({
    required String id,
    required double weightKg,
    required DateTime timestamp,
    required HealthDataSource source,
    String? healthConnectId,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return HealthDataPoint(
      id: id,
      type: HealthDataType.weight,
      value: weightKg,
      unit: 'kg',
      timestamp: timestamp,
      source: source,
      healthConnectId: healthConnectId,
      metadata: metadata,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a steps data point
  static HealthDataPoint createSteps({
    required String id,
    required int steps,
    required DateTime timestamp,
    required HealthDataSource source,
    String? healthConnectId,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return HealthDataPoint(
      id: id,
      type: HealthDataType.steps,
      value: steps.toDouble(),
      unit: 'steps',
      timestamp: timestamp,
      source: source,
      healthConnectId: healthConnectId,
      metadata: metadata,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a workout data point
  static HealthDataPoint createWorkout({
    required String id,
    required int caloriesBurned,
    required DateTime startTime,
    required DateTime endTime,
    required HealthDataSource source,
    String? healthConnectId,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return HealthDataPoint(
      id: id,
      type: HealthDataType.workout,
      value: caloriesBurned.toDouble(),
      unit: 'calories',
      timestamp: startTime,
      endTime: endTime,
      source: source,
      healthConnectId: healthConnectId,
      metadata: metadata,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a heart rate data point
  static HealthDataPoint createHeartRate({
    required String id,
    required int bpm,
    required DateTime timestamp,
    required HealthDataSource source,
    String? healthConnectId,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return HealthDataPoint(
      id: id,
      type: HealthDataType.heartRate,
      value: bpm.toDouble(),
      unit: 'bpm',
      timestamp: timestamp,
      source: source,
      healthConnectId: healthConnectId,
      metadata: metadata,
      createdAt: now,
      updatedAt: now,
    );
  }
}