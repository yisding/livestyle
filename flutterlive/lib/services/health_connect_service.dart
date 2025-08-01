import 'dart:async';
import 'dart:io';
import 'package:health/health.dart';
import '../models/health_data_point.dart' as app_models;

/// Custom exceptions for Health Connect operations
class HealthConnectException implements Exception {
  final String message;
  final String? code;

  const HealthConnectException(this.message, [this.code]);

  @override
  String toString() =>
      'HealthConnectException: $message${code != null ? ' (Code: $code)' : ''}';
}

class PermissionException extends HealthConnectException {
  const PermissionException(String message)
    : super(message, 'PERMISSION_DENIED');
}

class NetworkException extends HealthConnectException {
  const NetworkException(String message) : super(message, 'NETWORK_ERROR');
}

class PlatformException extends HealthConnectException {
  const PlatformException(String message)
    : super(message, 'PLATFORM_NOT_SUPPORTED');
}

/// Events emitted by Health Connect service
abstract class HealthConnectEvent {}

class HealthDataChangedEvent extends HealthConnectEvent {
  final List<app_models.HealthDataType> changedTypes;

  HealthDataChangedEvent(this.changedTypes);
}

class PermissionChangedEvent extends HealthConnectEvent {
  final Map<app_models.HealthDataType, bool> permissions;

  PermissionChangedEvent(this.permissions);
}

/// Abstract interface for Health Connect service
abstract class HealthConnectService {
  /// Check if Health Connect is available on the current platform
  Future<bool> isAvailable();

  /// Check if permissions are granted for the specified data types
  Future<bool> hasPermissions(List<app_models.HealthDataType> types);

  /// Request permissions for the specified data types
  Future<bool> requestPermissions(List<app_models.HealthDataType> types);

  /// Get health data for the specified types and time range
  Future<List<app_models.HealthDataPoint>> getHealthData(
    List<app_models.HealthDataType> types,
    DateTime startTime,
    DateTime endTime,
  );

  /// Write health data points to Health Connect (read-only implementation returns false)
  Future<bool> writeHealthData(List<app_models.HealthDataPoint> dataPoints);

  /// Revoke all Health Connect permissions
  Future<void> revokePermissions();

  /// Stream of Health Connect events
  Stream<HealthConnectEvent> get healthConnectEvents;

  /// Check if the current platform supports Health Connect
  bool get isPlatformSupported;

  /// Get individual permission status for each data type
  Future<Map<app_models.HealthDataType, bool>> getPermissionStatus(
    List<app_models.HealthDataType> types,
  );

  /// Dispose of resources and close streams
  void dispose();
}

/// Android implementation using the health package
class HealthConnectServiceImpl implements HealthConnectService {
  final Health _health = Health();
  final StreamController<HealthConnectEvent> _eventController =
      StreamController<HealthConnectEvent>.broadcast();

  @override
  bool get isPlatformSupported => Platform.isAndroid;

  @override
  Future<bool> isAvailable() async {
    if (!isPlatformSupported) return false;

    try {
      // Check if Health Connect is installed and available on Android
      // First check if the health package can access basic data types
      final isStepsAvailable = _health.isDataTypeAvailable(
        HealthDataType.STEPS,
      );

      if (!isStepsAvailable) {
        return false;
      }

      // Additional check to ensure Health Connect is properly configured
      // Try to check permissions for a basic data type
      final hasBasicAccess = await _health.hasPermissions(
        [HealthDataType.STEPS],
        permissions: [HealthDataAccess.READ],
      );

      // If we can check permissions, Health Connect is available
      // (even if permissions are not granted yet)
      return hasBasicAccess != null;
    } catch (e) {
      // If any error occurs, assume Health Connect is not available
      return false;
    }
  }

