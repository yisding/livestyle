import 'package:flutter_test/flutter_test.dart';
import 'package:flutterlive/services/health_connect_sync_service.dart';
import 'package:flutterlive/services/health_connect_service.dart';
import 'package:flutterlive/models/health_data_point.dart';
import 'package:flutterlive/repositories/health_data_repository.dart';

void main() {
  group('Sync Engine Integration Tests', () {
    test('should validate sync status enum values', () {
      // Act & Assert
      expect(SyncStatus.values, contains(SyncStatus.idle));
      expect(SyncStatus.values, contains(SyncStatus.initializing));
      expect(SyncStatus.values, contains(SyncStatus.syncing));
      expect(SyncStatus.values, contains(SyncStatus.error));
      expect(SyncStatus.values, contains(SyncStatus.disabled));
    });

    test('should create proper deduplication configuration', () {
      // Act
      const config = DeduplicationConfig(
        timeWindow: Duration(minutes: 10),
        valueThreshold: 0.05,
        enableDeduplication: true,
      );

      // Assert
      expect(config.timeWindow, const Duration(minutes: 10));
      expect(config.valueThreshold, 0.05);
      expect(config.enableDeduplication, true);
    });

    test('should create sync result with proper data', () {
      // Arrange
      final now = DateTime.now();
      final recordsByType = {
        HealthDataType.weight: 5,
        HealthDataType.steps: 10,
      };

      // Act
      final result = SyncResult(
        success: true,
        totalRecords: 15,
        newRecords: 12,
        duplicatesSkipped: 3,
        errorsCount: 0,
        errors: const [],
        processingTime: const Duration(seconds: 5),
        syncTimestamp: now,
        recordsByType: recordsByType,
      );

      // Assert
      expect(result.success, true);
      expect(result.totalRecords, 15);
      expect(result.newRecords, 12);
      expect(result.duplicatesSkipped, 3);
      expect(result.successRate, closeTo(0.8, 0.01)); // 12/15
      expect(result.hasErrors, false);
    });

    test('should handle sync configuration validation', () {
      // Act
      const config = SyncConfiguration(
        batchSize: 500,
        syncInterval: Duration(hours: 4),
        retryDelay: Duration(minutes: 5),
        maxRetries: 3,
        historicalDays: 90,
        enableIncrementalSync: true,
        enableDeduplication: true,
        deduplicationWindow: Duration(minutes: 5),
        deduplicationThreshold: 0.01,
      );

      // Assert
      expect(config.batchSize, 500);
      expect(config.syncInterval, const Duration(hours: 4));
      expect(config.retryDelay, const Duration(minutes: 5));
      expect(config.maxRetries, 3);
      expect(config.historicalDays, 90);
      expect(config.enableIncrementalSync, true);
      expect(config.enableDeduplication, true);
      expect(config.deduplicationWindow, const Duration(minutes: 5));
      expect(config.deduplicationThreshold, 0.01);
    });

    test('should create sync events with proper data', () {
      // Arrange
      final now = DateTime.now();

      // Act
      final startedEvent = SyncStartedEvent(now, true);
      final progressEvent = SyncProgressEvent(5, 10, HealthDataType.weight);
      final errorEvent = SyncErrorEvent('Test error', true);

      // Assert
      expect(startedEvent.timestamp, now);
      expect(startedEvent.isInitialSync, true);
      expect(progressEvent.processed, 5);
      expect(progressEvent.total, 10);
      expect(progressEvent.currentType, HealthDataType.weight);
      expect(errorEvent.error, 'Test error');
      expect(errorEvent.isRetryable, true);
    });

    test('should validate sync status enum values', () {
      // Act & Assert
      expect(SyncStatus.values, contains(SyncStatus.idle));
      expect(SyncStatus.values, contains(SyncStatus.initializing));
      expect(SyncStatus.values, contains(SyncStatus.syncing));
      expect(SyncStatus.values, contains(SyncStatus.error));
      expect(SyncStatus.values, contains(SyncStatus.disabled));
    });
  });
}