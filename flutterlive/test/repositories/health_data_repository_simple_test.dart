import 'package:flutter_test/flutter_test.dart';
import '../../lib/repositories/health_data_repository.dart';
import '../../lib/models/health_data_point.dart';

void main() {
  group('HealthDataRepository', () {
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

    group('HealthDataRepositoryException', () {
      test('should create exception with message', () {
        const exception = HealthDataRepositoryException('Test error');
        
        expect(exception.message, equals('Test error'));
        expect(exception.code, isNull);
        expect(exception.toString(), equals('HealthDataRepositoryException: Test error'));
      });

      test('should create exception with message and code', () {
        const exception = HealthDataRepositoryException('Test error', 'TEST_CODE');
        
        expect(exception.message, equals('Test error'));
        expect(exception.code, equals('TEST_CODE'));
        expect(exception.toString(), equals('HealthDataRepositoryException: Test error (Code: TEST_CODE)'));
      });
    });

    group('HealthDataPoint factory methods', () {
      test('should create weight data point', () {
        final dataPoint = HealthDataPointFactory.createWeight(
          id: 'test_weight',
          weightKg: 70.5,
          timestamp: DateTime(2024, 1, 1),
          source: HealthDataSource.manual,
        );

        expect(dataPoint.id, equals('test_weight'));
        expect(dataPoint.type, equals(HealthDataType.weight));
        expect(dataPoint.value, equals(70.5));
        expect(dataPoint.unit, equals('kg'));
        expect(dataPoint.source, equals(HealthDataSource.manual));
      });

      test('should create steps data point', () {
        final dataPoint = HealthDataPointFactory.createSteps(
          id: 'test_steps',
          steps: 10000,
          timestamp: DateTime(2024, 1, 1),
          source: HealthDataSource.healthConnect,
        );

        expect(dataPoint.id, equals('test_steps'));
        expect(dataPoint.type, equals(HealthDataType.steps));
        expect(dataPoint.value, equals(10000.0));
        expect(dataPoint.unit, equals('steps'));
        expect(dataPoint.source, equals(HealthDataSource.healthConnect));
      });

      test('should create workout data point', () {
        final startTime = DateTime(2024, 1, 1, 10, 0);
        final endTime = DateTime(2024, 1, 1, 11, 0);
        
        final dataPoint = HealthDataPointFactory.createWorkout(
          id: 'test_workout',
          caloriesBurned: 300,
          startTime: startTime,
          endTime: endTime,
          source: HealthDataSource.healthConnect,
        );

        expect(dataPoint.id, equals('test_workout'));
        expect(dataPoint.type, equals(HealthDataType.workout));
        expect(dataPoint.value, equals(300.0));
        expect(dataPoint.unit, equals('calories'));
        expect(dataPoint.timestamp, equals(startTime));
        expect(dataPoint.endTime, equals(endTime));
        expect(dataPoint.duration, equals(const Duration(hours: 1)));
        expect(dataPoint.source, equals(HealthDataSource.healthConnect));
      });

      test('should create heart rate data point', () {
        final dataPoint = HealthDataPointFactory.createHeartRate(
          id: 'test_hr',
          bpm: 75,
          timestamp: DateTime(2024, 1, 1),
          source: HealthDataSource.healthConnect,
        );

        expect(dataPoint.id, equals('test_hr'));
        expect(dataPoint.type, equals(HealthDataType.heartRate));
        expect(dataPoint.value, equals(75.0));
        expect(dataPoint.unit, equals('bpm'));
        expect(dataPoint.source, equals(HealthDataSource.healthConnect));
      });
    });

    group('HealthDataPoint properties', () {
      test('should identify workout data points', () {
        final workoutPoint = HealthDataPointFactory.createWorkout(
          id: 'workout',
          caloriesBurned: 200,
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(minutes: 30)),
          source: HealthDataSource.healthConnect,
        );

        final weightPoint = HealthDataPointFactory.createWeight(
          id: 'weight',
          weightKg: 70.0,
          timestamp: DateTime.now(),
          source: HealthDataSource.manual,
        );

        expect(workoutPoint.isWorkout, isTrue);
        expect(workoutPoint.hasDuration, isTrue);
        expect(weightPoint.isWorkout, isFalse);
        expect(weightPoint.hasDuration, isFalse);
      });

      test('should generate description', () {
        final weightPoint = HealthDataPointFactory.createWeight(
          id: 'weight',
          weightKg: 70.5,
          timestamp: DateTime.now(),
          source: HealthDataSource.manual,
        );

        expect(weightPoint.description, equals('weight: 70.5 kg'));
      });

      test('should format timestamp', () {
        final timestamp = DateTime(2024, 1, 15, 14, 30);
        final dataPoint = HealthDataPointFactory.createWeight(
          id: 'weight',
          weightKg: 70.0,
          timestamp: timestamp,
          source: HealthDataSource.manual,
        );

        expect(dataPoint.formattedTimestamp, equals('15/1/2024 14:30'));
      });
    });

    group('HealthDataPoint equality', () {
      test('should be equal when all properties match', () {
        final timestamp = DateTime(2024, 1, 1);
        
        final point1 = HealthDataPoint(
          id: 'test',
          type: HealthDataType.weight,
          value: 70.0,
          unit: 'kg',
          timestamp: timestamp,
          source: HealthDataSource.manual,
          createdAt: timestamp,
          updatedAt: timestamp,
        );

        final point2 = HealthDataPoint(
          id: 'test',
          type: HealthDataType.weight,
          value: 70.0,
          unit: 'kg',
          timestamp: timestamp,
          source: HealthDataSource.manual,
          createdAt: timestamp,
          updatedAt: timestamp,
        );

        expect(point1, equals(point2));
        expect(point1.hashCode, equals(point2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final timestamp = DateTime(2024, 1, 1);
        
        final point1 = HealthDataPoint(
          id: 'test1',
          type: HealthDataType.weight,
          value: 70.0,
          unit: 'kg',
          timestamp: timestamp,
          source: HealthDataSource.manual,
          createdAt: timestamp,
          updatedAt: timestamp,
        );

        final point2 = HealthDataPoint(
          id: 'test2',
          type: HealthDataType.weight,
          value: 70.0,
          unit: 'kg',
          timestamp: timestamp,
          source: HealthDataSource.manual,
          createdAt: timestamp,
          updatedAt: timestamp,
        );

        expect(point1, isNot(equals(point2)));
      });
    });

    group('HealthDataPoint copyWith', () {
      test('should create copy with updated fields', () {
        final original = HealthDataPointFactory.createWeight(
          id: 'original',
          weightKg: 70.0,
          timestamp: DateTime(2024, 1, 1),
          source: HealthDataSource.manual,
        );

        final copy = original.copyWith(
          id: 'updated',
          value: 75.0,
        );

        expect(copy.id, equals('updated'));
        expect(copy.value, equals(75.0));
        expect(copy.type, equals(original.type));
        expect(copy.unit, equals(original.unit));
        expect(copy.timestamp, equals(original.timestamp));
        expect(copy.source, equals(original.source));
      });
    });
  });
}