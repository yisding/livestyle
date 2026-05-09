import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/health_data_point.dart';
import '../services/health_connect_permission_service.dart';
import '../services/health_connect_service.dart';

/// Centralized handler for Health Connect permission operations
class HealthConnectPermissionHandler {
  static HealthConnectPermissionHandler? _instance;
  static HealthConnectPermissionHandler get instance {
    _instance ??= HealthConnectPermissionHandler._();
    return _instance!;
  }

  HealthConnectPermissionHandler._();

  HealthConnectPermissionService? _permissionService;
  StreamSubscription<PermissionEvent>? _permissionSubscription;
  final StreamController<PermissionEvent> _globalEventController = 
      StreamController<PermissionEvent>.broadcast();

  /// Initialize the permission handler
  void initialize() {
    if (_permissionService != null) return;

    _permissionService = HealthConnectPermissionService(
      Platform.isAndroid 
          ? HealthConnectServiceImpl() 
          : HealthConnectServiceStub(),
    );

    // Forward events from the service to the global stream
    _permissionSubscription = _permissionService!.permissionEvents.listen(
      (event) => _globalEventController.add(event),
    );
  }

  /// Global stream of permission events
  Stream<PermissionEvent> get permissionEvents => _globalEventController.stream;

  /// Check if Health Connect is available
  Future<bool> isHealthConnectAvailable() async {
    _ensureInitialized();
    return await _permissionService!.isHealthConnectAvailable();
  }

  /// Get permission status for specified types
  Future<Map<HealthDataType, PermissionStatus>> getPermissionStatus(
    List<HealthDataType> types,
  ) async {
    _ensureInitialized();
    return await _permissionService!.getPermissionStatus(types);
  }

  /// Request permissions with comprehensive error handling
  Future<PermissionResult> requestPermissions(
    List<HealthDataType> types, {
    bool showRationale = true,
  }) async {
    _ensureInitialized();
    
    try {
      return await _permissionService!.requestPermissions(
        types,
        showRationale: showRationale,
      );
    } catch (e) {
      debugPrint('Error in permission handler: $e');
      return PermissionResult.failure(
        'Unexpected error occurred: ${e.toString()}',
        code: 'HANDLER_ERROR',
      );
    }
  }

  /// Request essential permissions for basic app functionality
  Future<PermissionResult> requestEssentialPermissions() async {
    _ensureInitialized();
    final essentialTypes = _permissionService!.getEssentialDataTypes();
    return await requestPermissions(essentialTypes);
  }

  /// Request all supported permissions
  Future<PermissionResult> requestAllPermissions() async {
    _ensureInitialized();
    final allTypes = _permissionService!.getSupportedDataTypes();
    return await requestPermissions(allTypes);
  }

  /// Check if specific permission is granted
  Future<bool> hasPermission(HealthDataType type) async {
    _ensureInitialized();
    return await _permissionService!.hasPermission(type);
  }

  /// Check if all essential permissions are granted
  Future<bool> hasEssentialPermissions() async {
    _ensureInitialized();
    final essentialTypes = _permissionService!.getEssentialDataTypes();
    return await _permissionService!.hasAllPermissions(essentialTypes);
  }

  /// Revoke all permissions
  Future<PermissionResult> revokeAllPermissions() async {
    _ensureInitialized();
    return await _permissionService!.revokeAllPermissions();
  }

  /// Get user-friendly error message for permission issues
  String getPermissionErrorMessage(PermissionResult result) {
    if (result.success) return '';

    switch (result.errorCode) {
      case 'PLATFORM_NOT_SUPPORTED':
        return 'Health Connect is only available on Android devices. '
               'You can use manual data entry on this platform.';
      
      case 'HEALTH_CONNECT_UNAVAILABLE':
        return 'Health Connect is not installed or available on this device. '
               'Please install Health Connect from the Google Play Store.';
      
      case 'PERMISSION_DENIED':
        return 'Some permissions were denied. You can grant them later in '
               'settings or continue with manual data entry.';
      
      case 'REVOKE_ERROR':
        return 'Failed to revoke permissions. Please try again or manage '
               'permissions directly in Health Connect settings.';
      
      case 'NETWORK_ERROR':
        return 'Network error occurred while requesting permissions. '
               'Please check your connection and try again.';
      
      default:
        return result.errorMessage ?? 'An unexpected error occurred.';
    }
  }

