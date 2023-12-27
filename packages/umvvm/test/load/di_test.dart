import 'package:test/test.dart';
import 'package:umvvm/umvvm.dart';

import 'test_load_instances.dart';

void main() {
  group('Instance collection load tests', () {
    final instances = InstanceCollection.implementationInstance;

    setUp(() async {
      UMvvmApp.isInTestMode = true;

      initialize(instances);
    });

    test('Instance get load test', () async {
      var average = 0;
      const iterations = 1000;

      for (var i = 0; i < iterations; i++) {
        final stopwatch = Stopwatch()..start();
        final _ = instances.get<TestMvvmInstance700>();

        average += stopwatch.elapsedMicroseconds;
      }

      expect(average / iterations < 10, true);
    });

    test('Instance getUnique load test', () async {
      var average = 0;
      const iterations = 1000;

      for (var i = 0; i < iterations; i++) {
        final stopwatch = Stopwatch()..start();
        final _ = instances.getUnique<TestMvvmInstance700>();

        average += stopwatch.elapsedMicroseconds;
      }

      expect(average / iterations < 10, true);
    });

    test('Instance getUniqueByTypeString load test', () async {
      var average = 0;
      const iterations = 1000;

      for (var i = 0; i < iterations; i++) {
        final stopwatch = Stopwatch()..start();
        final _ = instances.getUniqueByTypeString('TestMvvmInstance$i');

        average += stopwatch.elapsedMicroseconds;
      }

      expect(average / iterations < 10, true);
    });

    test('Instance getByTypeString load test', () async {
      var average = 0;
      const iterations = 1000;

      for (var i = 0; i < iterations; i++) {
        final stopwatch = Stopwatch()..start();

        final _ = instances.getByTypeString(type: 'TestMvvmInstance$i');

        average += stopwatch.elapsedMicroseconds;
      }

      expect(average / iterations < 10, true);
    });
  });
}
