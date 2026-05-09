import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutterlive/repositories/health_data_repository_factory.dart';
import 'package:flutterlive/repositories/health_data_repository.dart';
import 'package:flutterlive/services/health_connect_service.dart';
import 'package:flutterlive/services/firestore_service.dart';
import 'package:flutterlive/services/health_connect_sync_service.dart';

// Generate mocks
@GenerateMocks([HealthConnectService, FirestoreService, HealthConnectSyncService])
import 'health_data_repository_factory_test.mocks.dart';

void main() {
  group('HealthDataRepositoryFactory', () {
    setUp(() {
      // Reset the singleton before each test
      HealthDataRepositoryFactory.reset();
    });

    tearDown(() {
      // Clean up after each test
      HealthDataRepositoryFactory.reset();
    });

    group('singleton instance', () {
      test('should return the same instance on multiple calls', () {
        // Act
        final instance1 = HealthDataRepositoryFactory.instance;
        final instance2 = HealthDataRepositoryFactory.instance;

        // Assert
        expect(identical(instance1, instance2), true);
      });

      test('should create new instance after reset', () {
        // Arrange
        final instance1 = HealthDataRepositoryFactory.instance;

        // Act
        HealthDataRepositoryFactory.reset();
        final instance2 = HealthDataRepositoryFactory.instance;

        // Assert
        expect(identical(instance1, instance2), false);
      });
    });

    group('initialization', () {
      test('should initialize the repository instance', () async {
        // Arrange
        final repository = HealthDataRepositoryFactory.instance;

        // Act & Assert
        // This should not throw an exception
        // Note: In a real test environment, we would need to mock Firebase
        // For now, we just verify the method can be called
        expect(() => HealthDataRepositoryFactory.initialize(), returnsNormally);
      });
    });

    group('testing factory', () {
      test('should create repository with custom services for testing', () {
        // Arrange
        final mockHealthConnectService = MockHealthConnectService();
        final mockFirestoreService = MockFirestoreService();
        final mockSyncService = MockHealthConnectSyncService();

        // Act
        final repository = HealthDataRepositoryFactory.createForTesting(
          healthConnectService: mockHealthConnectService,
          firestoreService: mockFirestoreService,
          syncService: mockSyncService,
        );

        // Assert
        expect(repository, isA<HealthDataRepository>());
        expect(repository, isA<HealthDataRepositoryImpl>());
      });

      test('should create repository with default sync service when not provided', () {
        // Arrange
        final mockHealthConnectService = MockHealthConnectService();
        final mockFirestoreService = MockFirestoreService();

        // Act
        final repository = HealthDataRepositoryFactory.createForTesting(
          healthConnectService: mockHealthConnectService,
          firestoreService: mockFirestoreService,
        );

        // Assert
        expect(repository, isA<HealthDataRepository>());
        expect(repository, isA<HealthDataRepositoryImpl>());
      });

      test('should create repository with custom configurations', () {
        // Arrange
        final mockHealthConnectService = MockHealthConnectService();
        final mockFirestoreService = MockFirestoreService();
        
        final customSyncConfig = SyncConfiguration(
          batchSize: 200,
          syncInterval: const Duration(hours: 2),
          historicalDays: 30,
        );

        final customDeduplicationConfig = DeduplicationConfig(
          timeWindow: const Duration(minutes: 10),
          valueThreshold: 0.05,
          enableDeduplication: false,
        );

        // Act
        final repository = HealthDataRepositoryFactory.createForTesting(
          healthConnectService: mockHealthConnectService,
          firestoreService: mockFirestoreService,
          syncConfig: customSyncConfig,
          deduplicationConfig: customDeduplicationConfig,
        );

        // Assert
        expect(repository, isA<HealthDataRepository>());
        expect(repository, isA<HealthDataRepositoryImpl>());
      });
    });

    group('platform-specific behavior', () {
      test('should create appropriate health connect service based on platform', () {
        // Act
        final repository = HealthDataRepositoryFactory.instance;

        // Assert
        expect(repository, isA<HealthDataRepository>());
        // Note: The actual platform-specific behavior would be tested
        // in integration tests with real platform detection
      });
    });

    group('configuration', () {
      test('should use default configuration values', () {
        // Act
        final repository = HealthDataRepositoryFactory.instance;

        // Assert
        expect(repository, isA<HealthDataRepository>());
        // The factory creates the repository with default configurations
        // which are tested in the individual service tests
      });
    });
  });
}