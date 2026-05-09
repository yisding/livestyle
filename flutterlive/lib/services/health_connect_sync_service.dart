import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/health_data_point.dart';
import '../services/health_connect_service.dart';
import '../services/firestore_service.dart';

/// Configuration for the synchronization engine
class SyncConfiguration {
  final int batchSize;
  final Duration syncInterval;
  final Duration retryDelay;
  final int maxRetries;
  final int historicalDays;
  final bool enableIncrementalSync;
  final bool enableDeduplication;
  final Duration deduplicationWindow;
  final double deduplicationThreshold;

  const SyncConfiguration({
    this.batchSize = 500,
    this.syncInterval = const Duration(hours: 4),
    this.retryDelay = const Duration(minutes: 5),
    this.maxRetries = 3,
    this.historicalDays = 90,
    this.enableIncrementalSync = true,
    this.enableDeduplication = true,
    this.deduplicationWindow = const Duration(minutes: 5),
    this.deduplicationThreshold = 0.01,
  });
}

/// Result of a synchronization operation
class SyncResult {
  final bool success;
  final int totalRecords;
  final int newRecords;
  final int duplicatesSkipped;
  final int errorsCount;
  final List<String> errors;
  final Duration processingTime;
  final DateTime syncTimestamp;
  final Map<HealthDataType, int> recordsByType;

  const SyncResult({
    required this.success,
    required this.totalRecords,
    required this.newRecords,
    required this.duplicatesSkipped,
    required this.errorsCount,
    required this.errors,
    required this.processingTime,
    required this.syncTimestamp,
    required this.recordsByType,
  });

  double get successRate => totalRecords > 0 ? newRecords / totalRecords : 0.0;
  bool get hasErrors => errors.isNotEmpty;
}

/// Status of the synchronization engine
enum SyncStatus {
  idle,
  initializing,
  syncing,
  error,
  disabled,
}

/// Event emitted by the synchronization engine
abstract class SyncEvent {}

class SyncStartedEvent extends SyncEvent {
  final DateTime timestamp;
  final bool isInitialSync;
  
  SyncStartedEvent(this.timestamp, this.isInitialSync);
}

class SyncProgressEvent extends SyncEvent {
  final int processed;
  final int total;
  final HealthDataType currentType;
  
  SyncProgressEvent(this.processed, this.total, this.currentType);
}

class SyncCompletedEvent extends SyncEvent {
  final SyncResult result;
  
  SyncCompletedEvent(this.result);
}

class SyncErrorEvent extends SyncEvent {
  final String error;
  final bool isRetryable;
  
  SyncErrorEvent(this.error, this.isRetryable);
}

/// Health Connect Data Synchronization Engine
class HealthConnectSyncService {
  final HealthConnectService _healthConnectService;
  final FirestoreService _firestoreService;
  final SyncConfiguration _config;
  
  final StreamController<SyncEvent> _eventController = 
      StreamController<SyncEvent>.broadcast();
  
  Timer? _periodicSyncTimer;
  SyncStatus _status = SyncStatus.idle;
  DateTime? _lastSyncTime;
  int _retryCount = 0;
  bool _disposed = false;

  HealthConnectSyncService({
    required HealthConnectService healthConnectService,
    required FirestoreService firestoreService,
    SyncConfiguration? config,
  })  : _healthConnectService = healthConnectService,
        _firestoreService = firestoreService,
        _config = config ?? const SyncConfiguration();

  /// Current synchronization status
  SyncStatus get status => _status;

  /// Last successful synchronization time
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Stream of synchronization events
  Stream<SyncEvent> get events => _eventController.stream;

  /// Initialize the synchronization engine
  Future<void> initialize() async {
    if (_disposed) return;
    
    try {
      _status = SyncStatus.initializing;
      developer.log('Initializing Health Connect sync service');

      // Check if Health Connect is available
      final isAvailable = await _healthConnectService.isAvailable();
      if (!isAvailable) {
        _status = SyncStatus.disabled;
        await _firestoreService.updateHealthConnectSyncStatus(
          isAvailable: false,
          lastError: 'Health Connect not available on this platform',
        );
        return;
      }

      // Load last sync status
      final syncStatus = await _firestoreService.getHealthConnectSyncStatus();
      if (syncStatus != null && syncStatus['lastSuccessfulSync'] != null) {
        _lastSyncTime = (syncStatus['lastSuccessfulSync'] as Timestamp).toDate();
      }

      // Start periodic sync if enabled
      if (_config.enableIncrementalSync) {
        _startPeriodicSync();
      }

      _status = SyncStatus.idle;
      developer.log('Health Connect sync service initialized');
    } catch (e) {
      _status = SyncStatus.error;
      developer.log('Failed to initialize sync service: $e');
      rethrow;
    }
  }

