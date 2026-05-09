import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../lib/models/health_data_point.dart';
import '../../lib/services/health_connect_permission_service.dart';
import '../../lib/services/health_connect_service.dart';

// Generate mocks
@GenerateMocks([HealthConnectService])
import 'health_connect_permission_service_test.mocks.dart';

void main() {
  group('HealthConnectPermissionService', () {
    late MockHealthConnectService mockHealthConnectService;
    late HealthConnectPermissionService permissionService;

    setUp(() {
      mockHealthConnectService = MockHealthConnectService();
      permissionService = HealthConnectPermissionService(mockHealthConnectService);
    });

    tearDown(() {
      permissionService.dispose();
    });

    group('isHealthConnectAvailable', () {
      test('returns true when platform is supported and service is available', () async {
        // Arrange
        when(mockHealthConnectService.isPlatformSupported).thenReturn(true);
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);

        // Act
        final result = await permissionService.isHealthConnectAvailable();

        // Assert
        expect(result, isTrue);
        verify(mockHealthConnectService.isAvailable()).called(1);
      });

      test('returns false when platform is not supported', () async {
        // Arrange
        when(mockHealthConnectService.isPlatformSupported).thenReturn(false);

        // Act
        final result = await permissionService.isHealthConnectAvailable();

        // Assert
        expect(result, isFalse);
        verifyNever(mockHealthConnectService.isAvailable());
      });

      test('returns false when service throws exception', () async {
        // Arrange
        when(mockHealthConnectService.isPlatformSupported).thenReturn(true);
        when(mockHealthConnectService.isAvailable())
            .thenThrow(const HealthConnectException('Service unavailable'));

        // Act
        final result = await permissionService.isHealthConnectAvailable();

        // Assert
        expect(result, isFalse);
      });
    });

    group('getPermissionStatus', () {
      test('returns granted status for granted permissions', () async {
        // Arrange
        final types = [HealthDataType.weight, HealthDataType.steps];
        when(mockHealthConnectService.isPlatformSupported).thenReturn(true);
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.getPermissionStatus(types))
            .thenAnswer((_) async => {
              HealthDataType.weight: true,
              HealthDataType.steps: true,
            });

        // Act
        final result = await permissionService.getPermissionStatus(types);

        // Assert
        expect(result[HealthDataType.weight], equals(PermissionStatus.granted));
        expect(result[HealthDataType.steps], equals(PermissionStatus.granted));
      });

      test('returns denied status for denied permissions', () async {
        // Arrange
        final types = [HealthDataType.weight, HealthDataType.steps];
        when(mockHealthConnectService.isPlatformSupported).thenReturn(true);
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.getPermissionStatus(types))
            .thenAnswer((_) async => {
              HealthDataType.weight: false,
              HealthDataType.steps: false,
            });

        // Act
        final result = await permissionService.getPermissionStatus(types);

        // Assert
        expect(result[HealthDataType.weight], equals(PermissionStatus.denied));
        expect(result[HealthDataType.steps], equals(PermissionStatus.denied));
      });

      test('returns restricted status when platform not supported', () async {
        // Arrange
        final types = [HealthDataType.weight];
        when(mockHealthConnectService.isPlatformSupported).thenReturn(false);

        // Act
        final result = await permissionService.getPermissionStatus(types);

        // Assert
        expect(result[HealthDataType.weight], equals(PermissionStatus.restricted));
      });

      test('returns restricted status when Health Connect unavailable', () async {
        // Arrange
        final types = [HealthDataType.weight];
        when(mockHealthConnectService.isPlatformSupported).thenReturn(true);
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => false);

        // Act
        final result = await permissionService.getPermissionStatus(types);

        // Assert
        expect(result[HealthDataType.weight], equals(PermissionStatus.restricted));
      });
    });

    group('requestPermissions', () {
      test('returns success result when all permissions granted', () async {
        // Arrange
        final types = [HealthDataType.weight, HealthDataType.steps];
        when(mockHealthConnectService.isPlatformSupported).thenReturn(true);
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.getPermissionStatus(types))
            .thenAnswer((_) async => {
              HealthDataType.weight: false,
              HealthDataType.steps: false,
            });
        when(mockHealthConnectService.requestPermissions(types))
            .thenAnswer((_) async => true);
        when(mockHealthConnectService.getPermissionStatus(types))
            .thenAnswer((_) async => {
              HealthDataType.weight: true,
              HealthDataType.steps: true,
            });

        // Act
        final result = await permissionService.requestPermissions(types);

        // Assert
        expect(result.success, isTrue);
        expect(result.allPermissionsGranted, isTrue);
        expect(result.grantedPermissions, containsAll(types));
      });

      test('returns platform not supported result on unsupported platform', () async {
        // Arrange
        final types = [HealthDataType.weight];
        when(mockHealthConnectService.isPlatformSupported).thenReturn(false);

        // Act
        final result = await permissionService.requestPermissions(types);

        // Assert
        expect(result.success, isFalse);
        expect(result.errorCode, equals('PLATFORM_NOT_SUPPORTED'));
      });

      test('returns unavailable result when Health Connect not available', () async {
        // Arrange
        final types = [HealthDataType.weight];
        when(mockHealthConnectService.isPlatformSupported).thenReturn(true);
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => false);

        // Act
        final result = await permissionService.requestPermissions(types);

        // Assert
        expect(result.success, isFalse);
        expect(result.errorCode, equals('HEALTH_CONNECT_UNAVAILABLE'));
      });

      test('returns success immediately if all permissions already granted', () async {
        // Arrange
        final types = [HealthDataType.weight];
        when(mockHealthConnectService.isPlatformSupported).thenReturn(true);
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.getPermissionStatus(types))
            .thenAnswer((_) async => {HealthDataType.weight: true});

        // Act
        final result = await permissionService.requestPermissions(types);

        // Assert
        expect(result.success, isTrue);
        expect(result.allPermissionsGranted, isTrue);
        verifyNever(mockHealthConnectService.requestPermissions(any));
      });

      test('handles PermissionException correctly', () async {
        // Arrange
        final types = [HealthDataType.weight];
        when(mockHealthConnectService.isPlatformSupported).thenReturn(true);
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.getPermissionStatus(types))
            .thenAnswer((_) async => {HealthDataType.weight: false});
        when(mockHealthConnectService.requestPermissions(types))
            .thenThrow(const PermissionException('Permission denied by user'));

        // Act
        final result = await permissionService.requestPermissions(types);

        // Assert
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Permission denied by user'));
      });
    });

    group('revokeAllPermissions', () {
      test('successfully revokes permissions', () async {
        // Arrange
        when(mockHealthConnectService.isPlatformSupported).thenReturn(true);
        when(mockHealthConnectService.revokePermissions())
            .thenAnswer((_) async => {});

        // Act
        final result = await permissionService.revokeAllPermissions();

        // Assert
        expect(result.success, isTrue);
        verify(mockHealthConnectService.revokePermissions()).called(1);
      });

      test('returns platform not supported result on unsupported platform', () async {
        // Arrange
        when(mockHealthConnectService.isPlatformSupported).thenReturn(false);

        // Act
        final result = await permissionService.revokeAllPermissions();

        // Assert
        expect(result.success, isFalse);
        expect(result.errorCode, equals('PLATFORM_NOT_SUPPORTED'));
      });

      test('handles exceptions during revocation', () async {
        // Arrange
        when(mockHealthConnectService.isPlatformSupported).thenReturn(true);
        when(mockHealthConnectService.revokePermissions())
            .thenThrow(const HealthConnectException('Revocation failed'));

        // Act
        final result = await permissionService.revokeAllPermissions();

        // Assert
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Revocation failed'));
      });
    });

    group('hasPermission', () {
      test('returns true when permission is granted', () async {
        // Arrange
        when(mockHealthConnectService.isPlatformSupported).thenReturn(true);
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.getPermissionStatus([HealthDataType.weight]))
            .thenAnswer((_) async => {HealthDataType.weight: true});

        // Act
        final result = await permissionService.hasPermission(HealthDataType.weight);

        // Assert
        expect(result, isTrue);
      });

      test('returns false when permission is denied', () async {
        // Arrange
        when(mockHealthConnectService.isPlatformSupported).thenReturn(true);
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.getPermissionStatus([HealthDataType.weight]))
            .thenAnswer((_) async => {HealthDataType.weight: false});

        // Act
        final result = await permissionService.hasPermission(HealthDataType.weight);

        // Assert
        expect(result, isFalse);
      });
    });

    group('hasAllPermissions', () {
      test('returns true when all permissions are granted', () async {
        // Arrange
        final types = [HealthDataType.weight, HealthDataType.steps];
        when(mockHealthConnectService.isPlatformSupported).thenReturn(true);
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.getPermissionStatus(types))
            .thenAnswer((_) async => {
              HealthDataType.weight: true,
              HealthDataType.steps: true,
            });

        // Act
        final result = await permissionService.hasAllPermissions(types);

        // Assert
        expect(result, isTrue);
      });

      test('returns false when some permissions are denied', () async {
        // Arrange
        final types = [HealthDataType.weight, HealthDataType.steps];
        when(mockHealthConnectService.isPlatformSupported).thenReturn(true);
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.getPermissionStatus(types))
            .thenAnswer((_) async => {
              HealthDataType.weight: true,
              HealthDataType.steps: false,
            });

        // Act
        final result = await permissionService.hasAllPermissions(types);

        // Assert
        expect(result, isFalse);
      });
    });

    group('data type helpers', () {
      test('getSupportedDataTypes returns all types when platform supported', () {
        // Arrange
        when(mockHealthConnectService.isPlatformSupported).thenReturn(true);

        // Act
        final result = permissionService.getSupportedDataTypes();

        // Assert
        expect(result, equals(HealthDataType.values));
      });

      test('getSupportedDataTypes returns empty list when platform not supported', () {
        // Arrange
        when(mockHealthConnectService.isPlatformSupported).thenReturn(false);

        // Act
        final result = permissionService.getSupportedDataTypes();

        // Assert
        expect(result, isEmpty);
      });

      test('getEssentialDataTypes returns expected types', () {
        // Act
        final result = permissionService.getEssentialDataTypes();

        // Assert
        expect(result, contains(HealthDataType.weight));
        expect(result, contains(HealthDataType.steps));
        expect(result, contains(HealthDataType.heartRate));
        expect(result, contains(HealthDataType.workout));
        expect(result, contains(HealthDataType.calories));
      });

      test('getOptionalDataTypes returns expected types', () {
        // Act
        final result = permissionService.getOptionalDataTypes();

        // Assert
        expect(result, contains(HealthDataType.bodyFatPercentage));
        expect(result, contains(HealthDataType.bmi));
        expect(result, contains(HealthDataType.sleep));
        expect(result, contains(HealthDataType.bloodPressure));
        expect(result, contains(HealthDataType.bloodGlucose));
      });
    });

    group('user-friendly helpers', () {
      test('getDataTypeDescription returns meaningful descriptions', () {
        // Act & Assert
        expect(
          permissionService.getDataTypeDescription(HealthDataType.weight),
          equals('Body weight measurements'),
        );
        expect(
          permissionService.getDataTypeDescription(HealthDataType.steps),
          equals('Daily step count and activity'),
        );
      });

      test('getDataTypeName returns readable names', () {
        // Act & Assert
        expect(
          permissionService.getDataTypeName(HealthDataType.weight),
          equals('Weight'),
        );
        expect(
          permissionService.getDataTypeName(HealthDataType.bodyFatPercentage),
          equals('Body Fat %'),
        );
      });

      test('getDataTypeIcon returns appropriate icon names', () {
        // Act & Assert
        expect(
          permissionService.getDataTypeIcon(HealthDataType.weight),
          equals('scale'),
        );
        expect(
          permissionService.getDataTypeIcon(HealthDataType.heartRate),
          equals('favorite'),
        );
      });
    });

    group('events', () {
      test('emits PermissionStatusChangedEvent when permissions change', () async {
        // Arrange
        final types = [HealthDataType.weight];
        when(mockHealthConnectService.isPlatformSupported).thenReturn(true);
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.getPermissionStatus(types))
            .thenAnswer((_) async => {HealthDataType.weight: false});
        when(mockHealthConnectService.requestPermissions(types))
            .thenAnswer((_) async => true);
        when(mockHealthConnectService.getPermissionStatus(types))
            .thenAnswer((_) async => {HealthDataType.weight: true});

        // Act
        final eventFuture = permissionService.permissionEvents
            .where((event) => event is PermissionStatusChangedEvent)
            .first;
        
        await permissionService.requestPermissions(types);
        final event = await eventFuture as PermissionStatusChangedEvent;

        // Assert
        expect(event.permissions[HealthDataType.weight], 
               equals(PermissionStatus.granted));
      });

      test('emits PermissionRequestCompletedEvent after request', () async {
        // Arrange
        final types = [HealthDataType.weight];
        when(mockHealthConnectService.isPlatformSupported).thenReturn(true);
        when(mockHealthConnectService.isAvailable()).thenAnswer((_) async => true);
        when(mockHealthConnectService.getPermissionStatus(types))
            .thenAnswer((_) async => {HealthDataType.weight: false});
        when(mockHealthConnectService.requestPermissions(types))
            .thenAnswer((_) async => true);
        when(mockHealthConnectService.getPermissionStatus(types))
            .thenAnswer((_) async => {HealthDataType.weight: true});

        // Act
        final eventFuture = permissionService.permissionEvents
            .where((event) => event is PermissionRequestCompletedEvent)
            .first;
        
        await permissionService.requestPermissions(types);
        final event = await eventFuture as PermissionRequestCompletedEvent;

        // Assert
        expect(event.result.success, isTrue);
      });
    });
  });

  group('PermissionResult', () {
    test('success factory creates successful result', () {
      // Arrange
      final permissions = {HealthDataType.weight: PermissionStatus.granted};

      // Act
      final result = PermissionResult.success(permissions);

      // Assert
      expect(result.success, isTrue);
      expect(result.permissions, equals(permissions));
      expect(result.errorMessage, isNull);
    });

    test('failure factory creates failed result', () {
      // Act
      final result = PermissionResult.failure('Test error', code: 'TEST_CODE');

      // Assert
      expect(result.success, isFalse);
      expect(result.errorMessage, equals('Test error'));
      expect(result.errorCode, equals('TEST_CODE'));
    });

    test('allPermissionsGranted returns true when all granted', () {
      // Arrange
      final permissions = {
        HealthDataType.weight: PermissionStatus.granted,
        HealthDataType.steps: PermissionStatus.granted,
      };
      final result = PermissionResult.success(permissions);

      // Act & Assert
      expect(result.allPermissionsGranted, isTrue);
    });

    test('allPermissionsGranted returns false when some denied', () {
      // Arrange
      final permissions = {
        HealthDataType.weight: PermissionStatus.granted,
        HealthDataType.steps: PermissionStatus.denied,
      };
      final result = PermissionResult.success(permissions);

      // Act & Assert
      expect(result.allPermissionsGranted, isFalse);
    });

    test('grantedPermissions returns only granted types', () {
      // Arrange
      final permissions = {
        HealthDataType.weight: PermissionStatus.granted,
        HealthDataType.steps: PermissionStatus.denied,
        HealthDataType.heartRate: PermissionStatus.granted,
      };
      final result = PermissionResult.success(permissions);

      // Act
      final granted = result.grantedPermissions;

      // Assert
      expect(granted, containsAll([HealthDataType.weight, HealthDataType.heartRate]));
      expect(granted, isNot(contains(HealthDataType.steps)));
    });

    test('deniedPermissions returns only denied types', () {
      // Arrange
      final permissions = {
        HealthDataType.weight: PermissionStatus.granted,
        HealthDataType.steps: PermissionStatus.denied,
        HealthDataType.heartRate: PermissionStatus.denied,
      };
      final result = PermissionResult.success(permissions);

      // Act
      final denied = result.deniedPermissions;

      // Assert
      expect(denied, containsAll([HealthDataType.steps, HealthDataType.heartRate]));
      expect(denied, isNot(contains(HealthDataType.weight)));
    });
  });
}