import 'package:flutter_test/flutter_test.dart';
import 'package:flutterlive/services/health_connect_service.dart';
import 'package:flutterlive/services/platform_health_service.dart';
import 'package:flutterlive/models/health_data_point.dart';

void main() {
  group('HealthConnectService', () {
    late HealthConnectService service;

    setUp(() {
      // Reset the singleton for each test
      PlatformHealthService.resetInstance();
      service = PlatformHealthService.instance;
    });

    tearDown(() {
      service.dispose();
      PlatformHealthService.resetInstance();
    });

    test('should create appropriate service for platform', () {
      expect(service, isNotNull);
      // On non-Android platforms, should create stub
      expect(service, isA<HealthConnectServiceStub>());
    });

    test('stub service should not support platform', () {
      expect(service.isPlatformSupported, isFalse);
    });

    test('stub service isAvailable should return false', () async {
      final isAvailable = await service.isAvailable();
      expect(isAvailable, isFalse);
    });

    test('stub service hasPermissions should return false', () async {
      final hasPermissions = await service.hasPermissions([
        HealthDataType.weight,
        HealthDataType.steps,
      ]);
      expect(hasPermissions, isFalse);
    });

    test('stub service requestPermissions should return false', () async {
      final granted = await service.requestPermissions([
        HealthDataType.weight,
        HealthDataType.steps,
      ]);
      expect(granted, isFalse);
    });

    test('stub service getHealthData should return empty list', () async {
      final data = await service.getHealthData(
        [HealthDataType.weight],
        DateTime.now().subtract(const Duration(days: 7)),
        DateTime.now(),
      );
      expect(data, isEmpty);
    });

    test('stub service writeHealthData should return false', () async {
      final success = await service.writeHealthData([]);
      expect(success, isFalse);
    });

    test('stub service should throw PlatformException for getPermissionStatus', () async {
      expect(
        () => service.getPermissionStatus([HealthDataType.weight]),
        throwsA(isA<PlatformException>()),
      );
    });

    test('healthConnectEvents stream should be available', () {
      expect(service.healthConnectEvents, isNotNull);
      expect(service.healthConnectEvents, isA<Stream<HealthConnectEvent>>());
    });

    test('PlatformHealthService should provide platform info', () {
      expect(PlatformHealthService.platformName, isNotEmpty);
      expect(PlatformHealthService.isSupported, isFalse); // On test environment
    });

    test('extension methods should work', () {
      final commonTypes = HealthConnectServiceExtension.commonHealthDataTypes;
      expect(commonTypes, isNotEmpty);
      expect(commonTypes, contains(HealthDataType.weight));
      expect(commonTypes, contains(HealthDataType.steps));

      final allTypes = HealthConnectServiceExtension.allHealthDataTypes;
      expect(allTypes, equals(HealthDataType.values));
    });

    test('isReadyToUse should return false for stub', () async {
      final isReady = await service.isReadyToUse;
      expect(isReady, isFalse);
    });
  });

  group('HealthConnectEvent', () {
    test('HealthDataChangedEvent should store changed types', () {
      final event = HealthDataChangedEvent([HealthDataType.weight]);
      expect(event.changedTypes, contains(HealthDataType.weight));
    });

    test('PermissionChangedEvent should store permissions map', () {
      final permissions = {HealthDataType.weight: true};
      final event = PermissionChangedEvent(permissions);
      expect(event.permissions, equals(permissions));
    });
  });

  group('HealthConnect Exceptions', () {
    test('HealthConnectException should format message correctly', () {
      const exception = HealthConnectException('Test message', 'TEST_CODE');
      expect(exception.toString(), contains('Test message'));
      expect(exception.toString(), contains('TEST_CODE'));
    });

    test('PermissionException should have correct code', () {
      const exception = PermissionException('Permission denied');
      expect(exception.code, equals('PERMISSION_DENIED'));
    });

    test('NetworkException should have correct code', () {
      const exception = NetworkException('Network error');
      expect(exception.code, equals('NETWORK_ERROR'));
    });

    test('PlatformException should have correct code', () {
      const exception = PlatformException('Platform not supported');
      expect(exception.code, equals('PLATFORM_NOT_SUPPORTED'));
    });
  });
}