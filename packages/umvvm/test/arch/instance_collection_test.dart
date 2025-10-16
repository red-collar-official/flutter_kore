import 'package:test/test.dart';
import 'package:umvvm/umvvm.dart';

import '../helpers/constants.dart';
import '../helpers/delay_utility.dart';

final class TestBaseMvvmInstance extends BaseMvvmInstance<int?> {
  int value = 1;

  @override
  void initialize(int? input) {
    super.initialize(input);

    value = input ?? 1;
  }
}

final class MockTestBaseMvvmInstance extends TestBaseMvvmInstance {
  @override
  // ignore: overridden_fields
  int value = 2;

  @override
  void initialize(int? input) {
    super.initialize(input);

    value = 2;
  }
}

final class TestBaseMvvmInstance2 extends BaseMvvmInstance<int?> {
  int value = 1;

  @override
  void initialize(int? input) {
    super.initialize(input);

    value = input ?? 1;
  }
}

void main() {
  group('Instance collection tests', () {
    final instances = InstanceCollection.instance;
    const testScope = Constants.testScope;
    final testInstanceRuntimeType =
        TestBaseMvvmInstance().runtimeType.toString();
    final testInstance2RuntimeType =
        TestBaseMvvmInstance2().runtimeType.toString();

    setUp(() async {
      UMvvmApp.isInTestMode = true;

      instances
        ..clear()
        ..addBuilder<TestBaseMvvmInstance>(TestBaseMvvmInstance.new)
        ..addBuilder<TestBaseMvvmInstance2>(TestBaseMvvmInstance2.new);
    });

    test('Instance collection mock test', () async {
      final mockInstance = TestBaseMvvmInstance();

      instances.mock(instance: mockInstance);

      mockInstance.value = 1;

      expect(instances.get<TestBaseMvvmInstance>(scope: testScope).value, 1);
    });

    test('Instance collection mock builder test', () async {
      instances.mock<TestBaseMvvmInstance>(
          builder: MockTestBaseMvvmInstance.new);

      expect(instances.get<TestBaseMvvmInstance>(scope: testScope).value, 2);
    });

    test('Instance collection add, get test', () async {
      instances.addWithParams<int>(
        type: testInstanceRuntimeType,
        params: 1,
        scope: testScope,
      );

      expect(instances.get<TestBaseMvvmInstance>(scope: testScope).value, 1);
    });

    test('Instance getUniqueByTypeString test', () async {
      instances.addWithParams<int>(
        type: testInstanceRuntimeType,
        params: 1,
        scope: testScope,
      );

      expect(
        (instances.getUniqueByTypeString(testInstanceRuntimeType)
                as TestBaseMvvmInstance)
            .value,
        1,
      );
    });

    test('Instance collection construct test', () async {
      instances.addWithParams<int>(
        type: testInstanceRuntimeType,
        params: 1,
        scope: testScope,
      );

      expect(
        instances
            .constructInstance<TestBaseMvvmInstance>(testInstanceRuntimeType)
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
        type: testInstanceRuntimeType,
        params: 1,
        scope: testScope,
      );

      expect(instances.get<TestBaseMvvmInstance>(scope: testScope).value, 1);
    });

    test('Instance uninitialized with no connections test', () async {
      instances.addUninitialized(
        type: testInstanceRuntimeType,
        params: 1,
        scope: testScope,
      );

      expect(
        instances
            .get<TestBaseMvvmInstance>(
              scope: testScope,
              withoutConnections: true,
            )
            .value,
        1,
      );
    });

    test('Instance uninitialized async test', () async {
      instances.addUninitialized(
        type: testInstanceRuntimeType,
        params: 1,
        scope: testScope,
      );

      expect(
        (await instances.getAsync<TestBaseMvvmInstance>(
          scope: testScope,
        ))
            .value,
        1,
      );
    });

    test('Instance uninitialized async with no connections test', () async {
      instances.addUninitialized(
        type: testInstanceRuntimeType,
        params: 1,
        scope: testScope,
      );

      expect(
        (await instances.getAsync<TestBaseMvvmInstance>(
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
          type: testInstanceRuntimeType,
          params: 1,
          scope: testScope,
        )
        ..addWithParams<int>(
          type: testInstanceRuntimeType,
          params: 2,
          scope: testScope,
          index: 1,
        );

      final all = instances.all(testScope);

      expect(all.length, 2);
      expect((all[0] as TestBaseMvvmInstance).value, 1);
      expect((all[1] as TestBaseMvvmInstance).value, 2);
    });

    test('Instance collection prune test', () async {
      instances
        ..addWithParams<int>(
          type: testInstanceRuntimeType,
          params: 1,
          scope: testScope,
        )
        ..increaseReferencesInScope(testScope, TestBaseMvvmInstance)
        ..addWithParams<int>(
          type: testInstanceRuntimeType,
          params: 2,
          scope: testScope,
          index: 1,
        )
        ..increaseReferencesInScope(testScope, TestBaseMvvmInstance, index: 1);

      var all = instances.all(testScope);

      expect(all.length, 2);

      expect((all[0] as TestBaseMvvmInstance).value, 1);
      expect((all[1] as TestBaseMvvmInstance).value, 2);

      instances.prune();

      all = instances.all(testScope);

      expect(all.length, 2);
      expect((all[0] as TestBaseMvvmInstance).value, 1);
      expect((all[1] as TestBaseMvvmInstance).value, 2);

      instances
        ..decreaseReferencesInScope(testScope, TestBaseMvvmInstance, index: 1)
        ..prune();

      all = instances.all(testScope);

      expect(all.length, 1);
      expect((all[0] as TestBaseMvvmInstance).value, 1);

      instances
        ..decreaseReferencesInScope(testScope, int)
        ..prune();

      all = instances.all(testScope);

      expect(all.length, 1);
      expect((all[0] as TestBaseMvvmInstance).value, 1);

      expect(
        () => instances
          ..decreaseReferencesInScope(testScope, TestBaseMvvmInstance,
              index: 10)
          ..prune(),
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(
        () => instances
          ..decreaseReferencesInScope(testScope, TestBaseMvvmInstance,
              index: -1)
          ..prune(),
        throwsA(isA<IllegalArgumentException>()),
      );

      instances
        ..decreaseReferencesInScope(testScope, TestBaseMvvmInstance)
        ..prune();

      all = instances.all(testScope);

      expect(all.length, 0);
    });

    test('Instance collection getAllByTypeString test', () async {
      instances
        ..addWithParams<int>(
          type: testInstanceRuntimeType,
          params: 1,
          scope: testScope,
        )
        ..addWithParams<int>(
          type: testInstanceRuntimeType,
          params: 2,
          scope: testScope,
          index: 1,
        );

      final all = instances.getAllByTypeString(
        testScope,
        testInstanceRuntimeType,
      );

      expect(all.length, 2);
      expect((all[0] as TestBaseMvvmInstance).value, 1);
      expect((all[1] as TestBaseMvvmInstance).value, 2);
    });

    test('Instance collection add existing test', () async {
      instances.addExisting(
          scope: testScope, instance: TestBaseMvvmInstance()..initialize(3));

      expect(instances.get<TestBaseMvvmInstance>(scope: testScope).value, 3);
    });

    test('Instance collection add test test', () async {
      instances.addTest<TestBaseMvvmInstance>(
        scope: testScope,
        instance: TestBaseMvvmInstance()..initialize(3),
      );

      expect(instances.get<TestBaseMvvmInstance>(scope: testScope).value, 3);
    });

    test('Instance collection add test overrideMainInstance test', () async {
      instances.addTest<TestBaseMvvmInstance>(
        scope: testScope,
        instance: TestBaseMvvmInstance()..initialize(3),
      );

      expect(instances.get<TestBaseMvvmInstance>(scope: testScope).value, 3);

      instances.addTest<TestBaseMvvmInstance>(
        scope: testScope,
        instance: TestBaseMvvmInstance()..initialize(4),
      );

      expect(instances.get<TestBaseMvvmInstance>(scope: testScope).value, 4);

      instances.addTest<TestBaseMvvmInstance>(
        scope: testScope,
        instance: TestBaseMvvmInstance()..initialize(5),
        overrideMainInstance: false,
      );

      expect(instances.get<TestBaseMvvmInstance>(scope: testScope).value, 4);
    });

    test('Instance collection add test uninitialized test', () async {
      instances.addTest<TestBaseMvvmInstance>(
        scope: testScope,
        instance: TestBaseMvvmInstance(),
      );

      expect(instances.get<TestBaseMvvmInstance>(scope: testScope).value, 1);
    });

    test('Instance collection clear test', () async {
      instances.addExisting(
          scope: testScope, instance: TestBaseMvvmInstance()..initialize(3));

      expect(instances.get<TestBaseMvvmInstance>(scope: testScope).value, 3);

      instances.clear();

      expect(instances.all(testScope).length, 0);
    });

    test('Instance collection find test', () async {
      instances.addExisting(
          scope: testScope, instance: TestBaseMvvmInstance()..initialize(3));

      expect(instances.find<TestBaseMvvmInstance>(testScope)!.value, 3);

      instances.clear();

      expect(instances.find<TestBaseMvvmInstance>(testScope), null);
    });

    test('Instance collection getUniqueAsync test', () async {
      expect((await instances.getUniqueAsync<TestBaseMvvmInstance>()).value, 1);
    });

    test('Instance collection getUniqueWithParamsAsync test', () async {
      expect(
        (await instances.getUniqueWithParamsAsync<TestBaseMvvmInstance, int>(
          params: 2,
        ))
            .value,
        2,
      );
    });

    test('Instance collection getAsync test', () async {
      expect((await instances.getAsync<TestBaseMvvmInstance>()).value, 1);
    });

    test('Instance collection getWithParamsAsync test', () async {
      expect(
        (await instances.getWithParamsAsync<TestBaseMvvmInstance, int>(
                params: 2))
            .value,
        2,
      );
    });

    test('Instance collection getAsync when instance already existing test',
        () async {
      instances.addExisting(
          scope: testScope, instance: TestBaseMvvmInstance()..initialize(3));

      expect(
        (await instances.getAsync<TestBaseMvvmInstance>(scope: testScope))
            .value,
        3,
      );
    });

    test('Instance collection getUniqueByTypeStringWithParamsAsync test',
        () async {
      expect(
        (await instances.getUniqueByTypeStringWithParamsAsync<int>(
          type: testInstanceRuntimeType,
          params: 2,
        ) as TestBaseMvvmInstance)
            .value,
        2,
      );
    });

    test('Instance collection getByTypeStringWithParamsAsync test', () async {
      expect(
        (await instances.getByTypeStringWithParamsAsync<int>(
          type: testInstanceRuntimeType,
          params: 2,
          scope: testScope,
        ) as TestBaseMvvmInstance)
            .value,
        2,
      );
    });

    test('Instance collection addAsync test', () async {
      await instances.addAsync(
        type: testInstanceRuntimeType,
        scope: testScope,
      );

      expect(instances.get<TestBaseMvvmInstance>(scope: testScope).value, 1);
    });

    test('Instance collection addWithParamsAsync test', () async {
      await instances.addWithParamsAsync(
        type: testInstanceRuntimeType,
        params: 2,
        scope: testScope,
      );

      expect(instances.get<TestBaseMvvmInstance>(scope: testScope).value, 2);
    });

    test('Instance collection getUnique test', () async {
      expect(instances.getUnique<TestBaseMvvmInstance>().value, 1);
    });

    test('Instance collection getUniqueWithParams test', () async {
      expect(
        instances
            .getUniqueWithParams<TestBaseMvvmInstance, int>(params: 2)
            .value,
        2,
      );
    });

    test('Instance collection get test', () async {
      expect(instances.get<TestBaseMvvmInstance>().value, 1);
    });

    test('Instance collection getWithParams test', () async {
      expect(
        instances.getWithParams<TestBaseMvvmInstance, int>(params: 2).value,
        2,
      );
    });

    test('Instance collection get when instance already existing test',
        () async {
      instances.addExisting(
          scope: testScope, instance: TestBaseMvvmInstance()..initialize(3));

      expect(
        instances.get<TestBaseMvvmInstance>(scope: testScope).value,
        3,
      );
    });

    test('Instance collection getByTypeString test', () async {
      expect(
        (instances.getByTypeString(
          type: testInstanceRuntimeType,
          scope: testScope,
        ) as TestBaseMvvmInstance)
            .value,
        1,
      );
    });

    test('Instance collection getByTypeStringWithParams test', () async {
      expect(
        (instances.getByTypeStringWithParams<int>(
          type: testInstanceRuntimeType,
          params: 2,
          scope: testScope,
        ) as TestBaseMvvmInstance)
            .value,
        2,
      );
    });

    test('Instance collection add test', () async {
      instances.add(
        type: testInstanceRuntimeType,
        scope: testScope,
      );

      expect(instances.get<TestBaseMvvmInstance>(scope: testScope).value, 1);
    });

    test('Instance collection addWithParams test', () async {
      instances.addWithParams(
        type: testInstanceRuntimeType,
        params: 2,
        scope: testScope,
      );

      expect(instances.get<TestBaseMvvmInstance>(scope: testScope).value, 2);
    });

    test('Instance collection unregisterInstance test', () async {
      instances.addWithParams(
        type: testInstanceRuntimeType,
        params: 2,
        scope: testScope,
      );

      expect(instances.get<TestBaseMvvmInstance>(scope: testScope).value, 2);

      instances.unregisterInstance<TestBaseMvvmInstance>(
        scope: testScope,
      );

      expect(instances.forceGet<TestBaseMvvmInstance>(scope: testScope), null);
    });

    test('Instance collection unregisterInstance global test', () async {
      instances
        ..addWithParams(
          type: testInstanceRuntimeType,
          params: 1,
          scope: BaseScopes.global,
        )
        ..addWithParams(
          type: testInstance2RuntimeType,
          params: 2,
          scope: BaseScopes.global,
        );

      expect(instances.get<TestBaseMvvmInstance>().value, 1);
      expect(instances.get<TestBaseMvvmInstance2>().value, 2);

      instances.unregisterInstance<TestBaseMvvmInstance>();

      expect(instances.forceGet<TestBaseMvvmInstance>(), null);
      expect(instances.forceGet<TestBaseMvvmInstance2>()!.value, 2);
    });

    test('Instance collection use and dispose instance test', () async {
      await instances
          .useAndDisposeInstance<TestBaseMvvmInstance>((instance) async {
        await DelayUtility.pause();
      });

      expect(
        instances.forceGet<TestBaseMvvmInstance>(),
        null,
      );
    });

    test('Instance collection use and dispose instance with params test',
        () async {
      await instances
          .useAndDisposeInstanceWithParams<TestBaseMvvmInstance, int>(
        1,
        (instance) async {
          await DelayUtility.pause();
        },
      );

      expect(
        instances.forceGet<TestBaseMvvmInstance>(),
        null,
      );
    });
  });
}
