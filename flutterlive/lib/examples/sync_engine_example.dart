import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/health_connect_sync_service.dart';
import '../services/health_connect_service.dart';
import '../services/firestore_service.dart';
import '../models/health_data_point.dart';
import '../repositories/health_data_repository.dart';
import '../repositories/health_data_repository_factory.dart';

/// Example demonstrating the Health Connect synchronization engine
class SyncEngineExample {
  late final HealthDataRepository _repository;
  late final HealthConnectSyncService _syncService;

  /// Initialize the sync engine example
  Future<void> initialize() async {
    try {
      // Create repository with sync service
      _repository = HealthDataRepositoryFactory.createForTesting(
        healthConnectService: HealthConnectServiceStub(), // Use stub for demo
        firestoreService: FirestoreService(),
        syncConfig: const SyncConfiguration(
          batchSize: 100,
          historicalDays: 30,
          enableDeduplication: true,
          enableIncrementalSync: true,
        ),
      );

      // Initialize the repository
      await _repository.initialize();

      developer.log('Sync engine example initialized');
    } catch (e) {
      developer.log('Failed to initialize sync engine: $e');
      rethrow;
    }
  }

  /// Demonstrate initial historical data sync
  Future<void> demonstrateInitialSync() async {
    try {
      developer.log('Starting initial sync demonstration...');

      // Listen to sync events
      _repository.syncEvents.listen((event) {
        if (event is SyncStartedEvent) {
          developer.log('Sync started: ${event.isInitialSync ? "Initial" : "Incremental"}');
        } else if (event is SyncProgressEvent) {
          developer.log('Sync progress: ${event.processed}/${event.total} (${event.currentType.name})');
        } else if (event is SyncCompletedEvent) {
          developer.log('Sync completed: ${event.result.newRecords} new records');
        } else if (event is SyncErrorEvent) {
          developer.log('Sync error: ${event.error}');
        }
      });

      // Perform initial sync for last 30 days
      final result = await _repository.performInitialSync(
        types: [
          HealthDataType.weight,
          HealthDataType.steps,
          HealthDataType.heartRate,
        ],
        startTime: DateTime.now().subtract(const Duration(days: 30)),
        endTime: DateTime.now(),
      );

      developer.log('Initial sync result:');
      developer.log('  Success: ${result.success}');
      developer.log('  Total records: ${result.totalRecords}');
      developer.log('  New records: ${result.newRecords}');
      developer.log('  Duplicates skipped: ${result.duplicatesSkipped}');
      developer.log('  Processing time: ${result.processingTime}');
      developer.log('  Success rate: ${(result.successRate * 100).toStringAsFixed(1)}%');

      if (result.hasErrors) {
        developer.log('  Errors: ${result.errors.join(", ")}');
      }

      // Show records by type
      result.recordsByType.forEach((type, count) {
        developer.log('  ${type.name}: $count records');
      });
    } catch (e) {
      developer.log('Initial sync demonstration failed: $e');
    }
  }

  /// Demonstrate incremental sync
  Future<void> demonstrateIncrementalSync() async {
    try {
      developer.log('Starting incremental sync demonstration...');

      // Perform incremental sync
      final result = await _repository.performIncrementalSync(
        types: [
          HealthDataType.weight,
          HealthDataType.steps,
        ],
      );

      developer.log('Incremental sync result:');
      developer.log('  Success: ${result.success}');
      developer.log('  New records: ${result.newRecords}');
      developer.log('  Processing time: ${result.processingTime}');

      if (result.hasErrors) {
        developer.log('  Errors: ${result.errors.join(", ")}');
      }
    } catch (e) {
      developer.log('Incremental sync demonstration failed: $e');
    }
  }

  /// Demonstrate batch processing with large dataset
  Future<void> demonstrateBatchProcessing() async {
    try {
      developer.log('Starting batch processing demonstration...');

      // Simulate large dataset sync
      final result = await _repository.performInitialSync(
        types: [
          HealthDataType.steps,
          HealthDataType.heartRate,
          HealthDataType.calories,
        ],
        startTime: DateTime.now().subtract(const Duration(days: 90)),
        endTime: DateTime.now(),
      );

      developer.log('Batch processing result:');
      developer.log('  Total records processed: ${result.totalRecords}');
      developer.log('  Processing time: ${result.processingTime}');
      developer.log('  Average records per second: ${(result.totalRecords / result.processingTime.inSeconds).toStringAsFixed(1)}');
    } catch (e) {
      developer.log('Batch processing demonstration failed: $e');
    }
  }

