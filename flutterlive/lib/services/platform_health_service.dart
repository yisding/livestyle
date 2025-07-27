import 'dart:io';
import 'health_connect_service.dart';

/// Factory class for creating platform-specific health services
class PlatformHealthService {
  /// Create the appropriate health service for the current platform
  static HealthConnectService create() {
    if (Platform.isAndroid) {
      return HealthConnectServiceImpl();
    } else {
      return HealthConnectServiceStub();
    }
  }
  
  /// Check if Health Connect is supported on the current platform
  static bool get isHealthConnectSupported => Platform.isAndroid;
  
  /// Get a description of the current platform's health integration
  static String get platformDescription {
    if (Platform.isAndroid) {
      return 'Android Health Connect';
    } else if (Platform.isIOS) {
      return 'iOS HealthKit (not yet implemented)';
    } else {
      return 'Manual entry only';
    }
  }
}