  /// Get user-friendly success message for permission results
  String getPermissionSuccessMessage(PermissionResult result) {
    if (!result.success) return '';

    final grantedCount = result.grantedPermissions.length;
    final totalCount = result.permissions.length;

    if (grantedCount == 0) {
      return 'No permissions were granted. You can continue with manual data entry.';
    } else if (grantedCount == totalCount) {
      return 'All permissions granted! LiveStyle can now access your health data.';
    } else {
      return 'Granted $grantedCount of $totalCount permissions. '
             'You can grant the remaining permissions later in settings.';
    }
  }

  /// Check if the app should show permission onboarding
  Future<bool> shouldShowPermissionOnboarding() async {
    if (!Platform.isAndroid) return false;
    
    try {
      final isAvailable = await isHealthConnectAvailable();
      if (!isAvailable) return false;

      final essentialTypes = _permissionService!.getEssentialDataTypes();
      final hasEssential = await _permissionService!.hasAllPermissions(essentialTypes);
      
      return !hasEssential;
    } catch (e) {
      debugPrint('Error checking onboarding status: $e');
      return false;
    }
  }

  /// Get permission statistics for analytics
  Future<Map<String, dynamic>> getPermissionStatistics() async {
    _ensureInitialized();
    
    try {
      final allTypes = _permissionService!.getSupportedDataTypes();
      final permissions = await getPermissionStatus(allTypes);
      
      final stats = <String, dynamic>{
        'platform_supported': Platform.isAndroid,
        'health_connect_available': await isHealthConnectAvailable(),
        'total_permissions': allTypes.length,
        'granted_permissions': permissions.values
            .where((status) => status == PermissionStatus.granted)
            .length,
        'denied_permissions': permissions.values
            .where((status) => status == PermissionStatus.denied)
            .length,
        'permission_details': {},
      };
      
      for (final entry in permissions.entries) {
        stats['permission_details'][entry.key.name] = entry.value.name;
      }
      
      return stats;
    } catch (e) {
      return {
        'error': e.toString(),
        'platform_supported': Platform.isAndroid,
      };
    }
  }

  /// Handle permission revocation (called when permissions are revoked externally)
  Future<void> handlePermissionRevocation() async {
    _ensureInitialized();
    
    try {
      // Check current permission status
      final allTypes = _permissionService!.getSupportedDataTypes();
      final currentPermissions = await getPermissionStatus(allTypes);
      
      // Emit event about permission changes
      _globalEventController.add(PermissionStatusChangedEvent(currentPermissions));
      
      debugPrint('Permission revocation handled. Current status: $currentPermissions');
    } catch (e) {
      debugPrint('Error handling permission revocation: $e');
    }
  }

  /// Clean up resources
  void dispose() {
    _permissionSubscription?.cancel();
    _permissionService?.dispose();
    _globalEventController.close();
    _permissionService = null;
    _instance = null;
  }

  void _ensureInitialized() {
    if (_permissionService == null) {
      initialize();
    }
  }
}

/// Extension methods for PermissionStatus enum
extension PermissionStatusExtension on PermissionStatus {
  /// Get user-friendly display name
  String get displayName {
    switch (this) {
      case PermissionStatus.granted:
        return 'Granted';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.notDetermined:
        return 'Not Set';
      case PermissionStatus.restricted:
        return 'Restricted';
    }
  }

  /// Check if permission allows data access
  bool get allowsAccess => this == PermissionStatus.granted;

  /// Check if permission can be requested
  bool get canRequest => this != PermissionStatus.restricted;
}

/// Utility class for permission-related UI helpers
class PermissionUIHelper {
  /// Get color for permission status
  static Color getStatusColor(PermissionStatus status, ColorScheme colorScheme) {
    switch (status) {
      case PermissionStatus.granted:
        return colorScheme.primary;
      case PermissionStatus.denied:
        return colorScheme.error;
      case PermissionStatus.restricted:
        return colorScheme.outline;
      case PermissionStatus.notDetermined:
        return colorScheme.outline;
    }
  }

  /// Get icon for permission status
  static IconData getStatusIcon(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return Icons.check_circle;
      case PermissionStatus.denied:
        return Icons.cancel;
      case PermissionStatus.restricted:
        return Icons.block;
      case PermissionStatus.notDetermined:
        return Icons.help_outline;
    }
  }

  /// Get description for permission status
  static String getStatusDescription(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Permission granted - data can be accessed';
      case PermissionStatus.denied:
        return 'Permission denied - manual entry required';
      case PermissionStatus.restricted:
        return 'Permission restricted by system';
      case PermissionStatus.notDetermined:
        return 'Permission not yet requested';
    }
  }
}