import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../lib/repositories/health_data_repository.dart';
import '../../lib/services/health_connect_service.dart';
import '../../lib/services/firestore_service.dart';
import '../../lib/models/health_data_point.dart';

import 'health_data_repository_test.mocks.dart';

@GenerateMocks([HealthConnectService, FirestoreService])
void main() {
  group('HealthDataRepositoryImpl', () {
    late MockHealthConnectService mockHealthConnectService;
    late MockFirestoreService mockFirestoreService;
    late HealthDataRepositoryImpl repository;

    setUp(() {
      mockHealthConnectService = MockHealthConnectService();
      mockFirestoreService = MockFirestoreService();
      repository = HealthDataRepositoryImpl(
        healthConnectService: mockHealthConnectService,
        firestoreService: mockFirestoreService,
      );
    });

    tearDown(() {
      repository.dispose();
    });

    group('getHealthData', () {
      final testTypes = [HealthDataType.weight, HealthDataType.steps];
      final startTime = DateTime(2024, 1, 1);
      final endTime = DateTime(2024, 1, 31);

      test('should return Health Connect data when source is healthConnect', () async {
        // Arrange
        final expectedData = [
          _createTestHealthDataPoint(
            type: HealthDataType.weight,
            source: HealthDataSource.healthConnect,
          ),
        ];
        when(mockFirestoreService.getHealthConnectData(
          types: any,
          startTime: any,
          endTime: any,
          limit: any,
        )).thenAnswer((_) async => expectedData);

        // Act
        final result = await repository.getHealthData(
          testTypes,
          startTime,
          endTime,
          source: HealthDataSource.healthConnect,
        );

        // Assert
        expect(result, equals(expectedData));
        verify(mockFirestoreService.getHealthConnectData(
          types: ['weight', 'steps'],
          startTime: startTime,
          endTime: endTime,
          limit: null,
        )).called(1);
      });

      test('should return manual data when source is manual', () async {
        // Arrange
        final expectedData = [
          _createTestHealthDataPoint(
            type: HealthDataType.weight,
            source: HealthDataSource.manual,
          ),
        ];
        when(mockFirestoreService.getManualHealthData(
          types: any,
          startTime: any,
          endTime: any,
          limit: any,
        )).thenAnswer((_) async => expectedData);

        // Act
        final result = await repository.getHealthData(
          testTypes,
          startTime,
          endTime,
          source: HealthDataSource.manual,
        );

        // Assert
        expect(result, equals(expectedData));
        verify(mockFirestoreService.getManualHealthData(
          types: ['weight', 'steps'],
          startTime: startTime,
          endTime: endTime,
          limit: null,
        )).called(1);
      });

      test('should return combined data when no source specified', () async {
        // Arrange
        final expectedData = [
          _createTestHealthDataPoint(
            type: HealthDataType.weight,
            source: HealthDataSource.healthConnect,
          ),
          _createTestHealthDataPoint(
            type: HealthDataType.weight,
            source: HealthDataSource.manual,
          ),
        ];
        when(mockFirestoreService.getCombinedHealthData(
          types: any,
          startTime: any,
          endTime: any,
          limit: any,
        )).thenAnswer((_) async => expectedData);

        // Act
        final result = await repository.getHealthData(
          testTypes,
          startTime,
          endTime,
        );

        // Assert
        expect(result.length, equals(2));
        verify(mockFirestoreService.getCombinedHealthData(
          types: ['weight', 'steps'],
          startTime: startTime,
          endTime: endTime,
          limit: null,
        )).called(1);
      });

      test('should throw HealthDataRepositoryException on error', () async {
        // Arrange
        when(mockFirestoreService.getHealthConnectData(
          types: any,
          startTime: any,
          endTime: any,
          limit: any,
        )).thenThrow(Exception('Firestore error'));

        // Act & Assert
        expect(
          () => repository.getHealthData(
            testTypes,
            startTime,
            endTime,
            source: HealthDataSource.healthConnect,
          ),
          throwsA(isA<HealthDataRepositoryException>()),
        );
      });
    });

    group('saveHealthData', () {
      test('should save Health Connect data to correct collection', () async {
        // Arrange
        final healthConnectData = [
          _createTestHealthDataPoint(
            type: HealthDataType.weight,
            source: HealthDataSource.healthConnect,
          ),
        ];
        when(mockFirestoreService.saveHealthConnectData(any))
            .thenAnswer((_) async {});

        // Act
        await repository.saveHealthData(healthConnectData);

        // Assert
        verify(mockFirestoreService.saveHealthConnectData(healthConnectData))
            .called(1);
        verifyNever(mockFirestoreService.saveManualHealthData(any));
      });

      test('should save manual data to correct collection', () async {
        // Arrange
        final manualData = [
          _createTestHealthDataPoint(
            type: HealthDataType.weight,
            source: HealthDataSource.manual,
          ),
        ];
        when(mockFirestoreService.saveManualHealthData(any))
            .thenAnswer((_) async {});

        // Act
        await repository.saveHealthData(manualData);

        // Assert
        verify(mockFirestoreService.saveManualHealthData(manualData)).called(1);
        verifyNever(mockFirestoreService.saveHealthConnectData(any));
      });

      test('should save mixed data to appropriate collections', () async {
        // Arrange
        final mixedData = [
          _createTestHealthDataPoint(
            type: HealthDataType.weight,
            source: HealthDataSource.healthConnect,
          ),
          _createTestHealthDataPoint(
            type: HealthDataType.steps,
            source: HealthDataSource.manual,
          ),
        ];
        when(mockFirestoreService.saveHealthConnectData(any))
            .thenAnswer((_) async {});
        when(mockFirestoreService.saveManualHealthData(any))
            .thenAnswer((_) async {});

        // Act
        await repository.saveHealthData(mixedData);

        // Assert
        verify(mockFirestoreService.saveHealthConnectData(any)).called(1);
        verify(mockFirestoreService.saveManualHealthData(any)).called(1);
      });
    });

    group('syncHealthConnectData', () {
      test('should sync data successfully', () async {
        // Arrange
        final testData = [
          _createTestHealthDataPoint(
            type: HealthDataType.weight,
            source: HealthDataSource.healthConnect,
          ),
        ];

        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.hasPermissions(any))
            .thenAnswer((_) async => true);
        when(mockHealthConnectService.getHealthData(any, any, any))
            .thenAnswer((_) async => testData);
        when(mockFirestoreService.updateHealthConnectSyncStatus(
          syncInProgress: anyNamed('syncInProgress'),
          lastSyncTimestamp: anyNamed('lastSyncTimestamp'),
          lastSuccessfulSync: anyNamed('lastSuccessfulSync'),
          totalRecordsSynced: anyNamed('totalRecordsSynced'),
          lastError: anyNamed('lastError'),
        )).thenAnswer((_) async {});
        when(mockFirestoreService.saveHealthConnectData(any))
            .thenAnswer((_) async {});
        when(mockFirestoreService.healthConnectDataExists(any))
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.syncHealthConnectData();

        // Assert
        expect(result.successful, greaterThan(0));
        expect(result.errors, isEmpty);
        verify(mockHealthConnectService.isAvailable()).called(1);
        verify(mockHealthConnectService.hasPermissions(any)).called(1);
        verify(mockFirestoreService.saveHealthConnectData(any)).called(1);
      });

      test('should handle Health Connect unavailable', () async {
        // Arrange
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => false);

        // Act
        final result = await repository.syncHealthConnectData();

        // Assert
        expect(result.successful, equals(0));
        expect(result.errors, isNotEmpty);
        expect(result.errors.first, contains('Health Connect is not available'));
      });

      test('should handle missing permissions', () async {
        // Arrange
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.hasPermissions(any))
            .thenAnswer((_) async => false);
        when(mockFirestoreService.updateHealthConnectSyncStatus(
          syncInProgress: anyNamed('syncInProgress'),
          lastSyncTimestamp: anyNamed('lastSyncTimestamp'),
          lastError: anyNamed('lastError'),
        )).thenAnswer((_) async {});

        // Act
        final result = await repository.syncHealthConnectData();

        // Assert
        expect(result.successful, equals(0));
        expect(result.errors, isNotEmpty);
        expect(result.errors.first, contains('Missing Health Connect permissions'));
      });
    });

    group('resetHealthConnectData', () {
      test('should reset and resync data successfully', () async {
        // Arrange
        when(mockFirestoreService.deleteAllHealthConnectData())
            .thenAnswer((_) async {});
        when(mockFirestoreService.updateHealthConnectSyncStatus(
          syncInProgress: anyNamed('syncInProgress'),
          lastError: anyNamed('lastError'),
          lastSyncTimestamp: anyNamed('lastSyncTimestamp'),
          lastSuccessfulSync: anyNamed('lastSuccessfulSync'),
          totalRecordsSynced: anyNamed('totalRecordsSynced'),
        )).thenAnswer((_) async {});
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.hasPermissions(any))
            .thenAnswer((_) async => true);
        when(mockHealthConnectService.getHealthData(any, any, any))
            .thenAnswer((_) async => []);
        when(mockFirestoreService.saveHealthConnectData(any))
            .thenAnswer((_) async {});

        // Act
        await repository.resetHealthConnectData();

        // Assert
        verify(mockFirestoreService.deleteAllHealthConnectData()).called(1);
        verify(mockFirestoreService.updateHealthConnectSyncStatus(
          syncInProgress: true,
          lastError: null,
        )).called(1);
      });

      test('should handle reset failure', () async {
        // Arrange
        when(mockFirestoreService.deleteAllHealthConnectData())
            .thenThrow(Exception('Delete failed'));
        when(mockFirestoreService.updateHealthConnectSyncStatus(
          syncInProgress: anyNamed('syncInProgress'),
          lastError: anyNamed('lastError'),
        )).thenAnswer((_) async {});

        // Act & Assert
        expect(
          () => repository.resetHealthConnectData(),
          throwsA(isA<HealthDataRepositoryException>()),
        );
        verify(mockFirestoreService.updateHealthConnectSyncStatus(
          syncInProgress: false,
          lastError: argThat(contains('Reset failed'), named: 'lastError'),
        )).called(1);
      });
    });

    group('data source preferences', () {
      test('should get data source preferences', () async {
        // Arrange
        final preferences = {
          'weight': 'healthConnect',
          'steps': 'manual',
        };
        when(mockFirestoreService.getDataSourcePreferences())
            .thenAnswer((_) async => preferences);

        // Act
        final result = await repository.getDataSourcePreferences();

        // Assert
        expect(result[HealthDataType.weight], equals(HealthDataSource.healthConnect));
        expect(result[HealthDataType.steps], equals(HealthDataSource.manual));
      });

      test('should set data source preference', () async {
        // Arrange
        final currentPreferences = {
          'weight': 'healthConnect',
          'steps': 'manual',
        };
        when(mockFirestoreService.getDataSourcePreferences())
            .thenAnswer((_) async => currentPreferences);
        when(mockFirestoreService.saveDataSourcePreferences(any))
            .thenAnswer((_) async {});

        // Act
        await repository.setDataSourcePreference(
          HealthDataType.weight,
          HealthDataSource.manual,
        );

        // Assert
        verify(mockFirestoreService.saveDataSourcePreferences(argThat(
          predicate<Map<String, String>>((prefs) => prefs['weight'] == 'manual'),
        ))).called(1);
      });
    });

    group('getLatestDataPoint', () {
      test('should return Health Connect data when preferred', () async {
        // Arrange
        final preferences = {'weight': 'healthConnect'};
        final expectedData = _createTestHealthDataPoint(
          type: HealthDataType.weight,
          source: HealthDataSource.healthConnect,
        );

        when(mockFirestoreService.getDataSourcePreferences())
            .thenAnswer((_) async => preferences);
        when(mockFirestoreService.getLatestHealthConnectData('weight'))
            .thenAnswer((_) async => expectedData);

        // Act
        final result = await repository.getLatestDataPoint(HealthDataType.weight);

        // Assert
        expect(result, equals(expectedData));
        verify(mockFirestoreService.getLatestHealthConnectData('weight')).called(1);
      });

      test('should fallback to manual data when Health Connect data unavailable', () async {
        // Arrange
        final preferences = {'weight': 'healthConnect'};
        final expectedData = _createTestHealthDataPoint(
          type: HealthDataType.weight,
          source: HealthDataSource.manual,
        );

        when(mockFirestoreService.getDataSourcePreferences())
            .thenAnswer((_) async => preferences);
        when(mockFirestoreService.getLatestHealthConnectData('weight'))
            .thenAnswer((_) async => null);
        when(mockFirestoreService.getLatestManualData('weight'))
            .thenAnswer((_) async => expectedData);

        // Act
        final result = await repository.getLatestDataPoint(HealthDataType.weight);

        // Assert
        expect(result, equals(expectedData));
        verify(mockFirestoreService.getLatestHealthConnectData('weight')).called(1);
        verify(mockFirestoreService.getLatestManualData('weight')).called(1);
      });
    });

    group('Health Connect permissions', () {
      test('should check permissions', () async {
        // Arrange
        final types = [HealthDataType.weight, HealthDataType.steps];
        when(mockHealthConnectService.hasPermissions(types))
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.hasHealthConnectPermissions(types);

        // Assert
        expect(result, isTrue);
        verify(mockHealthConnectService.hasPermissions(types)).called(1);
      });

      test('should request permissions', () async {
        // Arrange
        final types = [HealthDataType.weight, HealthDataType.steps];
        when(mockHealthConnectService.requestPermissions(types))
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.requestHealthConnectPermissions(types);

        // Assert
        expect(result, isTrue);
        verify(mockHealthConnectService.requestPermissions(types)).called(1);
      });
    });
  });

  group('DeduplicationConfig', () {
    test('should have default values', () {
      const config = DeduplicationConfig();
      
      expect(config.timeWindow, equals(const Duration(minutes: 5)));
      expect(config.valueThreshold, equals(0.01));
      expect(config.enableDeduplication, isTrue);
    });

    test('should accept custom values', () {
      const config = DeduplicationConfig(
        timeWindow: Duration(minutes: 10),
        valueThreshold: 0.05,
        enableDeduplication: false,
      );
      
      expect(config.timeWindow, equals(const Duration(minutes: 10)));
      expect(config.valueThreshold, equals(0.05));
      expect(config.enableDeduplication, isFalse);
    });
  });

  group('BatchOperationResult', () {
    test('should calculate success rate correctly', () {
      const result = BatchOperationResult(
        totalProcessed: 100,
        successful: 80,
        failed: 20,
        errors: [],
        processingTime: Duration(seconds: 5),
      );
      
      expect(result.successRate, equals(0.8));
      expect(result.hasErrors, isFalse);
    });

    test('should handle zero total processed', () {
      const result = BatchOperationResult(
        totalProcessed: 0,
        successful: 0,
        failed: 0,
        errors: [],
        processingTime: Duration(seconds: 1),
      );
      
      expect(result.successRate, equals(0.0));
    });

    test('should detect errors', () {
      const result = BatchOperationResult(
        totalProcessed: 10,
        successful: 8,
        failed: 2,
        errors: ['Error 1', 'Error 2'],
        processingTime: Duration(seconds: 2),
      );
      
      expect(result.hasErrors, isTrue);
    });
  });
}

/// Helper function to create test health data points
HealthDataPoint _createTestHealthDataPoint({
  required HealthDataType type,
  required HealthDataSource source,
  double value = 70.0,
  String? unit = 'kg',
  DateTime? timestamp,
}) {
  final now = DateTime.now();
  return HealthDataPoint(
    id: 'test_${type.name}_${now.millisecondsSinceEpoch}',
    type: type,
    value: value,
    unit: unit,
    timestamp: timestamp ?? now,
    source: source,
    createdAt: now,
    updatedAt: now,
  );
}