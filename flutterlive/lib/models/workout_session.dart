import 'package:cloud_firestore/cloud_firestore.dart';
import 'health_data_point.dart';

/// Enumeration of workout types
enum WorkoutType {
  running,
  walking,
  cycling,
  swimming,
  weightLifting,
  yoga,
  pilates,
  cardio,
  hiit,
  stretching,
  dancing,
  boxing,
  climbing,
  rowing,
  elliptical,
  other,
}

/// Extension to convert WorkoutType enum to string
extension WorkoutTypeExtension on WorkoutType {
  String get name {
    switch (this) {
      case WorkoutType.running:
        return 'running';
      case WorkoutType.walking:
        return 'walking';
      case WorkoutType.cycling:
        return 'cycling';
      case WorkoutType.swimming:
        return 'swimming';
      case WorkoutType.weightLifting:
        return 'weightLifting';
      case WorkoutType.yoga:
        return 'yoga';
      case WorkoutType.pilates:
        return 'pilates';
      case WorkoutType.cardio:
        return 'cardio';
      case WorkoutType.hiit:
        return 'hiit';
      case WorkoutType.stretching:
        return 'stretching';
      case WorkoutType.dancing:
        return 'dancing';
      case WorkoutType.boxing:
        return 'boxing';
      case WorkoutType.climbing:
        return 'climbing';
      case WorkoutType.rowing:
        return 'rowing';
      case WorkoutType.elliptical:
        return 'elliptical';
      case WorkoutType.other:
        return 'other';
    }
  }

  String get displayName {
    switch (this) {
      case WorkoutType.running:
        return 'Running';
      case WorkoutType.walking:
        return 'Walking';
      case WorkoutType.cycling:
        return 'Cycling';
      case WorkoutType.swimming:
        return 'Swimming';
      case WorkoutType.weightLifting:
        return 'Weight Lifting';
      case WorkoutType.yoga:
        return 'Yoga';
      case WorkoutType.pilates:
        return 'Pilates';
      case WorkoutType.cardio:
        return 'Cardio';
      case WorkoutType.hiit:
        return 'HIIT';
      case WorkoutType.stretching:
        return 'Stretching';
      case WorkoutType.dancing:
        return 'Dancing';
      case WorkoutType.boxing:
        return 'Boxing';
      case WorkoutType.climbing:
        return 'Climbing';
      case WorkoutType.rowing:
        return 'Rowing';
      case WorkoutType.elliptical:
        return 'Elliptical';
      case WorkoutType.other:
        return 'Other';
    }
  }

  static WorkoutType fromString(String value) {
    switch (value) {
      case 'running':
        return WorkoutType.running;
      case 'walking':
        return WorkoutType.walking;
      case 'cycling':
        return WorkoutType.cycling;
      case 'swimming':
        return WorkoutType.swimming;
      case 'weightLifting':
        return WorkoutType.weightLifting;
      case 'yoga':
        return WorkoutType.yoga;
      case 'pilates':
        return WorkoutType.pilates;
      case 'cardio':
        return WorkoutType.cardio;
      case 'hiit':
        return WorkoutType.hiit;
      case 'stretching':
        return WorkoutType.stretching;
      case 'dancing':
        return WorkoutType.dancing;
      case 'boxing':
        return WorkoutType.boxing;
      case 'climbing':
        return WorkoutType.climbing;
      case 'rowing':
        return WorkoutType.rowing;
      case 'elliptical':
        return WorkoutType.elliptical;
      case 'other':
        return WorkoutType.other;
      default:
        throw ArgumentError('Unknown WorkoutType: $value');
    }
  }
}

/// Heart rate zone data for workout sessions
class HeartRateZone {
  final String name;
  final int minBpm;
  final int maxBpm;
  final Duration timeInZone;
  final double percentage;

  const HeartRateZone({
    required this.name,
    required this.minBpm,
    required this.maxBpm,
    required this.timeInZone,
    required this.percentage,
  });

  /// Create HeartRateZone from Firestore data
  factory HeartRateZone.fromFirestore(Map<String, dynamic> data) {
    return HeartRateZone(
      name: data['name'] as String,
      minBpm: data['minBpm'] as int,
      maxBpm: data['maxBpm'] as int,
      timeInZone: Duration(seconds: data['timeInZoneSeconds'] as int),
      percentage: (data['percentage'] as num).toDouble(),
    );
  }

