import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutterlive/services/health_connect_sync_service.dart';
import 'package:flutterlive/services/health_connect_service.dart';
import 'package:flutterlive/services/firestore_service.dart';
import 'package:flutterlive/models/health_data_point.dart';

// Generate mocks
@GenerateMocks([HealthConnectService, FirestoreService])
import 'health_connect_sync_service_test.mocks.dart';

void main() {
  group('HealthConnectSyncService', () {
    late MockHealthConnectService mockHealthConnectService;
    late MockFirestoreService mockFirestoreService;
    late HealthConnectSyncService syncService;
    late SyncConfiguration testConfig;

    setUp(() {
      mockHealthConnectService = MockHealthConnectService();
      mockFirestoreService = MockFirestoreService();
      
      testConfig = const SyncConfiguration(
        batchSize: 100,
        syncInterval: Duration(minutes: 1),
        retryDelay: Duration(seconds: 1),
        maxRetries: 2,
        historicalDays: 7,
        enableIncrementalSync: false, // Disable for testing
        enableDeduplication: true,
        deduplicationWindow: Duration(minutes: 1),
        deduplicationThreshold: 0.01,
      );

      syncService = HealthConnectSyncService(
        healthConnectService: mockHealthConnectService,
        firestoreService: mockFirestoreService,
        config: testConfig,
      );
    });

    tearDown(() {
      syncService.dispose();
    });

    group('initialization', () {
      test('should initialize successfully when Health Connect is available', () async {
        // Arrange
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockFirestoreService.getHealthConnectSyncStatus())
            .thenAnswer((_) async => null);

        // Act
        await syncService.initialize();

        // Assert
        expect(syncService.status, SyncStatus.idle);
        verify(mockHealthConnectService.isAvailable()).called(1);
        verify(mockFirestoreService.getHealthConnectSyncStatus()).called(1);
      });

      test('should set status to disabled when Health Connect is not available', () async {
        // Arrange
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => false);
        when(mockFirestoreService.updateHealthConnectSyncStatus(
          isAvailable: false,
          lastError: 'Health Connect not available on this platform',
        )).thenAnswer((_) async {});

        // Act
        await syncService.initialize();

        // Assert
        expect(syncService.status, SyncStatus.disabled);
        verify(mockFirestoreService.updateHealthConnectSyncStatus(
          isAvailable: false,
          lastError: 'Health Connect not available on this platform',
        )).called(1);
      });
    });

    group('initial sync', () {
      test('should perform initial sync successfully', () async {
        // Arrange
        final testData = [
          _createTestHealthDataPoint(HealthDataType.weight, 70.0),
          _createTestHealthDataPoint(HealthDataType.steps, 5000.0),
        ];

        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.hasPermissions(any)).thenAnswer((_) async => true);
        when(mockHealthConnectService.getHealthData(any, any, any))
            .thenAnswer((_) async => testData);
        when(mockFirestoreService.updateHealthConnectSyncStatus(
          syncInProgress: true,
          lastSyncTimestamp: any,
          lastError: null,
        )).thenAnswer((_) async {});
        when(mockFirestoreService.updateHealthConnectSyncStatus(
          syncInProgress: false,
          lastSuccessfulSync: any,
          totalRecordsSynced: any,
          lastError: any,
        )).thenAnswer((_) async {});
        when(mockFirestoreService.healthConnectDataExists(any))
            .thenAnswer((_) async => false);
        when(mockFirestoreService.saveHealthConnectData(any))
            .thenAnswer((_) async {});

        // Act
        final result = await syncService.performInitialSync();

        // Assert
        expect(result.success, true);
        expect(result.newRecords, 2);
        expect(result.totalRecords, 2);
        expect(result.errors, isEmpty);
        expect(syncService.status, SyncStatus.idle);

        verify(mockFirestoreService.saveHealthConnectData(any)).called(1);
      });

      test('should handle permission errors during initial sync', () async {
        // Arrange
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.hasPermissions(any)).thenAnswer((_) async => false);
        when(mockFirestoreService.updateHealthConnectSyncStatus(
          syncInProgress: true,
          lastSyncTimestamp: any,
          lastError: null,
        )).thenAnswer((_) async {});
        when(mockFirestoreService.updateHealthConnectSyncStatus(
          syncInProgress: false,
          lastError: any,
        )).thenAnswer((_) async {});

        // Act & Assert
        expect(
          () => syncService.performInitialSync(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle batch processing for large datasets', () async {
        // Arrange
        final largeDataset = List.generate(250, (index) => 
            _createTestHealthDataPoint(HealthDataType.steps, index.toDouble()));

        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.hasPermissions(any)).thenAnswer((_) async => true);
        when(mockHealthConnectService.getHealthData(any, any, any))
            .thenAnswer((_) async => largeDataset);
        when(mockFirestoreService.updateHealthConnectSyncStatus(
          syncInProgress: any,
          lastSyncTimestamp: any,
          lastError: any,
        )).thenAnswer((_) async {});
        when(mockFirestoreService.updateHealthConnectSyncStatus(
          syncInProgress: any,
          lastSuccessfulSync: any,
          totalRecordsSynced: any,
          lastError: any,
        )).thenAnswer((_) async {});
        when(mockFirestoreService.healthConnectDataExists(any))
            .thenAnswer((_) async => false);
        when(mockFirestoreService.saveHealthConnectData(any))
            .thenAnswer((_) async {});

        // Act
        final result = await syncService.performInitialSync();

        // Assert
        expect(result.success, true);
        expect(result.newRecords, 250);
        
        // Should be called 3 times: 100 + 100 + 50 (batch size is 100)
        verify(mockFirestoreService.saveHealthConnectData(any)).called(3);
      });
    });

    group('incremental sync', () {
      test('should perform incremental sync successfully', () async {
        // Arrange
        final testData = [
          _createTestHealthDataPoint(HealthDataType.weight, 71.0),
        ];

        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.hasPermissions(any)).thenAnswer((_) async => true);
        when(mockHealthConnectService.getHealthData(any, any, any))
            .thenAnswer((_) async => testData);
        when(mockFirestoreService.updateHealthConnectSyncStatus(
          lastSuccessfulSync: any,
          lastError: any,
        )).thenAnswer((_) async {});
        when(mockFirestoreService.healthConnectDataExists(any))
            .thenAnswer((_) async => false);
        when(mockFirestoreService.saveHealthConnectData(any))
            .thenAnswer((_) async {});

        // Act
        final result = await syncService.performIncrementalSync();

        // Assert
        expect(result.success, true);
        expect(result.newRecords, 1);
        expect(result.totalRecords, 1);
        expect(result.errors, isEmpty);
      });

      test('should skip duplicate data during incremental sync', () async {
        // Arrange
        final testData = [
          _createTestHealthDataPoint(HealthDataType.weight, 71.0),
        ];

        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.hasPermissions(any)).thenAnswer((_) async => true);
        when(mockHealthConnectService.getHealthData(any, any, any))
            .thenAnswer((_) async => testData);
        when(mockFirestoreService.updateHealthConnectSyncStatus(
          lastSuccessfulSync: any,
          lastError: any,
        )).thenAnswer((_) async {});
        when(mockFirestoreService.healthConnectDataExists(any))
            .thenAnswer((_) async => true); // Data already exists
        when(mockFirestoreService.saveHealthConnectData(any))
            .thenAnswer((_) async {});

        // Act
        final result = await syncService.performIncrementalSync();

        // Assert
        expect(result.success, true);
        expect(result.newRecords, 0);
        expect(result.duplicatesSkipped, 1);
        
        // Should not save any data since it's a duplicate
        verifyNever(mockFirestoreService.saveHealthConnectData(any));
      });
    });

    group('reset and resync', () {
      test('should reset data and perform fresh sync', () async {
        // Arrange
        final testData = [
          _createTestHealthDataPoint(HealthDataType.weight, 70.0),
        ];

        when(mockFirestoreService.deleteAllHealthConnectData())
            .thenAnswer((_) async {});
        when(mockFirestoreService.updateHealthConnectSyncStatus(
          lastSuccessfulSync: null,
          totalRecordsSynced: 0,
          lastError: null,
        )).thenAnswer((_) async {});
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.hasPermissions(any)).thenAnswer((_) async => true);
        when(mockHealthConnectService.getHealthData(any, any, any))
            .thenAnswer((_) async => testData);
        when(mockFirestoreService.updateHealthConnectSyncStatus(
          syncInProgress: any,
          lastSyncTimestamp: any,
          lastError: any,
        )).thenAnswer((_) async {});
        when(mockFirestoreService.updateHealthConnectSyncStatus(
          syncInProgress: any,
          lastSuccessfulSync: any,
          totalRecordsSynced: any,
          lastError: any,
        )).thenAnswer((_) async {});
        when(mockFirestoreService.healthConnectDataExists(any))
            .thenAnswer((_) async => false);
        when(mockFirestoreService.saveHealthConnectData(any))
            .thenAnswer((_) async {});

        // Act
        final result = await syncService.resetAndResync();

        // Assert
        expect(result.success, true);
        verify(mockFirestoreService.deleteAllHealthConnectData()).called(1);
        verify(mockFirestoreService.saveHealthConnectData(any)).called(1);
      });
    });

    group('error handling', () {
      test('should handle Health Connect service errors gracefully', () async {
        // Arrange
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.hasPermissions(any)).thenAnswer((_) async => true);
        when(mockHealthConnectService.getHealthData(any, any, any))
            .thenThrow(Exception('Health Connect error'));
        when(mockFirestoreService.updateHealthConnectSyncStatus(
          syncInProgress: any,
          lastSyncTimestamp: any,
          lastError: any,
        )).thenAnswer((_) async {});

        // Act
        final result = await syncService.performInitialSync();

        // Assert
        expect(result.success, false);
        expect(result.errors, isNotEmpty);
        expect(result.errors.first, contains('Health Connect error'));
      });

      test('should handle Firestore errors gracefully', () async {
        // Arrange
        final testData = [
          _createTestHealthDataPoint(HealthDataType.weight, 70.0),
        ];

        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.hasPermissions(any)).thenAnswer((_) async => true);
        when(mockHealthConnectService.getHealthData(any, any, any))
            .thenAnswer((_) async => testData);
        when(mockFirestoreService.updateHealthConnectSyncStatus(
          syncInProgress: any,
          lastSyncTimestamp: any,
          lastError: any,
        )).thenAnswer((_) async {});
        when(mockFirestoreService.healthConnectDataExists(any))
            .thenAnswer((_) async => false);
        when(mockFirestoreService.saveHealthConnectData(any))
            .thenThrow(Exception('Firestore error'));

        // Act
        final result = await syncService.performInitialSync();

        // Assert
        expect(result.success, false);
        expect(result.errors, isNotEmpty);
        expect(result.errors.first, contains('Firestore error'));
      });
    });

    group('events', () {
      test('should emit sync events during operation', () async {
        // Arrange
        final testData = [
          _createTestHealthDataPoint(HealthDataType.weight, 70.0),
        ];
        final events = <SyncEvent>[];

        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.hasPermissions(any)).thenAnswer((_) async => true);
        when(mockHealthConnectService.getHealthData(any, any, any))
            .thenAnswer((_) async => testData);
        when(mockFirestoreService.updateHealthConnectSyncStatus(
          syncInProgress: any,
          lastSyncTimestamp: any,
          lastError: any,
        )).thenAnswer((_) async {});
        when(mockFirestoreService.updateHealthConnectSyncStatus(
          syncInProgress: any,
          lastSuccessfulSync: any,
          totalRecordsSynced: any,
          lastError: any,
        )).thenAnswer((_) async {});
        when(mockFirestoreService.healthConnectDataExists(any))
            .thenAnswer((_) async => false);
        when(mockFirestoreService.saveHealthConnectData(any))
            .thenAnswer((_) async {});

        // Listen to events
        syncService.events.listen((event) => events.add(event));

        // Act
        await syncService.performInitialSync();

        // Assert
        expect(events, isNotEmpty);
        expect(events.any((e) => e is SyncStartedEvent), true);
        expect(events.any((e) => e is SyncCompletedEvent), true);
      });
    });
  });
}

/// Helper function to create test health data points
HealthDataPoint _createTestHealthDataPoint(HealthDataType type, double value) {
  final now = DateTime.now();
  return HealthDataPoint(
    id: '${type.name}_${now.millisecondsSinceEpoch}',
    type: type,
    value: value,
    unit: type == HealthDataType.weight ? 'kg' : 'count',
    timestamp: now,
    source: HealthDataSource.healthConnect,
    healthConnectId: 'hc_${type.name}_${now.millisecondsSinceEpoch}',
    createdAt: now,
    updatedAt: now,
  );
}