  /// Perform initial historical data import
  Future<SyncResult> performInitialSync({
    List<HealthDataType>? types,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if (_disposed || _status == SyncStatus.disabled) {
      throw StateError('Sync service is not available');
    }

    final stopwatch = Stopwatch()..start();
    final syncTimestamp = DateTime.now();
    
    try {
      _status = SyncStatus.syncing;
      _eventController.add(SyncStartedEvent(syncTimestamp, true));

      developer.log('Starting initial Health Connect data sync');

      // Update sync status to indicate sync in progress
      await _firestoreService.updateHealthConnectSyncStatus(
        syncInProgress: true,
        lastSyncTimestamp: syncTimestamp,
        lastError: null,
      );

      // Default parameters
      types ??= _getAllSupportedTypes();
      endTime ??= DateTime.now();
      startTime ??= endTime.subtract(Duration(days: _config.historicalDays));

      // Check permissions
      final hasPermissions = await _healthConnectService.hasPermissions(types);
      if (!hasPermissions) {
        throw Exception('Missing Health Connect permissions for requested data types');
      }

      // Perform sync for each data type
      final results = <HealthDataType, int>{};
      final errors = <String>[];
      int totalRecords = 0;
      int newRecords = 0;
      int duplicatesSkipped = 0;

      for (int i = 0; i < types.length; i++) {
        final type = types[i];
        
        try {
          _eventController.add(SyncProgressEvent(i, types.length, type));
          
          final typeResult = await _syncDataType(
            type,
            startTime,
            endTime,
            isInitialSync: true,
          );
          
          results[type] = typeResult.newRecords;
          totalRecords += typeResult.totalRecords;
          newRecords += typeResult.newRecords;
          duplicatesSkipped += typeResult.duplicatesSkipped;
          errors.addAll(typeResult.errors);
          
          developer.log('Synced ${typeResult.newRecords} new ${type.name} records');
        } catch (e) {
          errors.add('Failed to sync ${type.name}: $e');
          developer.log('Error syncing ${type.name}: $e');
        }
      }

      // Update sync status
      final success = errors.isEmpty;
      await _firestoreService.updateHealthConnectSyncStatus(
        syncInProgress: false,
        lastSuccessfulSync: success ? syncTimestamp : null,
        totalRecordsSynced: newRecords,
        lastError: errors.isNotEmpty ? errors.join('; ') : null,
      );

      if (success) {
        _lastSyncTime = syncTimestamp;
        _retryCount = 0;
      }

      final result = SyncResult(
        success: success,
        totalRecords: totalRecords,
        newRecords: newRecords,
        duplicatesSkipped: duplicatesSkipped,
        errorsCount: errors.length,
        errors: errors,
        processingTime: stopwatch.elapsed,
        syncTimestamp: syncTimestamp,
        recordsByType: results,
      );

      _status = success ? SyncStatus.idle : SyncStatus.error;
      _eventController.add(SyncCompletedEvent(result));

      developer.log('Initial sync completed: ${result.newRecords}/${result.totalRecords} records');
      return result;
    } catch (e) {
      _status = SyncStatus.error;
      await _firestoreService.updateHealthConnectSyncStatus(
        syncInProgress: false,
        lastError: e.toString(),
      );
      
      final result = SyncResult(
        success: false,
        totalRecords: 0,
        newRecords: 0,
        duplicatesSkipped: 0,
        errorsCount: 1,
        errors: [e.toString()],
        processingTime: stopwatch.elapsed,
        syncTimestamp: syncTimestamp,
        recordsByType: {},
      );
      
      _eventController.add(SyncCompletedEvent(result));
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  /// Perform incremental synchronization
  Future<SyncResult> performIncrementalSync({
    List<HealthDataType>? types,
  }) async {
    if (_disposed || _status == SyncStatus.disabled) {
      throw StateError('Sync service is not available');
    }

    final stopwatch = Stopwatch()..start();
    final syncTimestamp = DateTime.now();
    
    try {
      _status = SyncStatus.syncing;
      _eventController.add(SyncStartedEvent(syncTimestamp, false));

      developer.log('Starting incremental Health Connect data sync');

      // Determine sync window
      final endTime = DateTime.now();
      final startTime = _lastSyncTime ?? endTime.subtract(const Duration(days: 1));

      // Default parameters
      types ??= _getAllSupportedTypes();

      // Check permissions
      final hasPermissions = await _healthConnectService.hasPermissions(types);
      if (!hasPermissions) {
        throw Exception('Missing Health Connect permissions for requested data types');
      }

      // Perform incremental sync
      final results = <HealthDataType, int>{};
      final errors = <String>[];
      int totalRecords = 0;
      int newRecords = 0;
      int duplicatesSkipped = 0;

      for (int i = 0; i < types.length; i++) {
        final type = types[i];
        
        try {
          _eventController.add(SyncProgressEvent(i, types.length, type));
          
          final typeResult = await _syncDataType(
            type,
            startTime,
            endTime,
            isInitialSync: false,
          );
          
          results[type] = typeResult.newRecords;
          totalRecords += typeResult.totalRecords;
          newRecords += typeResult.newRecords;
          duplicatesSkipped += typeResult.duplicatesSkipped;
          errors.addAll(typeResult.errors);
        } catch (e) {
          errors.add('Failed to sync ${type.name}: $e');
          developer.log('Error syncing ${type.name}: $e');
        }
      }

      // Update sync status
      final success = errors.isEmpty;
      await _firestoreService.updateHealthConnectSyncStatus(
        lastSuccessfulSync: success ? syncTimestamp : null,
        lastError: errors.isNotEmpty ? errors.join('; ') : null,
      );

      if (success) {
        _lastSyncTime = syncTimestamp;
        _retryCount = 0;
      }

      final result = SyncResult(
        success: success,
        totalRecords: totalRecords,
        newRecords: newRecords,
        duplicatesSkipped: duplicatesSkipped,
        errorsCount: errors.length,
        errors: errors,
        processingTime: stopwatch.elapsed,
        syncTimestamp: syncTimestamp,
        recordsByType: results,
      );

      _status = success ? SyncStatus.idle : SyncStatus.error;
      _eventController.add(SyncCompletedEvent(result));

      developer.log('Incremental sync completed: ${result.newRecords}/${result.totalRecords} records');
      return result;
    } catch (e) {
      _status = SyncStatus.error;
      
      final result = SyncResult(
        success: false,
        totalRecords: 0,
        newRecords: 0,
        duplicatesSkipped: 0,
        errorsCount: 1,
        errors: [e.toString()],
        processingTime: stopwatch.elapsed,
        syncTimestamp: syncTimestamp,
        recordsByType: {},
      );
      
      _eventController.add(SyncCompletedEvent(result));
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  /// Reset all Health Connect data and perform fresh sync
  Future<SyncResult> resetAndResync() async {
    if (_disposed || _status == SyncStatus.disabled) {
      throw StateError('Sync service is not available');
    }

    try {
      developer.log('Resetting Health Connect data and performing fresh sync');

      // Delete all existing Health Connect data
      await _firestoreService.deleteAllHealthConnectData();

      // Reset sync status
      await _firestoreService.updateHealthConnectSyncStatus(
        lastSuccessfulSync: null,
        totalRecordsSynced: 0,
        lastError: null,
      );

      _lastSyncTime = null;

      // Perform initial sync
      return await performInitialSync();
    } catch (e) {
      developer.log('Failed to reset and resync: $e');
      rethrow;
    }
  }

  /// Start periodic synchronization
  void _startPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(_config.syncInterval, (timer) {
      if (_status == SyncStatus.idle) {
        _performPeriodicSync();
      }
    });
  }

  /// Perform periodic sync with error recovery
  Future<void> _performPeriodicSync() async {
    try {
      await performIncrementalSync();
    } catch (e) {
      developer.log('Periodic sync failed: $e');
      
      _retryCount++;
      if (_retryCount <= _config.maxRetries) {
        developer.log('Scheduling retry ${_retryCount}/${_config.maxRetries}');
        Timer(_config.retryDelay, () {
          if (_status != SyncStatus.syncing) {
            _performPeriodicSync();
          }
        });
      } else {
        developer.log('Max retries exceeded, stopping periodic sync');
        _eventController.add(SyncErrorEvent(e.toString(), false));
      }
    }
  }

  /// Sync data for a specific type
  Future<SyncResult> _syncDataType(
    HealthDataType type,
    DateTime startTime,
    DateTime endTime,
    {required bool isInitialSync}
  ) async {
    final stopwatch = Stopwatch()..start();
    final errors = <String>[];
    int totalRecords = 0;
    int newRecords = 0;
    int duplicatesSkipped = 0;

    try {
      // Fetch data from Health Connect
      final healthConnectData = await _healthConnectService.getHealthData(
        [type],
        startTime,
        endTime,
      );

      totalRecords = healthConnectData.length;
      
      if (healthConnectData.isEmpty) {
        return SyncResult(
          success: true,
          totalRecords: 0,
          newRecords: 0,
          duplicatesSkipped: 0,
          errorsCount: 0,
          errors: [],
          processingTime: stopwatch.elapsed,
          syncTimestamp: DateTime.now(),
          recordsByType: {type: 0},
        );
      }

      // Apply deduplication if enabled
      List<HealthDataPoint> dataToSync = healthConnectData;
      if (_config.enableDeduplication) {
        dataToSync = await _deduplicateData(healthConnectData);
        duplicatesSkipped = healthConnectData.length - dataToSync.length;
      }

      // Process data in batches
      final batches = _createBatches(dataToSync, _config.batchSize);
      
      for (final batch in batches) {
        try {
          await _firestoreService.saveHealthConnectData(batch);
          newRecords += batch.length;
        } catch (e) {
          errors.add('Failed to save batch for ${type.name}: $e');
        }
      }

      return SyncResult(
        success: errors.isEmpty,
        totalRecords: totalRecords,
        newRecords: newRecords,
        duplicatesSkipped: duplicatesSkipped,
        errorsCount: errors.length,
        errors: errors,
        processingTime: stopwatch.elapsed,
        syncTimestamp: DateTime.now(),
        recordsByType: {type: newRecords},
      );
    } catch (e) {
      errors.add('Failed to sync ${type.name}: $e');
      return SyncResult(
        success: false,
        totalRecords: totalRecords,
        newRecords: newRecords,
        duplicatesSkipped: duplicatesSkipped,
        errorsCount: errors.length,
        errors: errors,
        processingTime: stopwatch.elapsed,
        syncTimestamp: DateTime.now(),
        recordsByType: {type: 0},
      );
    } finally {
      stopwatch.stop();
    }
  }

  /// Deduplicate data points
  Future<List<HealthDataPoint>> _deduplicateData(List<HealthDataPoint> dataPoints) async {
    final deduplicatedData = <HealthDataPoint>[];
    final processedIds = <String>{};

    // Sort by timestamp for efficient processing
    dataPoints.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (final dataPoint in dataPoints) {
      // Skip if we've already processed this exact data point
      if (processedIds.contains(dataPoint.id)) {
        continue;
      }

      // Check if this data point already exists in Firestore
      if (dataPoint.healthConnectId != null) {
        final exists = await _firestoreService.healthConnectDataExists(dataPoint.healthConnectId!);
        if (exists) {
          continue;
        }
      }

      // Check for duplicates within the current batch
      final isDuplicate = deduplicatedData.any((existing) =>
          _isDuplicateDataPoint(existing, dataPoint));

      if (!isDuplicate) {
        deduplicatedData.add(dataPoint);
        processedIds.add(dataPoint.id);
      }
    }

    return deduplicatedData;
  }

  /// Check if two data points are duplicates
  bool _isDuplicateDataPoint(HealthDataPoint existing, HealthDataPoint candidate) {
    // Must be same type
    if (existing.type != candidate.type) return false;

    // Check timestamp window
    final timeDiff = existing.timestamp.difference(candidate.timestamp).abs();
    if (timeDiff > _config.deduplicationWindow) return false;

    // Check value threshold
    final valueDiff = (existing.value - candidate.value).abs();
    if (valueDiff > _config.deduplicationThreshold) return false;

    return true;
  }

  /// Create batches from a list of data points
  List<List<HealthDataPoint>> _createBatches(List<HealthDataPoint> dataPoints, int batchSize) {
    final batches = <List<HealthDataPoint>>[];
    
    for (int i = 0; i < dataPoints.length; i += batchSize) {
      final end = math.min(i + batchSize, dataPoints.length);
      batches.add(dataPoints.sublist(i, end));
    }
    
    return batches;
  }

  /// Get all supported health data types
  List<HealthDataType> _getAllSupportedTypes() {
    return [
      HealthDataType.weight,
      HealthDataType.bodyFatPercentage,
      HealthDataType.bmi,
      HealthDataType.steps,
      HealthDataType.heartRate,
      HealthDataType.workout,
      HealthDataType.calories,
      HealthDataType.sleep,
    ];
  }

  /// Stop periodic synchronization
  void stopPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
  }

  /// Resume periodic synchronization
  void resumePeriodicSync() {
    if (_config.enableIncrementalSync && _periodicSyncTimer == null) {
      _startPeriodicSync();
    }
  }

  /// Dispose of resources
  void dispose() {
    if (_disposed) return;
    
    _disposed = true;
    _periodicSyncTimer?.cancel();
    _eventController.close();
    developer.log('Health Connect sync service disposed');
  }
}