import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/health_data_point.dart';
import 'health_connect_service.dart';

/// Permission status for a specific health data type
enum PermissionStatus {
  granted,
  denied,
  notDetermined,
  restricted,
}

/// Result of a permission request operation
class PermissionResult {
  final bool success;
  final Map<HealthDataType, PermissionStatus> permissions;
  final String? errorMessage;
  final String? errorCode;

  const PermissionResult({
    required this.success,
    required this.permissions,
    this.errorMessage,
    this.errorCode,
  });

  factory PermissionResult.success(Map<HealthDataType, PermissionStatus> permissions) {
    return PermissionResult(
      success: true,
      permissions: permissions,
    );
  }

  factory PermissionResult.failure(String message, {String? code}) {
    return PermissionResult(
      success: false,
      permissions: {},
      errorMessage: message,
      errorCode: code,
    );
  }

  factory PermissionResult.platformNotSupported() {
    return const PermissionResult(
      success: false,
      permissions: {},
      errorMessage: 'Health Connect is not supported on this platform',
      errorCode: 'PLATFORM_NOT_SUPPORTED',
    );
  }

  factory PermissionResult.healthConnectUnavailable() {
    return const PermissionResult(
      success: false,
      permissions: {},
      errorMessage: 'Health Connect is not available on this device',
      errorCode: 'HEALTH_CONNECT_UNAVAILABLE',
    );
  }

  /// Check if all requested permissions were granted
  bool get allPermissionsGranted {
    return permissions.values.every((status) => status == PermissionStatus.granted);
  }

  /// Get list of granted permissions
  List<HealthDataType> get grantedPermissions {
    return permissions.entries
        .where((entry) => entry.value == PermissionStatus.granted)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get list of denied permissions
  List<HealthDataType> get deniedPermissions {
    return permissions.entries
        .where((entry) => entry.value == PermissionStatus.denied)
        .map((entry) => entry.key)
        .toList();
  }
}

/// Events emitted by the permission service
abstract class PermissionEvent {}

class PermissionStatusChangedEvent extends PermissionEvent {
  final Map<HealthDataType, PermissionStatus> permissions;
  final DateTime timestamp;

  PermissionStatusChangedEvent(this.permissions) : timestamp = DateTime.now();
}

class PermissionRequestCompletedEvent extends PermissionEvent {
  final PermissionResult result;
  final DateTime timestamp;

  PermissionRequestCompletedEvent(this.result) : timestamp = DateTime.now();
}

/// Service for managing Health Connect permissions
class HealthConnectPermissionService {
  final HealthConnectService _healthConnectService;
  final StreamController<PermissionEvent> _eventController = 
      StreamController<PermissionEvent>.broadcast();
  
  Timer? _permissionMonitorTimer;
  Map<HealthDataType, PermissionStatus> _lastKnownPermissions = {};

  HealthConnectPermissionService(this._healthConnectService) {
    _startPermissionMonitoring();
  }

  /// Stream of permission events
  Stream<PermissionEvent> get permissionEvents => _eventController.stream;

  /// Check if Health Connect is available on the current platform
  Future<bool> isHealthConnectAvailable() async {
    if (!_healthConnectService.isPlatformSupported) {
      return false;
    }
    
    try {
      return await _healthConnectService.isAvailable();
    } catch (e) {
      debugPrint('Error checking Health Connect availability: $e');
      return false;
    }
  }

  /// Get current permission status for specified data types
  Future<Map<HealthDataType, PermissionStatus>> getPermissionStatus(
    List<HealthDataType> types,
  ) async {
    if (!_healthConnectService.isPlatformSupported) {
      return {for (var type in types) type: PermissionStatus.restricted};
    }

    try {
      final isAvailable = await _healthConnectService.isAvailable();
      if (!isAvailable) {
        return {for (var type in types) type: PermissionStatus.restricted};
      }

      final healthConnectPermissions = await _healthConnectService.getPermissionStatus(types);
      final result = <HealthDataType, PermissionStatus>{};

      for (final type in types) {
        final hasPermission = healthConnectPermissions[type] ?? false;
        result[type] = hasPermission ? PermissionStatus.granted : PermissionStatus.denied;
      }

      return result;
    } catch (e) {
      debugPrint('Error getting permission status: $e');
      return {for (var type in types) type: PermissionStatus.notDetermined};
    }
  }

