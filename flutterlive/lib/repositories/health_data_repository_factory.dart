import '../models/health_data_point.dart';
import '../services/health_connect_service.dart';
import '../services/firestore_service.dart';
import '../services/health_connect_sync_service.dart';
import 'health_data_repository.dart';
import 'dart:io';

/// Factory for creating Health Data Repository instances
class HealthDataRepositoryFactory {
  static HealthDataRepository? _instance;

  /// Get singleton instance of the repository
  static HealthDataRepository get instance {
    _instance ??= _createRepository();
    return _instance!;
  }

  /// Create a new repository instance
  static HealthDataRepository _createRepository() {
    // Create Health Connect service based on platform
    final HealthConnectService healthConnectService;
    if (Platform.isAndroid) {
      healthConnectService = HealthConnectServiceImpl();
    } else {
      healthConnectService = HealthConnectServiceStub();
    }

    // Create Firestore service
    final firestoreService = FirestoreService();

    // Create sync service with configuration
    final syncConfig = SyncConfiguration(
      batchSize: 500,
      syncInterval: const Duration(hours: 4),
      retryDelay: const Duration(minutes: 5),
      maxRetries: 3,
      historicalDays: 90,
      enableIncrementalSync: true,
      enableDeduplication: true,
      deduplicationWindow: const Duration(minutes: 5),
      deduplicationThreshold: 0.01,
    );

    final syncService = HealthConnectSyncService(
      healthConnectService: healthConnectService,
      firestoreService: firestoreService,
      config: syncConfig,
    );

    // Create repository with deduplication config
    final deduplicationConfig = DeduplicationConfig(
      timeWindow: const Duration(minutes: 5),
      valueThreshold: 0.01,
      enableDeduplication: true,
    );

    return HealthDataRepositoryImpl(
      healthConnectService: healthConnectService,
      firestoreService: firestoreService,
      syncService: syncService,
      deduplicationConfig: deduplicationConfig,
    );
  }

  /// Initialize the repository
  static Future<void> initialize() async {
    await instance.initialize();
  }

  /// Reset the singleton instance (useful for testing)
  static void reset() {
    _instance?.dispose();
    _instance = null;
  }

  /// Create a repository for testing with custom services
  static HealthDataRepository createForTesting({
    required HealthConnectService healthConnectService,
    required FirestoreService firestoreService,
    HealthConnectSyncService? syncService,
    DeduplicationConfig? deduplicationConfig,
    SyncConfiguration? syncConfig,
  }) {
    final actualSyncService = syncService ?? HealthConnectSyncService(
      healthConnectService: healthConnectService,
      firestoreService: firestoreService,
      config: syncConfig ?? const SyncConfiguration(),
    );

    return HealthDataRepositoryImpl(
      healthConnectService: healthConnectService,
      firestoreService: firestoreService,
      syncService: actualSyncService,
      deduplicationConfig: deduplicationConfig ?? const DeduplicationConfig(),
    );
  }
}