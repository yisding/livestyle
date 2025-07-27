import 'dart:async';
import 'dart:io';
import 'package:health/health.dart';
import '../models/health_data_point.dart' as app_models;

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
  
  /// Singleton instance
  static HealthConnectService? _instance;
  
  /// Get the singleton instance
  static HealthConnectService get instance {
    _instance ??= _createPlatformService();
    return _instance!;
  }
  
  /// Factory method to create platform-specific service
  static HealthConnectService _createPlatformService() {
    if (Platform.isAndroid) {
      return HealthConnectServiceImpl();
    } else {
      return HealthConnectServiceStub();
    }
  }
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
      // Check if Health Connect is installed and available
      return _health.isDataTypeAvailable(HealthDataType.STEPS);
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<bool> hasPermissions(List<app_models.HealthDataType> types) async {
    if (!isPlatformSupported) return false;
    
    try {
      final healthTypes = types.map(_mapToHealthDataType).toList();
      final permissions = healthTypes.map((type) => HealthDataAccess.READ).toList();
      
      return await _health.hasPermissions(healthTypes, permissions: permissions) ?? false;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<bool> requestPermissions(List<app_models.HealthDataType> types) async {
    if (!isPlatformSupported) return false;
    
    try {
      final healthTypes = types.map(_mapToHealthDataType).toList();
      final permissions = healthTypes.map((type) => HealthDataAccess.READ).toList();
      
      final granted = await _health.requestAuthorization(healthTypes, permissions: permissions);
      
      if (granted) {
        // Emit permission changed event
        final permissionMap = <app_models.HealthDataType, bool>{};
        for (final type in types) {
          permissionMap[type] = true;
        }
        _eventController.add(PermissionChangedEvent(permissionMap));
      }
      
      return granted;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<List<app_models.HealthDataPoint>> getHealthData(
    List<app_models.HealthDataType> types,
    DateTime startTime,
    DateTime endTime,
  ) async {
    if (!isPlatformSupported) return [];
    
    try {
      final healthTypes = types.map(_mapToHealthDataType).toList();
      final healthData = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: healthTypes,
      );
      
      return healthData.map(_mapToAppHealthDataPoint).toList();
    } catch (e) {
      return [];
    }
  }
  
  @override
  Future<bool> writeHealthData(List<app_models.HealthDataPoint> dataPoints) async {
    // Write operations are not supported - this is a read-only implementation
    return false;
  }
  
  @override
  Future<void> revokePermissions() async {
    if (!isPlatformSupported) return;
    
    try {
      await _health.revokePermissions();
      _eventController.add(PermissionChangedEvent({}));
    } catch (e) {
      // Handle error silently
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
  app_models.HealthDataPoint _mapToAppHealthDataPoint(HealthDataPoint healthPoint) {
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
  Future<bool> hasPermissions(List<app_models.HealthDataType> types) async => false;
  
  @override
  Future<bool> requestPermissions(List<app_models.HealthDataType> types) async => false;
  
  @override
  Future<List<app_models.HealthDataPoint>> getHealthData(
    List<app_models.HealthDataType> types,
    DateTime startTime,
    DateTime endTime,
  ) async => [];
  
  @override
  Future<bool> writeHealthData(List<app_models.HealthDataPoint> dataPoints) async => false;
  
  @override
  Future<void> revokePermissions() async {}
  
  @override
  Stream<HealthConnectEvent> get healthConnectEvents => _eventController.stream;
  
  void dispose() {
    _eventController.close();
  }
}