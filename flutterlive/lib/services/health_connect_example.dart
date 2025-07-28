import 'dart:async';
import 'package:flutter/foundation.dart';
import 'platform_health_service.dart';
import 'health_connect_service.dart';
import '../models/health_data_point.dart';

/// Example usage of Health Connect service
class HealthConnectExample {
  late final HealthConnectService _healthService;
  StreamSubscription<HealthConnectEvent>? _eventSubscription;

  HealthConnectExample() {
    _healthService = PlatformHealthService.instance;
    _setupEventListener();
  }

  /// Initialize Health Connect and request permissions
  Future<bool> initialize() async {
    try {
      // Check if Health Connect is available
      if (!await _healthService.isAvailable()) {
        debugPrint('Health Connect is not available on this device');
        return false;
      }

      // Request permissions for common health data types
      final commonTypes = HealthConnectServiceExtension.commonHealthDataTypes;
      final granted = await _healthService.requestPermissions(commonTypes);

      if (granted) {
        debugPrint('Health Connect permissions granted');
        return true;
      } else {
        debugPrint('Health Connect permissions denied');
        return false;
      }
    } catch (e) {
      debugPrint('Error initializing Health Connect: $e');
      return false;
    }
  }

  /// Get recent weight data
  Future<List<HealthDataPoint>> getRecentWeightData({int days = 30}) async {
    try {
      final endTime = DateTime.now();
      final startTime = endTime.subtract(Duration(days: days));

      final data = await _healthService.getHealthData(
        [HealthDataType.weight],
        startTime,
        endTime,
      );

      debugPrint('Retrieved ${data.length} weight data points');
      return data;
    } catch (e) {
      debugPrint('Error getting weight data: $e');
      return [];
    }
  }

  /// Get recent step data
  Future<List<HealthDataPoint>> getRecentStepsData({int days = 7}) async {
    try {
      final endTime = DateTime.now();
      final startTime = endTime.subtract(Duration(days: days));

      final data = await _healthService.getHealthData(
        [HealthDataType.steps],
        startTime,
        endTime,
      );

      debugPrint('Retrieved ${data.length} steps data points');
      return data;
    } catch (e) {
      debugPrint('Error getting steps data: $e');
      return [];
    }
  }

  /// Get recent workout data
  Future<List<HealthDataPoint>> getRecentWorkoutData({int days = 14}) async {
    try {
      final endTime = DateTime.now();
      final startTime = endTime.subtract(Duration(days: days));

      final data = await _healthService.getHealthData(
        [HealthDataType.workout],
        startTime,
        endTime,
      );

      debugPrint('Retrieved ${data.length} workout data points');
      return data;
    } catch (e) {
      debugPrint('Error getting workout data: $e');
      return [];
    }
  }

  /// Check permission status for all common data types
  Future<Map<HealthDataType, bool>> checkPermissionStatus() async {
    try {
      final commonTypes = HealthConnectServiceExtension.commonHealthDataTypes;
      final status = await _healthService.getPermissionStatus(commonTypes);
      
      debugPrint('Permission status: $status');
      return status;
    } catch (e) {
      debugPrint('Error checking permission status: $e');
      return {};
    }
  }

  /// Get comprehensive health summary
  Future<HealthSummary> getHealthSummary({int days = 30}) async {
    final summary = HealthSummary();

    try {
      final endTime = DateTime.now();
      final startTime = endTime.subtract(Duration(days: days));

      // Get all common health data types
      final allData = await _healthService.getHealthData(
        HealthConnectServiceExtension.commonHealthDataTypes,
        startTime,
        endTime,
      );

      // Group data by type
      for (final dataPoint in allData) {
        switch (dataPoint.type) {
          case HealthDataType.weight:
            summary.weightData.add(dataPoint);
            break;
          case HealthDataType.steps:
            summary.stepsData.add(dataPoint);
            break;
          case HealthDataType.heartRate:
            summary.heartRateData.add(dataPoint);
            break;
          case HealthDataType.calories:
            summary.caloriesData.add(dataPoint);
            break;
          case HealthDataType.workout:
            summary.workoutData.add(dataPoint);
            break;
          default:
            break;
        }
      }

      debugPrint('Health summary: ${summary.toString()}');
      return summary;
    } catch (e) {
      debugPrint('Error getting health summary: $e');
      return summary;
    }
  }

  /// Setup event listener for Health Connect changes
  void _setupEventListener() {
    _eventSubscription = _healthService.healthConnectEvents.listen(
      (event) {
        if (event is HealthDataChangedEvent) {
          debugPrint('Health data changed: ${event.changedTypes}');
        } else if (event is PermissionChangedEvent) {
          debugPrint('Permissions changed: ${event.permissions}');
        }
      },
      onError: (error) {
        debugPrint('Health Connect event error: $error');
      },
    );
  }

  /// Dispose of resources
  void dispose() {
    _eventSubscription?.cancel();
    _healthService.dispose();
  }
}

/// Health data summary container
class HealthSummary {
  final List<HealthDataPoint> weightData = [];
  final List<HealthDataPoint> stepsData = [];
  final List<HealthDataPoint> heartRateData = [];
  final List<HealthDataPoint> caloriesData = [];
  final List<HealthDataPoint> workoutData = [];

  /// Get the most recent weight
  double? get latestWeight => 
      weightData.isNotEmpty ? weightData.first.value : null;

  /// Get total steps for the period
  int get totalSteps => 
      stepsData.fold(0, (sum, data) => sum + data.value.toInt());

  /// Get average heart rate
  double? get averageHeartRate {
    if (heartRateData.isEmpty) return null;
    final total = heartRateData.fold(0.0, (sum, data) => sum + data.value);
    return total / heartRateData.length;
  }

  /// Get total calories burned
  double get totalCalories => 
      caloriesData.fold(0.0, (sum, data) => sum + data.value);

  /// Get number of workouts
  int get workoutCount => workoutData.length;

  @override
  String toString() {
    return 'HealthSummary('
           'weight: $latestWeight, '
           'steps: $totalSteps, '
           'avgHeartRate: $averageHeartRate, '
           'calories: $totalCalories, '
           'workouts: $workoutCount'
           ')';
  }
}