  @override
  Future<bool> hasPermissions(List<app_models.HealthDataType> types) async {
    if (!isPlatformSupported) {
      throw const PlatformException(
        'Health Connect is not supported on this platform',
      );
    }

    try {
      final healthTypes = types.map(_mapToHealthDataType).toList();
      final permissions = healthTypes
          .map((type) => HealthDataAccess.READ)
          .toList();

      final result = await _health.hasPermissions(
        healthTypes,
        permissions: permissions,
      );
      return result ?? false;
    } catch (e) {
      throw HealthConnectException(
        'Failed to check permissions: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> requestPermissions(List<app_models.HealthDataType> types) async {
    if (!isPlatformSupported) {
      throw const PlatformException(
        'Health Connect is not supported on this platform',
      );
    }

    try {
      final healthTypes = types.map(_mapToHealthDataType).toList();
      final permissions = healthTypes
          .map((type) => HealthDataAccess.READ)
          .toList();

      final granted = await _health.requestAuthorization(
        healthTypes,
        permissions: permissions,
      );

      if (granted) {
        // Check actual permissions granted and emit event
        final actualPermissions = await _health.hasPermissions(
          healthTypes,
          permissions: permissions,
        );
        final permissionMap = <app_models.HealthDataType, bool>{};

        for (int i = 0; i < types.length; i++) {
          permissionMap[types[i]] = actualPermissions ?? false;
        }

        _eventController.add(PermissionChangedEvent(permissionMap));
      }

      return granted;
    } catch (e) {
      throw PermissionException(
        'Failed to request permissions: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<app_models.HealthDataPoint>> getHealthData(
    List<app_models.HealthDataType> types,
    DateTime startTime,
    DateTime endTime,
  ) async {
    if (!isPlatformSupported) {
      throw const PlatformException(
        'Health Connect is not supported on this platform',
      );
    }

    try {
      final healthTypes = types.map(_mapToHealthDataType).toList();

      // Validate time range
      if (endTime.isBefore(startTime)) {
        throw const HealthConnectException(
          'End time cannot be before start time',
        );
      }

      final healthData = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: healthTypes,
      );

      // Filter out invalid data points and map to app model
      final validDataPoints = healthData
          .where((point) => point.value is NumericHealthValue)
          .map(_mapToAppHealthDataPoint)
          .toList();

      // Sort by timestamp (most recent first)
      validDataPoints.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return validDataPoints;
    } catch (e) {
      if (e is HealthConnectException) rethrow;
      throw HealthConnectException(
        'Failed to fetch health data: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> writeHealthData(
    List<app_models.HealthDataPoint> dataPoints,
  ) async {
    // Write operations are not supported - this is a read-only implementation
    return false;
  }

  @override
  Future<void> revokePermissions() async {
    if (!isPlatformSupported) {
      throw const PlatformException(
        'Health Connect is not supported on this platform',
      );
    }

    try {
      await _health.revokePermissions();
      _eventController.add(PermissionChangedEvent({}));
    } catch (e) {
      throw HealthConnectException(
        'Failed to revoke permissions: ${e.toString()}',
      );
    }
  }

  @override
  Stream<HealthConnectEvent> get healthConnectEvents => _eventController.stream;

  /// Map app health data type to health package type
  HealthDataType _mapToHealthDataType(app_models.HealthDataType type) {
    switch (type) {
      case app_models.HealthDataType.weight:
        return HealthDataType.WEIGHT;
      case app_models.HealthDataType.bodyFatPercentage:
        return HealthDataType.BODY_FAT_PERCENTAGE;
      case app_models.HealthDataType.bmi:
        return HealthDataType.BODY_MASS_INDEX;
      case app_models.HealthDataType.steps:
        return HealthDataType.STEPS;
      case app_models.HealthDataType.heartRate:
        return HealthDataType.HEART_RATE;
      case app_models.HealthDataType.workout:
        return HealthDataType.WORKOUT;
      case app_models.HealthDataType.calories:
        return HealthDataType.ACTIVE_ENERGY_BURNED;
      case app_models.HealthDataType.sleep:
        return HealthDataType.SLEEP_ASLEEP;
      case app_models.HealthDataType.bloodPressure:
        return HealthDataType.BLOOD_PRESSURE_SYSTOLIC;
      case app_models.HealthDataType.bloodGlucose:
        return HealthDataType.BLOOD_GLUCOSE;
    }
  }

  /// Map health package data point to app data point
  app_models.HealthDataPoint _mapToAppHealthDataPoint(
    HealthDataPoint healthPoint,
  ) {
    final now = DateTime.now();
    return app_models.HealthDataPoint(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _mapFromHealthDataType(healthPoint.type),
      value: (healthPoint.value as NumericHealthValue).numericValue.toDouble(),
      unit: healthPoint.unit.name,
      timestamp: healthPoint.dateFrom,
      endTime: healthPoint.dateTo,
      source: app_models.HealthDataSource.healthConnect,
      createdAt: now,
      updatedAt: now,
      metadata: {
        'platform': healthPoint.sourcePlatform.name,
        'device': healthPoint.sourceDeviceId,
        'sourceId': healthPoint.sourceId,
        'sourceName': healthPoint.sourceName,
      },
    );
  }

  /// Map health package type to app health data type
  app_models.HealthDataType _mapFromHealthDataType(HealthDataType type) {
    switch (type) {
      case HealthDataType.WEIGHT:
        return app_models.HealthDataType.weight;
      case HealthDataType.BODY_FAT_PERCENTAGE:
        return app_models.HealthDataType.bodyFatPercentage;
      case HealthDataType.BODY_MASS_INDEX:
        return app_models.HealthDataType.bmi;
      case HealthDataType.STEPS:
        return app_models.HealthDataType.steps;
      case HealthDataType.HEART_RATE:
        return app_models.HealthDataType.heartRate;
      case HealthDataType.WORKOUT:
        return app_models.HealthDataType.workout;
      case HealthDataType.ACTIVE_ENERGY_BURNED:
        return app_models.HealthDataType.calories;
      case HealthDataType.SLEEP_ASLEEP:
      case HealthDataType.SLEEP_AWAKE:
      case HealthDataType.SLEEP_IN_BED:
        return app_models.HealthDataType.sleep;
      case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
      case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
        return app_models.HealthDataType.bloodPressure;
      case HealthDataType.BLOOD_GLUCOSE:
        return app_models.HealthDataType.bloodGlucose;
      default:
        return app_models.HealthDataType.weight; // Default fallback
    }
  }

  @override
  Future<Map<app_models.HealthDataType, bool>> getPermissionStatus(
    List<app_models.HealthDataType> types,
  ) async {
    if (!isPlatformSupported) {
      throw const PlatformException(
        'Health Connect is not supported on this platform',
      );
    }

    final result = <app_models.HealthDataType, bool>{};

    try {
      // Check permissions for each type individually
      for (final type in types) {
        final healthType = _mapToHealthDataType(type);
        final hasPermission = await _health.hasPermissions(
          [healthType],
          permissions: [HealthDataAccess.READ],
        );
        result[type] = hasPermission ?? false;
      }

      return result;
    } catch (e) {
      throw HealthConnectException(
        'Failed to get permission status: ${e.toString()}',
      );
    }
  }

  @override
  void dispose() {
    _eventController.close();
  }
}

/// Stub implementation for non-Android platforms
class HealthConnectServiceStub implements HealthConnectService {
  final StreamController<HealthConnectEvent> _eventController =
      StreamController<HealthConnectEvent>.broadcast();

  @override
  bool get isPlatformSupported => false;

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<bool> hasPermissions(List<app_models.HealthDataType> types) async =>
      false;

  @override
  Future<bool> requestPermissions(
    List<app_models.HealthDataType> types,
  ) async => false;

  @override
  Future<List<app_models.HealthDataPoint>> getHealthData(
    List<app_models.HealthDataType> types,
    DateTime startTime,
    DateTime endTime,
  ) async => [];

  @override
  Future<bool> writeHealthData(
    List<app_models.HealthDataPoint> dataPoints,
  ) async => false;

  @override
  Future<void> revokePermissions() async {}

  @override
  Stream<HealthConnectEvent> get healthConnectEvents => _eventController.stream;

  @override
  Future<Map<app_models.HealthDataType, bool>> getPermissionStatus(
    List<app_models.HealthDataType> types,
  ) async {
    throw const PlatformException(
      'Health Connect is not supported on this platform',
    );
  }

  @override
  void dispose() {
    _eventController.close();
  }
}