  /// Request permissions for specified data types
  Future<PermissionResult> requestPermissions(
    List<HealthDataType> types, {
    bool showRationale = true,
  }) async {
    try {
      // Check platform support
      if (!_healthConnectService.isPlatformSupported) {
        final result = PermissionResult.platformNotSupported();
        _eventController.add(PermissionRequestCompletedEvent(result));
        return result;
      }

      // Check Health Connect availability
      final isAvailable = await _healthConnectService.isAvailable();
      if (!isAvailable) {
        final result = PermissionResult.healthConnectUnavailable();
        _eventController.add(PermissionRequestCompletedEvent(result));
        return result;
      }

      // Check current permissions first
      final currentPermissions = await getPermissionStatus(types);
      final typesNeedingPermission = types
          .where((type) => currentPermissions[type] != PermissionStatus.granted)
          .toList();

      // If all permissions are already granted, return success
      if (typesNeedingPermission.isEmpty) {
        final result = PermissionResult.success(currentPermissions);
        _eventController.add(PermissionRequestCompletedEvent(result));
        return result;
      }

      // Request permissions from Health Connect
      final granted = await _healthConnectService.requestPermissions(typesNeedingPermission);
      
      // Get updated permission status
      final updatedPermissions = await getPermissionStatus(types);
      
      final result = PermissionResult.success(updatedPermissions);
      _eventController.add(PermissionRequestCompletedEvent(result));
      
      // Update cached permissions and emit change event
      _lastKnownPermissions = updatedPermissions;
      _eventController.add(PermissionStatusChangedEvent(updatedPermissions));

      return result;
    } on PermissionException catch (e) {
      final result = PermissionResult.failure(e.message, code: e.code);
      _eventController.add(PermissionRequestCompletedEvent(result));
      return result;
    } on PlatformException catch (e) {
      final result = PermissionResult.failure(e.message, code: e.code);
      _eventController.add(PermissionRequestCompletedEvent(result));
      return result;
    } catch (e) {
      final result = PermissionResult.failure(
        'Failed to request permissions: ${e.toString()}',
        code: 'UNKNOWN_ERROR',
      );
      _eventController.add(PermissionRequestCompletedEvent(result));
      return result;
    }
  }

  /// Revoke all Health Connect permissions
  Future<PermissionResult> revokeAllPermissions() async {
    try {
      if (!_healthConnectService.isPlatformSupported) {
        return PermissionResult.platformNotSupported();
      }

      await _healthConnectService.revokePermissions();
      
      // Clear cached permissions
      _lastKnownPermissions.clear();
      _eventController.add(PermissionStatusChangedEvent({}));

      return PermissionResult.success({});
    } catch (e) {
      return PermissionResult.failure(
        'Failed to revoke permissions: ${e.toString()}',
        code: 'REVOKE_ERROR',
      );
    }
  }

  /// Check if specific permission is granted
  Future<bool> hasPermission(HealthDataType type) async {
    final permissions = await getPermissionStatus([type]);
    return permissions[type] == PermissionStatus.granted;
  }

  /// Check if all specified permissions are granted
  Future<bool> hasAllPermissions(List<HealthDataType> types) async {
    final permissions = await getPermissionStatus(types);
    return permissions.values.every((status) => status == PermissionStatus.granted);
  }

  /// Get list of all supported health data types
  List<HealthDataType> getSupportedDataTypes() {
    if (!_healthConnectService.isPlatformSupported) {
      return [];
    }
    
    return HealthDataType.values;
  }

  /// Get essential health data types for basic functionality
  List<HealthDataType> getEssentialDataTypes() {
    return [
      HealthDataType.weight,
      HealthDataType.steps,
      HealthDataType.heartRate,
      HealthDataType.workout,
      HealthDataType.calories,
    ];
  }

