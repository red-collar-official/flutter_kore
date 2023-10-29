import 'package:test/test.dart';
import 'package:umvvm/umvvm.dart';

import '../helpers/constants.dart';

final class TestMvvmInstance extends MvvmInstance<int?> {
  int value = 1;

  @override
  void initialize(int? input) {
    super.initialize(input);

    value = input ?? 1;

    initialized = true;
  }
}

void main() {
  group('Instance collection tests', () {
    final instances = InstanceCollection.implementationInstance;
    const testScope = Constants.testScope;
    final testInstanceRuntimeType = TestMvvmInstance().runtimeType.toString();

    setUp(() async {
      UMvvmApp.isInTestMode = true;

      instances
        ..clear()
        ..addBuilder<TestMvvmInstance>(TestMvvmInstance.new);
    });

    test('Instance collection add, get test', () async {
      instances.addWithParams<int>(
        testInstanceRuntimeType,
        1,
        scope: testScope,
      );

      expect(instances.get<TestMvvmInstance>(scope: testScope).value, 1);
    });

    test('Instance getUniqueByTypeString test', () async {
      instances.addWithParams<int>(
        testInstanceRuntimeType,
        1,
        scope: testScope,
      );

      expect(
        (instances.getUniqueByTypeString(testInstanceRuntimeType)
                as TestMvvmInstance)
            .value,
        1,
      );
    });

    test('Instance collection construct test', () async {
      instances.addWithParams<int>(
        testInstanceRuntimeType,
        1,
        scope: testScope,
      );

      expect(
        instances
            .constructInstance<TestMvvmInstance>(testInstanceRuntimeType)
            .value,
        1,
      );
    });

    test('Instance new instance test', () async {
      final instancesSeparate = InstanceCollection.newInstance();

      expect(instancesSeparate != instances, true);
    });

    test('Instance uninitialized test', () async {
      instances.addUninitialized(
        testInstanceRuntimeType,
        1,
        scope: testScope,
      );

      expect(instances.get<TestMvvmInstance>(scope: testScope).value, 1);
    });

    test('Instance uninitialized with no connections test', () async {
      instances.addUninitialized(
        testInstanceRuntimeType,
        1,
        scope: testScope,
      );

      expect(
        instances
            .get<TestMvvmInstance>(
              scope: testScope,
              withoutConnections: true,
            )
            .value,
        1,
      );
    });

    test('Instance uninitialized async test', () async {
      instances.addUninitialized(
        testInstanceRuntimeType,
        1,
        scope: testScope,
      );

      expect(
        (await instances.getAsync<TestMvvmInstance>(
          scope: testScope,
        ))
            .value,
        1,
      );
    });

    test('Instance uninitialized async with no connections test', () async {
      instances.addUninitialized(
        testInstanceRuntimeType,
        1,
        scope: testScope,
      );

      expect(
        (await instances.getAsync<TestMvvmInstance>(
          scope: testScope,
          withoutConnections: true,
        ))
            .value,
        1,
      );
    });

    test('Instance collection all test', () async {
      instances
        ..addWithParams<int>(
          testInstanceRuntimeType,
          1,
          scope: testScope,
        )
        ..addWithParams<int>(
          testInstanceRuntimeType,
          2,
          scope: testScope,
          index: 1,
        );

      final all = instances.all(testScope);

      expect(all.length, 2);
      expect((all[0] as TestMvvmInstance).value, 1);
      expect((all[1] as TestMvvmInstance).value, 2);
    });

    test('Instance collection proone test', () async {
      instances
        ..addWithParams<int>(
          testInstanceRuntimeType,
          1,
          scope: testScope,
        )
        ..increaseReferencesInScope(testScope, TestMvvmInstance)
        ..addWithParams<int>(
          testInstanceRuntimeType,
          2,
          scope: testScope,
          index: 1,
        )
        ..increaseReferencesInScope(testScope, TestMvvmInstance, index: 1);

      var all = instances.all(testScope);

      expect(all.length, 2);

      expect((all[0] as TestMvvmInstance).value, 1);
      expect((all[1] as TestMvvmInstance).value, 2);

      instances.proone();

      all = instances.all(testScope);

      expect(all.length, 2);
      expect((all[0] as TestMvvmInstance).value, 1);
      expect((all[1] as TestMvvmInstance).value, 2);

      instances
        ..decreaseReferencesInScope(testScope, TestMvvmInstance, index: 1)
        ..proone();

      all = instances.all(testScope);

      expect(all.length, 1);
      expect((all[0] as TestMvvmInstance).value, 1);

      instances
        ..decreaseReferencesInScope(testScope, int)
        ..proone();

      all = instances.all(testScope);

      expect(all.length, 1);
      expect((all[0] as TestMvvmInstance).value, 1);

      expect(
        () => instances
          ..decreaseReferencesInScope(testScope, TestMvvmInstance, index: 10)
          ..proone(),
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(
        () => instances
          ..decreaseReferencesInScope(testScope, TestMvvmInstance, index: -1)
          ..proone(),
        throwsA(isA<IllegalArgumentException>()),
      );

      instances
        ..decreaseReferencesInScope(testScope, TestMvvmInstance)
        ..proone();

      all = instances.all(testScope);

      expect(all.length, 0);
    });

    test('Instance collection getAllByTypeString test', () async {
      instances
        ..addWithParams<int>(
          testInstanceRuntimeType,
          1,
          scope: testScope,
        )
        ..addWithParams<int>(
          testInstanceRuntimeType,
          2,
          scope: testScope,
          index: 1,
        );

      final all = instances.getAllByTypeString(
        testScope,
        testInstanceRuntimeType,
      );

      expect(all.length, 2);
      expect((all[0] as TestMvvmInstance).value, 1);
      expect((all[1] as TestMvvmInstance).value, 2);
    });

    test('Instance collection add existing test', () async {
      instances.addExisting(testScope, TestMvvmInstance()..initialize(3));

      expect(instances.get<TestMvvmInstance>(scope: testScope).value, 3);
    });

    test('Instance collection add test test', () async {
      instances.addTest<TestMvvmInstance>(
        testScope,
        TestMvvmInstance()..initialize(3),
      );

      expect(instances.get<TestMvvmInstance>(scope: testScope).value, 3);
    });

    test('Instance collection add test uninitialized test', () async {
      instances.addTest<TestMvvmInstance>(
        testScope,
        TestMvvmInstance(),
      );

      expect(instances.get<TestMvvmInstance>(scope: testScope).value, 1);
    });

    test('Instance collection clear test', () async {
      instances.addExisting(testScope, TestMvvmInstance()..initialize(3));

      expect(instances.get<TestMvvmInstance>(scope: testScope).value, 3);

      instances.clear();

      expect(instances.all(testScope).length, 0);
    });

    test('Instance collection find test', () async {
      instances.addExisting(testScope, TestMvvmInstance()..initialize(3));

      expect(instances.find<TestMvvmInstance>(testScope)!.value, 3);

      instances.clear();

      expect(instances.find<TestMvvmInstance>(testScope), null);
    });

    test('Instance collection getUniqueAsync test', () async {
      expect((await instances.getUniqueAsync<TestMvvmInstance>()).value, 1);
    });

    test('Instance collection getUniqueWithParamsAsync test', () async {
      expect(
        (await instances.getUniqueWithParamsAsync<TestMvvmInstance, int>(
          params: 2,
        ))
            .value,
        2,
      );
    });

    test('Instance collection getAsync test', () async {
      expect((await instances.getAsync<TestMvvmInstance>()).value, 1);
    });

    test('Instance collection getWithParamsAsync test', () async {
      expect(
        (await instances.getWithParamsAsync<TestMvvmInstance, int>(params: 2))
            .value,
        2,
      );
    });

    test('Instance collection getAsync when instance already existing test',
        () async {
      instances.addExisting(testScope, TestMvvmInstance()..initialize(3));

      expect(
        (await instances.getAsync<TestMvvmInstance>(scope: testScope)).value,
        3,
      );
    });

    test('Instance collection getUniqueByTypeStringWithParamsAsync test',
        () async {
      expect(
        (await instances.getUniqueByTypeStringWithParamsAsync<int>(
                testInstanceRuntimeType,
                params: 2) as TestMvvmInstance)
            .value,
        2,
      );
    });

    test('Instance collection getByTypeStringWithParamsAsync test', () async {
      expect(
        (await instances.getByTypeStringWithParamsAsync<int>(
          testInstanceRuntimeType,
          2,
          null,
          testScope,
          false,
        ) as TestMvvmInstance)
            .value,
        2,
      );
    });

    test('Instance collection addAsync test', () async {
      await instances.addAsync(
        testInstanceRuntimeType,
        null,
        scope: testScope,
      );

      expect(instances.get<TestMvvmInstance>(scope: testScope).value, 1);
    });

    test('Instance collection addWithParamsAsync test', () async {
      await instances.addWithParamsAsync(
        testInstanceRuntimeType,
        2,
        scope: testScope,
      );

      expect(instances.get<TestMvvmInstance>(scope: testScope).value, 2);
    });

    test('Instance collection getUnique test', () async {
      expect(instances.getUnique<TestMvvmInstance>().value, 1);
    });

    test('Instance collection getUniqueWithParams test', () async {
      expect(
        instances.getUniqueWithParams<TestMvvmInstance, int>(params: 2).value,
        2,
      );
    });

    test('Instance collection get test', () async {
      expect(instances.get<TestMvvmInstance>().value, 1);
    });

    test('Instance collection getWithParams test', () async {
      expect(
        instances.getWithParams<TestMvvmInstance, int>(params: 2).value,
        2,
      );
    });

    test('Instance collection get when instance already existing test',
        () async {
      instances.addExisting(testScope, TestMvvmInstance()..initialize(3));

      expect(
        instances.get<TestMvvmInstance>(scope: testScope).value,
        3,
      );
    });

    test('Instance collection getByTypeString test', () async {
      expect(
        (instances.getByTypeString(
          testInstanceRuntimeType,
          null,
          null,
          testScope,
          false,
        ) as TestMvvmInstance)
            .value,
        1,
      );
    });

    test('Instance collection getByTypeStringWithParams test', () async {
      expect(
        (instances.getByTypeStringWithParams<int>(
          testInstanceRuntimeType,
          2,
          null,
          testScope,
          false,
        ) as TestMvvmInstance)
            .value,
        2,
      );
    });

    test('Instance collection add test', () async {
      instances.add(
        testInstanceRuntimeType,
        null,
        scope: testScope,
      );

      expect(instances.get<TestMvvmInstance>(scope: testScope).value, 1);
    });

    test('Instance collection addWithParams test', () async {
      instances.addWithParams(
        testInstanceRuntimeType,
        2,
        scope: testScope,
      );

      expect(instances.get<TestMvvmInstance>(scope: testScope).value, 2);
    });
  });
}
