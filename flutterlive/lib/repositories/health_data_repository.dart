import 'dart:async';
import 'dart:developer' as developer;
import '../models/health_data_point.dart';
import '../services/health_connect_service.dart';
import '../services/firestore_service.dart';
import '../services/health_connect_sync_service.dart';

/// Exception thrown by the Health Data Repository
class HealthDataRepositoryException implements Exception {
  final String message;
  final String? code;

  const HealthDataRepositoryException(this.message, [this.code]);

  @override
  String toString() =>
      'HealthDataRepositoryException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Configuration for data deduplication
class DeduplicationConfig {
  final Duration timeWindow;
  final double valueThreshold;
  final bool enableDeduplication;

  const DeduplicationConfig({
    this.timeWindow = const Duration(minutes: 5),
    this.valueThreshold = 0.01,
    this.enableDeduplication = true,
  });
}

/// Result of a batch operation
class BatchOperationResult {
  final int totalProcessed;
  final int successful;
  final int failed;
  final List<String> errors;
  final Duration processingTime;

  const BatchOperationResult({
    required this.totalProcessed,
    required this.successful,
    required this.failed,
    required this.errors,
    required this.processingTime,
  });

  bool get hasErrors => errors.isNotEmpty;
  double get successRate => totalProcessed > 0 ? successful / totalProcessed : 0.0;
}

/// Abstract interface for Health Data Repository
abstract class HealthDataRepository {
  /// Get health data from specified source(s) for given types and time range
  Future<List<HealthDataPoint>> getHealthData(
    List<HealthDataType> types,
    DateTime startTime,
    DateTime endTime, {
    HealthDataSource? source,
    int? limit,
  });

  /// Save health data points to appropriate data source
  Future<void> saveHealthData(List<HealthDataPoint> dataPoints);

  /// Delete all Health Connect data and trigger fresh sync
  Future<void> resetHealthConnectData();

  /// Sync Health Connect data with local storage
  Future<SyncResult> syncHealthConnectData({
    List<HealthDataType>? types,
    DateTime? startTime,
    DateTime? endTime,
  });

  /// Perform initial historical data sync
  Future<SyncResult> performInitialSync({
    List<HealthDataType>? types,
    DateTime? startTime,
    DateTime? endTime,
  });

  /// Perform incremental data sync
  Future<SyncResult> performIncrementalSync({
    List<HealthDataType>? types,
  });

  /// Get synchronization events stream
  Stream<SyncEvent> get syncEvents;

  /// Get current sync status
  SyncStatus get syncStatus;

  /// Stream health data changes for specified types
  Stream<List<HealthDataPoint>> watchHealthData(
    List<HealthDataType> types, {
    HealthDataSource? source,
    int? limit,
  });

  /// Get data source preferences for each health data type
  Future<Map<HealthDataType, HealthDataSource>> getDataSourcePreferences();

  /// Set data source preference for a specific health data type
  Future<void> setDataSourcePreference(
    HealthDataType type,
    HealthDataSource preferredSource,
  );

  /// Stream data source preferences changes
  Stream<Map<HealthDataType, HealthDataSource>> watchDataSourcePreferences();

  /// Get the latest data point for a specific type, respecting user preferences
  Future<HealthDataPoint?> getLatestDataPoint(HealthDataType type);

  /// Check if Health Connect permissions are available
  Future<bool> hasHealthConnectPermissions(List<HealthDataType> types);

  /// Request Health Connect permissions
  Future<bool> requestHealthConnectPermissions(List<HealthDataType> types);

  /// Get Health Connect sync status
  Future<Map<String, dynamic>?> getHealthConnectSyncStatus();

  /// Stream Health Connect sync status changes
  Stream<Map<String, dynamic>?> watchHealthConnectSyncStatus();

  /// Initialize the repository and sync service
  Future<void> initialize();

  /// Dispose of resources
  void dispose();
}

/// Implementation of Health Data Repository with dual data source support
class HealthDataRepositoryImpl implements HealthDataRepository {
  final HealthConnectService _healthConnectService;
  final FirestoreService _firestoreService;
  final HealthConnectSyncService _syncService;
  final DeduplicationConfig _deduplicationConfig;

  HealthDataRepositoryImpl({
    required HealthConnectService healthConnectService,
    required FirestoreService firestoreService,
    HealthConnectSyncService? syncService,
    DeduplicationConfig? deduplicationConfig,
  })  : _healthConnectService = healthConnectService,
        _firestoreService = firestoreService,
        _syncService = syncService ?? HealthConnectSyncService(
          healthConnectService: healthConnectService,
          firestoreService: firestoreService,
        ),
        _deduplicationConfig = deduplicationConfig ?? const DeduplicationConfig();