  /// Convert HeartRateZone to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'minBpm': minBpm,
      'maxBpm': maxBpm,
      'timeInZoneSeconds': timeInZone.inSeconds,
      'percentage': percentage,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is HeartRateZone &&
        other.name == name &&
        other.minBpm == minBpm &&
        other.maxBpm == maxBpm &&
        other.timeInZone == timeInZone &&
        other.percentage == percentage;
  }

  @override
  int get hashCode {
    return Object.hash(name, minBpm, maxBpm, timeInZone, percentage);
  }

  @override
  String toString() {
    return 'HeartRateZone(name: $name, range: $minBpm-$maxBpm bpm, time: ${timeInZone.inMinutes}min)';
  }
}

/// Extended model for workout session data
class WorkoutSession {
  final String id;
  final WorkoutType type;
  final DateTime startTime;
  final DateTime endTime;
  final int? calories;
  final double? distance;
  final String? distanceUnit;
  final List<HeartRateZone>? heartRateZones;
  final int? averageHeartRate;
  final int? maxHeartRate;
  final HealthDataSource source;
  final Map<String, dynamic>? metadata;
  final String? healthConnectId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkoutSession({
    required this.id,
    required this.type,
    required this.startTime,
    required this.endTime,
    this.calories,
    this.distance,
    this.distanceUnit,
    this.heartRateZones,
    this.averageHeartRate,
    this.maxHeartRate,
    required this.source,
    this.metadata,
    this.healthConnectId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get workout duration
  Duration get duration => endTime.difference(startTime);

  /// Get duration in minutes
  int get durationInMinutes => duration.inMinutes;

  /// Get formatted duration string
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Get calories per minute
  double? get caloriesPerMinute {
    if (calories == null || durationInMinutes == 0) return null;
    return calories! / durationInMinutes;
  }

  /// Get average pace (if distance is available)
  double? get averagePace {
    if (distance == null || durationInMinutes == 0) return null;
    return durationInMinutes / distance!; // minutes per unit distance
  }

  /// Check if workout has heart rate data
  bool get hasHeartRateData => 
      averageHeartRate != null || maxHeartRate != null || heartRateZones != null;

  /// Create WorkoutSession from Firestore document
  factory WorkoutSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    List<HeartRateZone>? heartRateZones;
    if (data['heartRateZones'] != null) {
      final zonesData = data['heartRateZones'] as List<dynamic>;
      heartRateZones = zonesData
          .map((zone) => HeartRateZone.fromFirestore(zone as Map<String, dynamic>))
          .toList();
    }
    
    return WorkoutSession(
      id: data['id'] as String,
      type: WorkoutTypeExtension.fromString(data['type'] as String),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      calories: data['calories'] as int?,
      distance: data['distance'] != null ? (data['distance'] as num).toDouble() : null,
      distanceUnit: data['distanceUnit'] as String?,
      heartRateZones: heartRateZones,
      averageHeartRate: data['averageHeartRate'] as int?,
      maxHeartRate: data['maxHeartRate'] as int?,
      source: HealthDataSourceExtension.fromString(data['source'] as String? ?? 'manual'),
      metadata: data['metadata'] as Map<String, dynamic>?,
      healthConnectId: data['healthConnectId'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert WorkoutSession to Firestore document data
  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      'id': id,
      'type': type.name,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'source': source.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };

    if (calories != null) {
      data['calories'] = calories;
    }

    if (distance != null) {
      data['distance'] = distance;
    }

    if (distanceUnit != null) {
      data['distanceUnit'] = distanceUnit;
    }

    if (heartRateZones != null) {
      data['heartRateZones'] = heartRateZones!
          .map((zone) => zone.toFirestore())
          .toList();
    }

    if (averageHeartRate != null) {
      data['averageHeartRate'] = averageHeartRate;
    }

    if (maxHeartRate != null) {
      data['maxHeartRate'] = maxHeartRate;
    }

    if (metadata != null) {
      data['metadata'] = metadata;
    }

    if (healthConnectId != null) {
      data['healthConnectId'] = healthConnectId;
    }

    return data;
  }

  /// Create a copy of this WorkoutSession with updated fields
  WorkoutSession copyWith({
    String? id,
    WorkoutType? type,
    DateTime? startTime,
    DateTime? endTime,
    int? calories,
    double? distance,
    String? distanceUnit,
    List<HeartRateZone>? heartRateZones,
    int? averageHeartRate,
    int? maxHeartRate,
    HealthDataSource? source,
    Map<String, dynamic>? metadata,
    String? healthConnectId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      calories: calories ?? this.calories,
      distance: distance ?? this.distance,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      heartRateZones: heartRateZones ?? this.heartRateZones,
      averageHeartRate: averageHeartRate ?? this.averageHeartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      source: source ?? this.source,
      metadata: metadata ?? this.metadata,
      healthConnectId: healthConnectId ?? this.healthConnectId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get formatted date string
  String get formattedDate {
    return '${startTime.day}/${startTime.month}/${startTime.year}';
  }

  /// Get formatted time string
  String get formattedTime {
    return '${startTime.hour.toString().padLeft(2, '0')}:'
           '${startTime.minute.toString().padLeft(2, '0')}';
  }

  /// Get workout intensity based on heart rate zones
  String get intensityLevel {
    if (heartRateZones == null || heartRateZones!.isEmpty) {
      return 'Unknown';
    }

    // Calculate intensity based on time spent in different zones
    double highIntensityTime = 0;
    double moderateIntensityTime = 0;
    
    for (final zone in heartRateZones!) {
      if (zone.name.toLowerCase().contains('vigorous') || 
          zone.name.toLowerCase().contains('anaerobic')) {
        highIntensityTime += zone.timeInZone.inMinutes;
      } else if (zone.name.toLowerCase().contains('aerobic') ||
                 zone.name.toLowerCase().contains('moderate')) {
        moderateIntensityTime += zone.timeInZone.inMinutes;
      }
    }

    final totalTime = durationInMinutes;
    final highIntensityPercentage = (highIntensityTime / totalTime) * 100;
    final moderateIntensityPercentage = (moderateIntensityTime / totalTime) * 100;

    if (highIntensityPercentage > 30) {
      return 'High';
    } else if (moderateIntensityPercentage > 50) {
      return 'Moderate';
    } else {
      return 'Low';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is WorkoutSession &&
        other.id == id &&
        other.type == type &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.calories == calories &&
        other.distance == distance &&
        other.source == source &&
        other.healthConnectId == healthConnectId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      type,
      startTime,
      endTime,
      calories,
      distance,
      source,
      healthConnectId,
    );
  }

  @override
  String toString() {
    return 'WorkoutSession('
           'id: $id, '
           'type: ${type.displayName}, '
           'duration: $formattedDuration, '
           'calories: $calories, '
           'source: ${source.name}'
           ')';
  }
}

/// Utility class for creating WorkoutSession instances
class WorkoutSessionFactory {
  /// Create a basic workout session
  static WorkoutSession create({
    required String id,
    required WorkoutType type,
    required DateTime startTime,
    required DateTime endTime,
    required HealthDataSource source,
    int? calories,
    double? distance,
    String? distanceUnit,
    String? healthConnectId,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return WorkoutSession(
      id: id,
      type: type,
      startTime: startTime,
      endTime: endTime,
      calories: calories,
      distance: distance,
      distanceUnit: distanceUnit,
      source: source,
      healthConnectId: healthConnectId,
      metadata: metadata,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a running workout session
  static WorkoutSession createRunning({
    required String id,
    required DateTime startTime,
    required DateTime endTime,
    required HealthDataSource source,
    int? calories,
    double? distanceKm,
    int? averageHeartRate,
    int? maxHeartRate,
    String? healthConnectId,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return WorkoutSession(
      id: id,
      type: WorkoutType.running,
      startTime: startTime,
      endTime: endTime,
      calories: calories,
      distance: distanceKm,
      distanceUnit: 'km',
      averageHeartRate: averageHeartRate,
      maxHeartRate: maxHeartRate,
      source: source,
      healthConnectId: healthConnectId,
      metadata: metadata,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a weight lifting workout session
  static WorkoutSession createWeightLifting({
    required String id,
    required DateTime startTime,
    required DateTime endTime,
    required HealthDataSource source,
    int? calories,
    int? averageHeartRate,
    int? maxHeartRate,
    String? healthConnectId,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return WorkoutSession(
      id: id,
      type: WorkoutType.weightLifting,
      startTime: startTime,
      endTime: endTime,
      calories: calories,
      averageHeartRate: averageHeartRate,
      maxHeartRate: maxHeartRate,
      source: source,
      healthConnectId: healthConnectId,
      metadata: metadata,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a cycling workout session
  static WorkoutSession createCycling({
    required String id,
    required DateTime startTime,
    required DateTime endTime,
    required HealthDataSource source,
    int? calories,
    double? distanceKm,
    int? averageHeartRate,
    int? maxHeartRate,
    String? healthConnectId,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return WorkoutSession(
      id: id,
      type: WorkoutType.cycling,
      startTime: startTime,
      endTime: endTime,
      calories: calories,
      distance: distanceKm,
      distanceUnit: 'km',
      averageHeartRate: averageHeartRate,
      maxHeartRate: maxHeartRate,
      source: source,
      healthConnectId: healthConnectId,
      metadata: metadata,
      createdAt: now,
      updatedAt: now,
    );
  }
}