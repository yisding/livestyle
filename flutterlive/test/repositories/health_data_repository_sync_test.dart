import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutterlive/repositories/health_data_repository.dart';
import 'package:flutterlive/services/health_connect_service.dart';
import 'package:flutterlive/services/firestore_service.dart';
import 'package:flutterlive/services/health_connect_sync_service.dart';
import 'package:flutterlive/models/health_data_point.dart';

// Generate mocks
@GenerateMocks([HealthConnectService, FirestoreService, HealthConnectSyncService])
import 'health_data_repository_sync_test.mocks.dart';

void main() {
  group('HealthDataRepository with Sync Service', () {
    late MockHealthConnectService mockHealthConnectService;
    late MockFirestoreService mockFirestoreService;
    late MockHealthConnectSyncService mockSyncService;
    late HealthDataRepository repository;

    setUp(() {
      mockHealthConnectService = MockHealthConnectService();
      mockFirestoreService = MockFirestoreService();
      mockSyncService = MockHealthConnectSyncService();

      repository = HealthDataRepositoryImpl(
        healthConnectService: mockHealthConnectService,
        firestoreService: mockFirestoreService,
        syncService: mockSyncService,
      );
    });

    tearDown(() {
      repository.dispose();
    });

    group('initialization', () {
      test('should initialize sync service', () async {
        // Arrange
        when(mockSyncService.initialize()).thenAnswer((_) async {});

        // Act
        await repository.initialize();

        // Assert
        verify(mockSyncService.initialize()).called(1);
      });

      test('should handle initialization errors', () async {
        // Arrange
        when(mockSyncService.initialize())
            .thenThrow(Exception('Initialization failed'));

        // Act & Assert
        expect(
          () => repository.initialize(),
          throwsA(isA<HealthDataRepositoryException>()),
        );
      });
    });

    group('sync operations', () {
      test('should perform initial sync through sync service', () async {
        // Arrange
        final expectedResult = SyncResult(
          success: true,
          totalRecords: 10,
          newRecords: 8,
          duplicatesSkipped: 2,
          errorsCount: 0,
          errors: [],
          processingTime: const Duration(seconds: 5),
          syncTimestamp: DateTime.now(),
          recordsByType: {HealthDataType.weight: 8},
        );

        when(mockSyncService.performInitialSync(
          types: anyNamed('types'),
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        )).thenAnswer((_) async => expectedResult);

        // Act
        final result = await repository.performInitialSync(
          types: [HealthDataType.weight],
        );

        // Assert
        expect(result.success, true);
        expect(result.newRecords, 8);
        expect(result.totalRecords, 10);
        verify(mockSyncService.performInitialSync(
          types: [HealthDataType.weight],
          startTime: null,
          endTime: null,
        )).called(1);
      });

      test('should perform incremental sync through sync service', () async {
        // Arrange
        final expectedResult = SyncResult(
          success: true,
          totalRecords: 5,
          newRecords: 3,
          duplicatesSkipped: 2,
          errorsCount: 0,
          errors: [],
          processingTime: const Duration(seconds: 2),
          syncTimestamp: DateTime.now(),
          recordsByType: {HealthDataType.steps: 3},
        );

        when(mockSyncService.performIncrementalSync(
          types: anyNamed('types'),
        )).thenAnswer((_) async => expectedResult);

        // Act
        final result = await repository.performIncrementalSync(
          types: [HealthDataType.steps],
        );

        // Assert
        expect(result.success, true);
        expect(result.newRecords, 3);
        verify(mockSyncService.performIncrementalSync(
          types: [HealthDataType.steps],
        )).called(1);
      });

      test('should handle sync with time range as initial sync', () async {
        // Arrange
        final startTime = DateTime.now().subtract(const Duration(days: 7));
        final endTime = DateTime.now();
        final expectedResult = SyncResult(
          success: true,
          totalRecords: 15,
          newRecords: 12,
          duplicatesSkipped: 3,
          errorsCount: 0,
          errors: [],
          processingTime: const Duration(seconds: 8),
          syncTimestamp: DateTime.now(),
          recordsByType: {HealthDataType.weight: 12},
        );

        when(mockSyncService.performInitialSync(
          types: anyNamed('types'),
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        )).thenAnswer((_) async => expectedResult);

        // Act
        final result = await repository.syncHealthConnectData(
          types: [HealthDataType.weight],
          startTime: startTime,
          endTime: endTime,
        );

        // Assert
        expect(result.success, true);
        expect(result.newRecords, 12);
        verify(mockSyncService.performInitialSync(
          types: [HealthDataType.weight],
          startTime: startTime,
          endTime: endTime,
        )).called(1);
      });

      test('should handle sync without time range as incremental sync', () async {
        // Arrange
        final expectedResult = SyncResult(
          success: true,
          totalRecords: 3,
          newRecords: 2,
          duplicatesSkipped: 1,
          errorsCount: 0,
          errors: [],
          processingTime: const Duration(seconds: 1),
          syncTimestamp: DateTime.now(),
          recordsByType: {HealthDataType.heartRate: 2},
        );

        when(mockSyncService.performIncrementalSync(
          types: anyNamed('types'),
        )).thenAnswer((_) async => expectedResult);

        // Act
        final result = await repository.syncHealthConnectData(
          types: [HealthDataType.heartRate],
        );

        // Assert
        expect(result.success, true);
        expect(result.newRecords, 2);
        verify(mockSyncService.performIncrementalSync(
          types: [HealthDataType.heartRate],
        )).called(1);
      });

      test('should reset and resync through sync service', () async {
        // Arrange
        final expectedResult = SyncResult(
          success: true,
          totalRecords: 100,
          newRecords: 95,
          duplicatesSkipped: 5,
          errorsCount: 0,
          errors: [],
          processingTime: const Duration(seconds: 30),
          syncTimestamp: DateTime.now(),
          recordsByType: {
            HealthDataType.weight: 20,
            HealthDataType.steps: 75,
          },
        );

        when(mockSyncService.resetAndResync()).thenAnswer((_) async => expectedResult);

        // Act
        await repository.resetHealthConnectData();

        // Assert
        verify(mockSyncService.resetAndResync()).called(1);
      });
    });

    group('sync status and events', () {
      test('should expose sync status from sync service', () {
        // Arrange
        when(mockSyncService.status).thenReturn(SyncStatus.syncing);

        // Act
        final status = repository.syncStatus;

        // Assert
        expect(status, SyncStatus.syncing);
        verify(mockSyncService.status).called(1);
      });

      test('should expose sync events stream from sync service', () {
        // Arrange
        final testEvent = SyncStartedEvent(DateTime.now(), true);
        when(mockSyncService.events).thenAnswer((_) => Stream.value(testEvent));

        // Act
        final eventsStream = repository.syncEvents;

        // Assert
        expect(eventsStream, emits(testEvent));
        verify(mockSyncService.events).called(1);
      });
    });

    group('error handling', () {
      test('should handle sync service errors in initial sync', () async {
        // Arrange
        when(mockSyncService.performInitialSync(
          types: anyNamed('types'),
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        )).thenThrow(Exception('Sync service error'));

        // Act & Assert
        expect(
          () => repository.performInitialSync(),
          throwsA(isA<HealthDataRepositoryException>()),
        );
      });

      test('should handle sync service errors in incremental sync', () async {
        // Arrange
        when(mockSyncService.performIncrementalSync(
          types: anyNamed('types'),
        )).thenThrow(Exception('Incremental sync error'));

        // Act & Assert
        expect(
          () => repository.performIncrementalSync(),
          throwsA(isA<HealthDataRepositoryException>()),
        );
      });

      test('should handle sync service errors in reset', () async {
        // Arrange
        when(mockSyncService.resetAndResync())
            .thenThrow(Exception('Reset error'));

        // Act & Assert
        expect(
          () => repository.resetHealthConnectData(),
          throwsA(isA<HealthDataRepositoryException>()),
        );
      });
    });

    group('disposal', () {
      test('should dispose both health connect service and sync service', () {
        // Act
        repository.dispose();

        // Assert
        verify(mockHealthConnectService.dispose()).called(1);
        verify(mockSyncService.dispose()).called(1);
      });
    });
  });
}