  /// Demonstrate error recovery
  Future<void> demonstrateErrorRecovery() async {
    try {
      developer.log('Starting error recovery demonstration...');

      // This will fail with stub service, demonstrating error handling
      final result = await _repository.syncHealthConnectData(
        types: [HealthDataType.weight],
      );

      if (!result.success) {
        developer.log('Sync failed as expected with stub service');
        developer.log('Error recovery mechanisms:');
        developer.log('  - Graceful error handling');
        developer.log('  - Detailed error reporting');
        developer.log('  - Retry capabilities');
        developer.log('  - Partial success tracking');
      }
    } catch (e) {
      developer.log('Error recovery demonstration: $e');
    }
  }

  /// Demonstrate sync status tracking
  Future<void> demonstrateSyncStatusTracking() async {
    try {
      developer.log('Starting sync status tracking demonstration...');

      // Monitor sync status
      developer.log('Current sync status: ${_repository.syncStatus}');

      // Watch sync status changes
      _repository.watchHealthConnectSyncStatus().listen((status) {
        if (status != null) {
          developer.log('Sync status updated:');
          developer.log('  Available: ${status['isAvailable'] ?? false}');
          developer.log('  In progress: ${status['syncInProgress'] ?? false}');
          developer.log('  Total synced: ${status['totalRecordsSynced'] ?? 0}');
          
          if (status['lastError'] != null) {
            developer.log('  Last error: ${status['lastError']}');
          }
          
          if (status['lastSuccessfulSync'] != null) {
            final lastSync = (status['lastSuccessfulSync'] as Timestamp).toDate();
            developer.log('  Last successful sync: $lastSync');
          }
        }
      });
    } catch (e) {
      developer.log('Sync status tracking demonstration failed: $e');
    }
  }

  /// Demonstrate data deduplication
  Future<void> demonstrateDeduplication() async {
    try {
      developer.log('Starting deduplication demonstration...');

      // Create test data with potential duplicates
      final testData = [
        _createTestDataPoint(HealthDataType.weight, 70.0, DateTime.now()),
        _createTestDataPoint(HealthDataType.weight, 70.01, DateTime.now()), // Near duplicate
        _createTestDataPoint(HealthDataType.weight, 71.0, DateTime.now().add(const Duration(hours: 1))),
      ];

      // Save test data
      await _repository.saveHealthData(testData);

      // Perform sync which will apply deduplication
      final result = await _repository.syncHealthConnectData();

      developer.log('Deduplication result:');
      developer.log('  Duplicates skipped: ${result.duplicatesSkipped}');
      developer.log('  Unique records: ${result.newRecords}');
    } catch (e) {
      developer.log('Deduplication demonstration failed: $e');
    }
  }

  /// Demonstrate reset and resync functionality
  Future<void> demonstrateResetAndResync() async {
    try {
      developer.log('Starting reset and resync demonstration...');

      // Reset all Health Connect data and perform fresh sync
      await _repository.resetHealthConnectData();

      developer.log('Reset and resync completed');
      developer.log('All Health Connect data has been cleared and resynced');
    } catch (e) {
      developer.log('Reset and resync demonstration failed: $e');
    }
  }

  /// Run all demonstrations
  Future<void> runAllDemonstrations() async {
    await initialize();
    
    await demonstrateInitialSync();
    await Future.delayed(const Duration(seconds: 1));
    
    await demonstrateIncrementalSync();
    await Future.delayed(const Duration(seconds: 1));
    
    await demonstrateBatchProcessing();
    await Future.delayed(const Duration(seconds: 1));
    
    await demonstrateErrorRecovery();
    await Future.delayed(const Duration(seconds: 1));
    
    await demonstrateSyncStatusTracking();
    await Future.delayed(const Duration(seconds: 1));
    
    await demonstrateDeduplication();
    await Future.delayed(const Duration(seconds: 1));
    
    await demonstrateResetAndResync();
    
    // Cleanup
    _repository.dispose();
    
    developer.log('All sync engine demonstrations completed');
  }

  /// Helper method to create test data points
  HealthDataPoint _createTestDataPoint(HealthDataType type, double value, DateTime timestamp) {
    final now = DateTime.now();
    return HealthDataPoint(
      id: '${type.name}_${timestamp.millisecondsSinceEpoch}',
      type: type,
      value: value,
      unit: type == HealthDataType.weight ? 'kg' : 'count',
      timestamp: timestamp,
      source: HealthDataSource.manual,
      createdAt: now,
      updatedAt: now,
    );
  }
}

/// Example usage
void main() async {
  final example = SyncEngineExample();
  await example.runAllDemonstrations();
}