  /// Get optional health data types for enhanced functionality
  List<HealthDataType> getOptionalDataTypes() {
    return [
      HealthDataType.bodyFatPercentage,
      HealthDataType.bmi,
      HealthDataType.sleep,
      HealthDataType.bloodPressure,
      HealthDataType.bloodGlucose,
    ];
  }

  /// Start monitoring permission changes
  void _startPermissionMonitoring() {
    if (!_healthConnectService.isPlatformSupported) {
      return;
    }

    // Check permissions every 30 seconds
    _permissionMonitorTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkPermissionChanges(),
    );
  }

  /// Check for permission changes and emit events if needed
  Future<void> _checkPermissionChanges() async {
    try {
      final allTypes = getSupportedDataTypes();
      if (allTypes.isEmpty) return;

      final currentPermissions = await getPermissionStatus(allTypes);
      
      // Compare with last known permissions
      bool hasChanges = false;
      for (final type in allTypes) {
        final currentStatus = currentPermissions[type];
        final lastStatus = _lastKnownPermissions[type];
        
        if (currentStatus != lastStatus) {
          hasChanges = true;
          break;
        }
      }

      if (hasChanges) {
        _lastKnownPermissions = currentPermissions;
        _eventController.add(PermissionStatusChangedEvent(currentPermissions));
      }
    } catch (e) {
      debugPrint('Error checking permission changes: $e');
    }
  }

  /// Get user-friendly description for a health data type
  String getDataTypeDescription(HealthDataType type) {
    switch (type) {
      case HealthDataType.weight:
        return 'Body weight measurements';
      case HealthDataType.bodyFatPercentage:
        return 'Body fat percentage data';
      case HealthDataType.bmi:
        return 'Body Mass Index calculations';
      case HealthDataType.steps:
        return 'Daily step count and activity';
      case HealthDataType.heartRate:
        return 'Heart rate measurements';
      case HealthDataType.workout:
        return 'Exercise sessions and activities';
      case HealthDataType.calories:
        return 'Calories burned during activities';
      case HealthDataType.sleep:
        return 'Sleep duration and quality data';
      case HealthDataType.bloodPressure:
        return 'Blood pressure readings';
      case HealthDataType.bloodGlucose:
        return 'Blood glucose measurements';
    }
  }

  /// Get user-friendly name for a health data type
  String getDataTypeName(HealthDataType type) {
    switch (type) {
      case HealthDataType.weight:
        return 'Weight';
      case HealthDataType.bodyFatPercentage:
        return 'Body Fat %';
      case HealthDataType.bmi:
        return 'BMI';
      case HealthDataType.steps:
        return 'Steps';
      case HealthDataType.heartRate:
        return 'Heart Rate';
      case HealthDataType.workout:
        return 'Workouts';
      case HealthDataType.calories:
        return 'Calories';
      case HealthDataType.sleep:
        return 'Sleep';
      case HealthDataType.bloodPressure:
        return 'Blood Pressure';
      case HealthDataType.bloodGlucose:
        return 'Blood Glucose';
    }
  }

  /// Get icon name for a health data type
  String getDataTypeIcon(HealthDataType type) {
    switch (type) {
      case HealthDataType.weight:
        return 'scale';
      case HealthDataType.bodyFatPercentage:
        return 'body';
      case HealthDataType.bmi:
        return 'calculator';
      case HealthDataType.steps:
        return 'directions_walk';
      case HealthDataType.heartRate:
        return 'favorite';
      case HealthDataType.workout:
        return 'fitness_center';
      case HealthDataType.calories:
        return 'local_fire_department';
      case HealthDataType.sleep:
        return 'bedtime';
      case HealthDataType.bloodPressure:
        return 'monitor_heart';
      case HealthDataType.bloodGlucose:
        return 'bloodtype';
    }
  }

  /// Dispose of resources
  void dispose() {
    _permissionMonitorTimer?.cancel();
    _eventController.close();
  }
}