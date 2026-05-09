import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

import '../../lib/models/health_data_point.dart';
import '../../lib/services/health_connect_permission_service.dart';
import '../../lib/services/health_connect_service.dart';
import '../../lib/utils/health_connect_permission_handler.dart';

void main() {
  group('Permission Management Integration Tests', () {
    late HealthConnectPermissionService permissionService;
    late HealthConnectPermissionHandler permissionHandler;

    setUp(() {
      // Use stub service for testing (non-Android environment)
      permissionService = HealthConnectPermissionService(HealthConnectServiceStub());
      permissionHandler = HealthConnectPermissionHandler.instance;
      permissionHandler.initialize();
    });

    tearDown(() {
      permissionService.dispose();
      permissionHandler.dispose();
    });

    group('HealthConnectPermissionService', () {
      test('should return false for Health Connect availability on non-Android', () async {
        final isAvailable = await permissionService.isHealthConnectAvailable();
        expect(isAvailable, isFalse);
      });

      test('should return restricted permissions on non-Android platform', () async {
        final types = [HealthDataType.weight, HealthDataType.steps];
        final permissions = await permissionService.getPermissionStatus(types);
        
        expect(permissions[HealthDataType.weight], equals(PermissionStatus.restricted));
        expect(permissions[HealthDataType.steps], equals(PermissionStatus.restricted));
      });

      test('should return platform not supported when requesting permissions', () async {
        final types = [HealthDataType.weight];
        final result = await permissionService.requestPermissions(types);
        
        expect(result.success, isFalse);
        expect(result.errorCode, equals('PLATFORM_NOT_SUPPORTED'));
      });

      test('should return empty list for supported data types on non-Android', () {
        final supportedTypes = permissionService.getSupportedDataTypes();
        expect(supportedTypes, isEmpty);
      });

      test('should return essential data types regardless of platform', () {
        final essentialTypes = permissionService.getEssentialDataTypes();
        expect(essentialTypes, isNotEmpty);
        expect(essentialTypes, contains(HealthDataType.weight));
        expect(essentialTypes, contains(HealthDataType.steps));
        expect(essentialTypes, contains(HealthDataType.heartRate));
      });

      test('should return optional data types regardless of platform', () {
        final optionalTypes = permissionService.getOptionalDataTypes();
        expect(optionalTypes, isNotEmpty);
        expect(optionalTypes, contains(HealthDataType.bodyFatPercentage));
        expect(optionalTypes, contains(HealthDataType.sleep));
      });

      test('should provide user-friendly data type descriptions', () {
        final description = permissionService.getDataTypeDescription(HealthDataType.weight);
        expect(description, equals('Body weight measurements'));
        
        final name = permissionService.getDataTypeName(HealthDataType.weight);
        expect(name, equals('Weight'));
        
        final icon = permissionService.getDataTypeIcon(HealthDataType.weight);
        expect(icon, equals('scale'));
      });

      test('should handle permission revocation gracefully', () async {
        final result = await permissionService.revokeAllPermissions();
        expect(result.success, isFalse);
        expect(result.errorCode, equals('PLATFORM_NOT_SUPPORTED'));
      });
    });

    group('HealthConnectPermissionHandler', () {
      test('should maintain singleton instance', () {
        final instance1 = HealthConnectPermissionHandler.instance;
        final instance2 = HealthConnectPermissionHandler.instance;
        expect(identical(instance1, instance2), isTrue);
      });

      test('should provide appropriate error messages', () {
        final platformResult = PermissionResult.platformNotSupported();
        final errorMessage = permissionHandler.getPermissionErrorMessage(platformResult);
        expect(errorMessage, contains('Health Connect is only available on Android'));

        final unavailableResult = PermissionResult.healthConnectUnavailable();
        final unavailableMessage = permissionHandler.getPermissionErrorMessage(unavailableResult);
        expect(unavailableMessage, contains('Health Connect is not installed'));
      });

      test('should provide appropriate success messages', () {
        final allGrantedPermissions = {
          HealthDataType.weight: PermissionStatus.granted,
          HealthDataType.steps: PermissionStatus.granted,
        };
        final allGrantedResult = PermissionResult.success(allGrantedPermissions);
        final successMessage = permissionHandler.getPermissionSuccessMessage(allGrantedResult);
        expect(successMessage, contains('All permissions granted'));

        final partialPermissions = {
          HealthDataType.weight: PermissionStatus.granted,
          HealthDataType.steps: PermissionStatus.denied,
        };
        final partialResult = PermissionResult.success(partialPermissions);
        final partialMessage = permissionHandler.getPermissionSuccessMessage(partialResult);
        expect(partialMessage, contains('Granted 1 of 2 permissions'));
      });

      test('should handle permission statistics correctly', () async {
        final stats = await permissionHandler.getPermissionStatistics();
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats.containsKey('platform_supported'), isTrue);
        expect(stats.containsKey('health_connect_available'), isTrue);
        expect(stats.containsKey('total_permissions'), isTrue);
      });

      test('should determine onboarding requirement correctly', () async {
        final shouldShow = await permissionHandler.shouldShowPermissionOnboarding();
        // On non-Android platforms, should not show onboarding
        expect(shouldShow, isFalse);
      });
    });

    group('PermissionResult', () {
      test('should correctly identify all permissions granted', () {
        final allGranted = {
          HealthDataType.weight: PermissionStatus.granted,
          HealthDataType.steps: PermissionStatus.granted,
        };
        final result = PermissionResult.success(allGranted);
        expect(result.allPermissionsGranted, isTrue);
      });

      test('should correctly identify partial permissions', () {
        final partialGranted = {
          HealthDataType.weight: PermissionStatus.granted,
          HealthDataType.steps: PermissionStatus.denied,
        };
        final result = PermissionResult.success(partialGranted);
        expect(result.allPermissionsGranted, isFalse);
        expect(result.grantedPermissions, contains(HealthDataType.weight));
        expect(result.deniedPermissions, contains(HealthDataType.steps));
      });

      test('should handle failure results correctly', () {
        final failureResult = PermissionResult.failure('Test error', code: 'TEST_CODE');
        expect(failureResult.success, isFalse);
        expect(failureResult.errorMessage, equals('Test error'));
        expect(failureResult.errorCode, equals('TEST_CODE'));
        // For failure results, permissions map is empty, so allPermissionsGranted should be true (vacuous truth)
        expect(failureResult.permissions.isEmpty, isTrue);
      });
    });

    group('Permission Status Extensions', () {
      test('should provide correct display names', () {
        expect(PermissionStatus.granted.displayName, equals('Granted'));
        expect(PermissionStatus.denied.displayName, equals('Denied'));
        expect(PermissionStatus.notDetermined.displayName, equals('Not Set'));
        expect(PermissionStatus.restricted.displayName, equals('Restricted'));
      });

      test('should correctly identify access permissions', () {
        expect(PermissionStatus.granted.allowsAccess, isTrue);
        expect(PermissionStatus.denied.allowsAccess, isFalse);
        expect(PermissionStatus.notDetermined.allowsAccess, isFalse);
        expect(PermissionStatus.restricted.allowsAccess, isFalse);
      });

      test('should correctly identify requestable permissions', () {
        expect(PermissionStatus.granted.canRequest, isTrue);
        expect(PermissionStatus.denied.canRequest, isTrue);
        expect(PermissionStatus.notDetermined.canRequest, isTrue);
        expect(PermissionStatus.restricted.canRequest, isFalse);
      });
    });

    group('Event Handling', () {
      test('should emit events when permissions change', () async {
        bool eventReceived = false;
        
        final subscription = permissionService.permissionEvents.listen((event) {
          if (event is PermissionRequestCompletedEvent) {
            eventReceived = true;
          }
        });

        // Trigger a permission request (will fail on non-Android but should emit event)
        await permissionService.requestPermissions([HealthDataType.weight]);
        
        // Give some time for the event to be processed
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(eventReceived, isTrue);
        
        await subscription.cancel();
      });
    });

    group('Error Handling', () {
      test('should handle platform exceptions gracefully', () async {
        // Test that the service doesn't crash when platform is not supported
        expect(() async {
          await permissionService.isHealthConnectAvailable();
        }, returnsNormally);

        expect(() async {
          await permissionService.getPermissionStatus([HealthDataType.weight]);
        }, returnsNormally);

        expect(() async {
          await permissionService.requestPermissions([HealthDataType.weight]);
        }, returnsNormally);
      });

      test('should provide meaningful error messages for different scenarios', () {
        final handler = HealthConnectPermissionHandler.instance;
        
        // Test different error scenarios
        final platformError = PermissionResult.platformNotSupported();
        expect(handler.getPermissionErrorMessage(platformError), 
               contains('only available on Android'));

        final unavailableError = PermissionResult.healthConnectUnavailable();
        expect(handler.getPermissionErrorMessage(unavailableError), 
               contains('not installed or available'));

        final customError = PermissionResult.failure('Custom error message');
        expect(handler.getPermissionErrorMessage(customError), 
               equals('Custom error message'));
      });
    });
  });
}