  @override
  Future<List<HealthDataPoint>> getHealthData(
    List<HealthDataType> types,
    DateTime startTime,
    DateTime endTime, {
    HealthDataSource? source,
    int? limit,
  }) async {
    try {
      final typeStrings = types.map((t) => t.name).toList();

      if (source == HealthDataSource.healthConnect) {
        return await _firestoreService.getHealthConnectData(
          types: typeStrings,
          startTime: startTime,
          endTime: endTime,
          limit: limit,
        );
      } else if (source == HealthDataSource.manual) {
        return await _firestoreService.getManualHealthData(
          types: typeStrings,
          startTime: startTime,
          endTime: endTime,
          limit: limit,
        );
      } else {
        // Return combined data from both sources
        final combinedData = await _firestoreService.getCombinedHealthData(
          types: typeStrings,
          startTime: startTime,
          endTime: endTime,
          limit: limit,
        );

        return _applySeparationLogic(combinedData);
      }
    } catch (e) {
      throw HealthDataRepositoryException(
        'Failed to get health data: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveHealthData(List<HealthDataPoint> dataPoints) async {
    try {
      // Separate data points by source
      final healthConnectData = dataPoints
          .where((point) => point.source == HealthDataSource.healthConnect)
          .toList();
      final manualData = dataPoints
          .where((point) => point.source == HealthDataSource.manual)
          .toList();

      // Save to appropriate collections
      if (healthConnectData.isNotEmpty) {
        await _firestoreService.saveHealthConnectData(healthConnectData);
      }
      if (manualData.isNotEmpty) {
        await _firestoreService.saveManualHealthData(manualData);
      }
    } catch (e) {
      throw HealthDataRepositoryException(
        'Failed to save health data: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> resetHealthConnectData() async {
    try {
      developer.log('Starting Health Connect data reset');
      await _syncService.resetAndResync();
      developer.log('Health Connect data reset completed');
    } catch (e) {
      throw HealthDataRepositoryException(
        'Failed to reset Health Connect data: ${e.toString()}',
      );
    }
  }

  @override
  Future<SyncResult> syncHealthConnectData({
    List<HealthDataType>? types,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      // Use the sync service for data synchronization
      if (startTime != null || endTime != null) {
        // Specific time range sync (initial sync)
        return await _syncService.performInitialSync(
          types: types,
          startTime: startTime,
          endTime: endTime,
        );
      } else {
        // Incremental sync
        return await _syncService.performIncrementalSync(types: types);
      }
    } catch (e) {
      throw HealthDataRepositoryException(
        'Failed to sync Health Connect data: ${e.toString()}',
      );
    }
  }

  @override
  Future<SyncResult> performInitialSync({
    List<HealthDataType>? types,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      return await _syncService.performInitialSync(
        types: types,
        startTime: startTime,
        endTime: endTime,
      );
    } catch (e) {
      throw HealthDataRepositoryException(
        'Failed to perform initial sync: ${e.toString()}',
      );
    }
  }

  @override
  Future<SyncResult> performIncrementalSync({
    List<HealthDataType>? types,
  }) async {
    try {
      return await _syncService.performIncrementalSync(types: types);
    } catch (e) {
      throw HealthDataRepositoryException(
        'Failed to perform incremental sync: ${e.toString()}',
      );
    }
  }

  @override
  Stream<SyncEvent> get syncEvents => _syncService.events;

  @override
  SyncStatus get syncStatus => _syncService.status;

  @override
  Stream<List<HealthDataPoint>> watchHealthData(
    List<HealthDataType> types, {
    HealthDataSource? source,
    int? limit,
  }) {
    final typeStrings = types.map((t) => t.name).toList();

    if (source == HealthDataSource.healthConnect) {
      return _firestoreService.streamHealthConnectData(
        types: typeStrings,
        limit: limit,
      );
    } else if (source == HealthDataSource.manual) {
      return _firestoreService.streamManualHealthData(
        types: typeStrings,
        limit: limit,
      );
    } else {
      // Combine streams from both sources
      return _combineDataStreams(typeStrings, limit);
    }
  }

  @override
  Future<Map<HealthDataType, HealthDataSource>> getDataSourcePreferences() async {
    try {
      final preferences = await _firestoreService.getDataSourcePreferences();
      final result = <HealthDataType, HealthDataSource>{};

      for (final entry in preferences.entries) {
        try {
          final type = HealthDataTypeExtension.fromString(entry.key);
          final source = HealthDataSourceExtension.fromString(entry.value);
          result[type] = source;
        } catch (e) {
          // Skip invalid entries
          continue;
        }
      }

      return result;
    } catch (e) {
      throw HealthDataRepositoryException(
        'Failed to get data source preferences: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> setDataSourcePreference(
    HealthDataType type,
    HealthDataSource preferredSource,
  ) async {
    try {
      final currentPreferences = await _firestoreService.getDataSourcePreferences();
      currentPreferences[type.name] = preferredSource.name;
      await _firestoreService.saveDataSourcePreferences(currentPreferences);
    } catch (e) {
      throw HealthDataRepositoryException(
        'Failed to set data source preference: ${e.toString()}',
      );
    }
  }

  @override
  Stream<Map<HealthDataType, HealthDataSource>> watchDataSourcePreferences() {
    return _firestoreService.streamDataSourcePreferences().map((preferences) {
      final result = <HealthDataType, HealthDataSource>{};

      for (final entry in preferences.entries) {
        try {
          final type = HealthDataTypeExtension.fromString(entry.key);
          final source = HealthDataSourceExtension.fromString(entry.value);
          result[type] = source;
        } catch (e) {
          // Skip invalid entries
          continue;
        }
      }

      return result;
    });
  }

  @override
  Future<HealthDataPoint?> getLatestDataPoint(HealthDataType type) async {
    try {
      final preferences = await getDataSourcePreferences();
      final preferredSource = preferences[type] ?? HealthDataSource.healthConnect;

      if (preferredSource == HealthDataSource.healthConnect) {
        final healthConnectData = await _firestoreService.getLatestHealthConnectData(type.name);
        if (healthConnectData != null) return healthConnectData;
        
        // Fallback to manual data if Health Connect data not available
        return await _firestoreService.getLatestManualData(type.name);
      } else {
        final manualData = await _firestoreService.getLatestManualData(type.name);
        if (manualData != null) return manualData;
        
        // Fallback to Health Connect data if manual data not available
        return await _firestoreService.getLatestHealthConnectData(type.name);
      }
    } catch (e) {
      throw HealthDataRepositoryException(
        'Failed to get latest data point: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> hasHealthConnectPermissions(List<HealthDataType> types) async {
    try {
      return await _healthConnectService.hasPermissions(types);
    } catch (e) {
      throw HealthDataRepositoryException(
        'Failed to check Health Connect permissions: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> requestHealthConnectPermissions(List<HealthDataType> types) async {
    try {
      return await _healthConnectService.requestPermissions(types);
    } catch (e) {
      throw HealthDataRepositoryException(
        'Failed to request Health Connect permissions: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> getHealthConnectSyncStatus() async {
    try {
      return await _firestoreService.getHealthConnectSyncStatus();
    } catch (e) {
      throw HealthDataRepositoryException(
        'Failed to get Health Connect sync status: ${e.toString()}',
      );
    }
  }

  @override
  Stream<Map<String, dynamic>?> watchHealthConnectSyncStatus() {
    return _firestoreService.streamHealthConnectSyncStatus();
  }

  @override
  Future<void> initialize() async {
    try {
      await _syncService.initialize();
      developer.log('Health Data Repository initialized');
    } catch (e) {
      throw HealthDataRepositoryException(
        'Failed to initialize repository: ${e.toString()}',
      );
    }
  }

  @override
  void dispose() {
    _healthConnectService.dispose();
    _syncService.dispose();
  }

  /// Apply data source separation logic to combined data
  List<HealthDataPoint> _applySeparationLogic(List<HealthDataPoint> combinedData) {
    // Group data by type and timestamp to handle conflicts
    final groupedData = <String, List<HealthDataPoint>>{};
    
    for (final dataPoint in combinedData) {
      final key = '${dataPoint.type.name}_${dataPoint.timestamp.millisecondsSinceEpoch}';
      groupedData.putIfAbsent(key, () => []).add(dataPoint);
    }

    final resolvedData = <HealthDataPoint>[];
    
    for (final group in groupedData.values) {
      if (group.length == 1) {
        resolvedData.add(group.first);
      } else {
        // Resolve conflicts - prefer Health Connect data by default
        final healthConnectData = group.where((p) => p.source == HealthDataSource.healthConnect).toList();
        if (healthConnectData.isNotEmpty) {
          resolvedData.add(healthConnectData.first);
        } else {
          resolvedData.add(group.first);
        }
      }
    }

    return resolvedData;
  }

  /// Combine data streams from both Health Connect and manual sources
  Stream<List<HealthDataPoint>> _combineDataStreams(List<String> types, int? limit) {
    final healthConnectStream = _firestoreService.streamHealthConnectData(
      types: types,
      limit: limit,
    );
    
    final manualStream = _firestoreService.streamManualHealthData(
      types: types,
      limit: limit,
    );

    return _combineStreams(healthConnectStream, manualStream, limit);
  }

  /// Combine two streams of health data
  Stream<List<HealthDataPoint>> _combineStreams(
    Stream<List<HealthDataPoint>> stream1,
    Stream<List<HealthDataPoint>> stream2,
    int? limit,
  ) {
    final controller = StreamController<List<HealthDataPoint>>();
    List<HealthDataPoint>? latestData1;
    List<HealthDataPoint>? latestData2;
    
    void emitCombined() {
      if (latestData1 != null && latestData2 != null) {
        final combinedData = <HealthDataPoint>[...latestData1!, ...latestData2!];
        combinedData.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        final result = limit != null && combinedData.length > limit
            ? combinedData.take(limit).toList()
            : combinedData;
            
        controller.add(_applySeparationLogic(result));
      }
    }

    final subscription1 = stream1.listen(
      (data) {
        latestData1 = data;
        emitCombined();
      },
      onError: controller.addError,
    );

    final subscription2 = stream2.listen(
      (data) {
        latestData2 = data;
        emitCombined();
      },
      onError: controller.addError,
    );

    controller.onCancel = () {
      subscription1.cancel();
      subscription2.cancel();
    };

    return controller.stream;
  }
}