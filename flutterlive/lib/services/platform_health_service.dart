import 'dart:io';
import 'health_connect_service.dart';
import '../models/health_data_point.dart' as app_models;

/// Platform-specific factory for creating Health Connect services
class PlatformHealthService {
  static HealthConnectService? _instance;
  
  /// Get the singleton instance of the appropriate Health Connect service
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
  
  /// Reset the singleton instance (useful for testing)
  static void resetInstance() {
    _instance?.dispose();
    _instance = null;
  }
  
  /// Check if Health Connect is supported on the current platform
  static bool get isSupported => Platform.isAndroid;
  
  /// Get platform name for debugging
  static String get platformName {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isFuchsia) return 'Fuchsia';
    return 'Unknown';
  }
}

/// Extension to add convenience methods to HealthConnectService
extension HealthConnectServiceExtension on HealthConnectService {
  /// Check if Health Connect is both supported and available
  Future<bool> get isReadyToUse async {
    return isPlatformSupported && await isAvailable();
  }
  
  /// Get a list of commonly requested health data types
  static List<app_models.HealthDataType> get commonHealthDataTypes => [
    app_models.HealthDataType.weight,
    app_models.HealthDataType.steps,
    app_models.HealthDataType.heartRate,
    app_models.HealthDataType.calories,
    app_models.HealthDataType.workout,
  ];
  
  /// Get a list of all supported health data types
  static List<app_models.HealthDataType> get allHealthDataTypes => 
      app_models.HealthDataType.values;
}