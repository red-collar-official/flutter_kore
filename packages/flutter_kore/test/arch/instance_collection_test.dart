import 'package:test/test.dart';
import 'package:flutter_kore/flutter_kore.dart';

import '../helpers/constants.dart';
import '../helpers/delay_utility.dart';
import '../mocks/test_interactors.dart';

final class TestBaseKoreInstance extends BaseKoreInstance<int?> {
  int value = 1;

  @override
  void initialize(int? input) {
    super.initialize(input);

    value = input ?? 1;
  }
}

final class MockTestBaseKoreInstance extends TestBaseKoreInstance {
  @override
  // ignore: overridden_fields
  int value = 2;

  @override
  void initialize(int? input) {
    super.initialize(input);

    value = 2;
  }
}

final class TestBaseKoreInstance2 extends BaseKoreInstance<int?> {
  int value = 1;

  @override
  void initialize(int? input) {
    super.initialize(input);

    value = input ?? 1;
  }
}

final class TestAsyncBaseKoreInstance extends BaseKoreInstance<int?> {
  int value = 1;

  @override
  bool get isAsync => true;
}

void main() {
  group('Instance collection tests', () {
    final instances = InstanceCollection.instance;
    const testScope = Constants.testScope;
    final testInstanceRuntimeType =
        TestBaseKoreInstance().runtimeType.toString();
    final testInstance2RuntimeType =
        TestBaseKoreInstance2().runtimeType.toString();

    setUp(() async {
      KoreApp.isInTestMode = true;

      instances
        ..clear()
        ..addBuilder<TestBaseKoreInstance>(TestBaseKoreInstance.new)
        ..addBuilder<TestAsyncBaseKoreInstance>(TestAsyncBaseKoreInstance.new)
        ..addBuilder<TestAsyncBaseKoreInstance>(TestAsyncBaseKoreInstance.new)
        ..addBuilder<TestInteractorAsync5>(TestInteractorAsync5.new)
        ..addBuilder<TestBaseKoreInstance2>(TestBaseKoreInstance2.new)
        ..addBuilder<TestInteractorAsyncSameDependency>(
            TestInteractorAsyncSameDependency.new);
    });

    test('Instance collection mock test', () async {
      final mockInstance = TestBaseKoreInstance();

      instances.mock(instance: mockInstance);

      mockInstance.value = 1;

      expect(instances.get<TestBaseKoreInstance>(scope: testScope).value, 1);
    });

    test('Instance collection mock builder test', () async {
      instances.mock<TestBaseKoreInstance>(
          builder: MockTestBaseKoreInstance.new);

      expect(instances.get<TestBaseKoreInstance>(scope: testScope).value, 2);
    });

    test('Instance collection add, get test', () async {
      instances.addWithParams<int>(
        type: testInstanceRuntimeType,
        params: 1,
        scope: testScope,
      );

      expect(instances.get<TestBaseKoreInstance>(scope: testScope).value, 1);
    });

    test('Instance getUniqueByTypeString test', () async {
      instances.addWithParams<int>(
        type: testInstanceRuntimeType,
        params: 1,
        scope: testScope,
      );

      expect(
        (instances.getUniqueByTypeString(testInstanceRuntimeType)
                as TestBaseKoreInstance)
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
            .constructInstance<TestBaseKoreInstance>(testInstanceRuntimeType)
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

      expect(instances.get<TestBaseKoreInstance>(scope: testScope).value, 1);
    });

    test('Instance uninitialized with no connections test', () async {
      instances.addUninitialized(
        type: testInstanceRuntimeType,
        params: 1,
        scope: testScope,
      );

      expect(
        instances
            .get<TestBaseKoreInstance>(
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
        (await instances.getAsync<TestBaseKoreInstance>(
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
        (await instances.getAsync<TestBaseKoreInstance>(
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
      expect((all[0] as TestBaseKoreInstance).value, 1);
      expect((all[1] as TestBaseKoreInstance).value, 2);
    });

    test('Instance collection prune test', () async {
      instances
        ..addWithParams<int>(
          type: testInstanceRuntimeType,
          params: 1,
          scope: testScope,
        )
        ..increaseReferencesInScope(testScope, TestBaseKoreInstance)
        ..addWithParams<int>(
          type: testInstanceRuntimeType,
          params: 2,
          scope: testScope,
          index: 1,
        )
        ..increaseReferencesInScope(testScope, TestBaseKoreInstance, index: 1);

      var all = instances.all(testScope);

      expect(all.length, 2);

      expect((all[0] as TestBaseKoreInstance).value, 1);
      expect((all[1] as TestBaseKoreInstance).value, 2);

      instances.prune();

      all = instances.all(testScope);

      expect(all.length, 2);
      expect((all[0] as TestBaseKoreInstance).value, 1);
      expect((all[1] as TestBaseKoreInstance).value, 2);

      instances
        ..decreaseReferencesInScope(testScope, TestBaseKoreInstance, index: 1)
        ..prune();

      all = instances.all(testScope);

      expect(all.length, 1);
      expect((all[0] as TestBaseKoreInstance).value, 1);

      instances
        ..decreaseReferencesInScope(testScope, int)
        ..prune();

      all = instances.all(testScope);

      expect(all.length, 1);
      expect((all[0] as TestBaseKoreInstance).value, 1);

      expect(
        () => instances
          ..decreaseReferencesInScope(testScope, TestBaseKoreInstance,
              index: 10)
          ..prune(),
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(
        () => instances
          ..decreaseReferencesInScope(testScope, TestBaseKoreInstance,
              index: -1)
          ..prune(),
        throwsA(isA<IllegalArgumentException>()),
      );

      instances
        ..decreaseReferencesInScope(testScope, TestBaseKoreInstance)
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
      expect((all[0] as TestBaseKoreInstance).value, 1);
      expect((all[1] as TestBaseKoreInstance).value, 2);
    });

    test('Instance collection add existing test', () async {
      instances.addExisting(
          scope: testScope, instance: TestBaseKoreInstance()..initialize(3));

      expect(instances.get<TestBaseKoreInstance>(scope: testScope).value, 3);
    });

    test('Instance collection add test test', () async {
      instances.addTest<TestBaseKoreInstance>(
        scope: testScope,
        instance: TestBaseKoreInstance()..initialize(3),
      );

      expect(instances.get<TestBaseKoreInstance>(scope: testScope).value, 3);
    });

    test('Instance collection add test overrideMainInstance test', () async {
      instances.addTest<TestBaseKoreInstance>(
        scope: testScope,
        instance: TestBaseKoreInstance()..initialize(3),
      );

      expect(instances.get<TestBaseKoreInstance>(scope: testScope).value, 3);

      instances.addTest<TestBaseKoreInstance>(
        scope: testScope,
        instance: TestBaseKoreInstance()..initialize(4),
      );

      expect(instances.get<TestBaseKoreInstance>(scope: testScope).value, 4);

      instances.addTest<TestBaseKoreInstance>(
        scope: testScope,
        instance: TestBaseKoreInstance()..initialize(5),
        overrideMainInstance: false,
      );

      expect(instances.get<TestBaseKoreInstance>(scope: testScope).value, 4);
    });

    test('Instance collection add test uninitialized test', () async {
      instances.addTest<TestBaseKoreInstance>(
        scope: testScope,
        instance: TestBaseKoreInstance(),
      );

      expect(instances.get<TestBaseKoreInstance>(scope: testScope).value, 1);
    });

    test('Instance collection clear test', () async {
      instances.addExisting(
          scope: testScope, instance: TestBaseKoreInstance()..initialize(3));

      expect(instances.get<TestBaseKoreInstance>(scope: testScope).value, 3);

      instances.clear();

      expect(instances.all(testScope).length, 0);
    });

    test('Instance collection find test', () async {
      instances.addExisting(
          scope: testScope, instance: TestBaseKoreInstance()..initialize(3));

      expect(instances.find<TestBaseKoreInstance>(testScope)!.value, 3);

      instances.clear();

      expect(instances.find<TestBaseKoreInstance>(testScope), null);
    });

    test('Instance collection getUniqueAsync test', () async {
      expect((await instances.getUniqueAsync<TestBaseKoreInstance>()).value, 1);
    });

    test('Instance collection getUniqueWithParamsAsync test', () async {
      expect(
        (await instances.getUniqueWithParamsAsync<TestBaseKoreInstance, int>(
          params: 2,
        ))
            .value,
        2,
      );
    });

    test('Instance collection getAsync test', () async {
      expect((await instances.getAsync<TestBaseKoreInstance>()).value, 1);
    });

    test('Instance collection getWithParamsAsync test', () async {
      expect(
        (await instances.getWithParamsAsync<TestBaseKoreInstance, int>(
                params: 2))
            .value,
        2,
      );
    });

    test('Instance collection getAsync when instance already existing test',
        () async {
      instances.addExisting(
          scope: testScope, instance: TestBaseKoreInstance()..initialize(3));

      expect(
        (await instances.getAsync<TestBaseKoreInstance>(scope: testScope))
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
        ) as TestBaseKoreInstance)
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
        ) as TestBaseKoreInstance)
            .value,
        2,
      );
    });

    test('Instance collection addAsync test', () async {
      await instances.addAsync(
        type: testInstanceRuntimeType,
        scope: testScope,
      );

      expect(instances.get<TestBaseKoreInstance>(scope: testScope).value, 1);
    });

    test('Instance collection addWithParamsAsync test', () async {
      await instances.addWithParamsAsync(
        type: testInstanceRuntimeType,
        params: 2,
        scope: testScope,
      );

      expect(instances.get<TestBaseKoreInstance>(scope: testScope).value, 2);
    });

    test('Instance collection getUnique test', () async {
      expect(instances.getUnique<TestBaseKoreInstance>().value, 1);
    });

    test('Instance collection getUniqueWithParams test', () async {
      expect(
        instances
            .getUniqueWithParams<TestBaseKoreInstance, int>(params: 2)
            .value,
        2,
      );
    });

    test('Instance collection get test', () async {
      expect(instances.get<TestBaseKoreInstance>().value, 1);
    });

    test('Instance collection getWithParams test', () async {
      expect(
        instances.getWithParams<TestBaseKoreInstance, int>(params: 2).value,
        2,
      );
    });

    test('Instance collection get when instance already existing test',
        () async {
      instances.addExisting(
          scope: testScope, instance: TestBaseKoreInstance()..initialize(3));

      expect(
        instances.get<TestBaseKoreInstance>(scope: testScope).value,
        3,
      );
    });

    test('Instance collection getByTypeString test', () async {
      expect(
        (instances.getByTypeString(
          type: testInstanceRuntimeType,
          scope: testScope,
        ) as TestBaseKoreInstance)
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
        ) as TestBaseKoreInstance)
            .value,
        2,
      );
    });

    test('Instance collection add test', () async {
      instances.add(
        type: testInstanceRuntimeType,
        scope: testScope,
      );

      expect(instances.get<TestBaseKoreInstance>(scope: testScope).value, 1);
    });

    test('Instance collection addWithParams test', () async {
      instances.addWithParams(
        type: testInstanceRuntimeType,
        params: 2,
        scope: testScope,
      );

      expect(instances.get<TestBaseKoreInstance>(scope: testScope).value, 2);
    });

    test('Instance collection unregisterInstance test', () async {
      instances.addWithParams(
        type: testInstanceRuntimeType,
        params: 2,
        scope: testScope,
      );

      expect(instances.get<TestBaseKoreInstance>(scope: testScope).value, 2);

      instances.unregisterInstance<TestBaseKoreInstance>(
        scope: testScope,
      );

      expect(instances.forceGet<TestBaseKoreInstance>(scope: testScope), null);
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

      expect(instances.get<TestBaseKoreInstance>().value, 1);
      expect(instances.get<TestBaseKoreInstance2>().value, 2);

      instances.unregisterInstance<TestBaseKoreInstance>();

      expect(instances.forceGet<TestBaseKoreInstance>(), null);
      expect(instances.forceGet<TestBaseKoreInstance2>()!.value, 2);
    });

    test('Instance collection use and dispose instance test', () async {
      await instances
          .useAndDisposeInstance<TestBaseKoreInstance>((instance) async {
        await DelayUtility.pause();
      });

      expect(
        instances.forceGet<TestBaseKoreInstance>(),
        null,
      );
    });

    test('Instance collection use and dispose instance with params test',
        () async {
      await instances
          .useAndDisposeInstanceWithParams<TestBaseKoreInstance, int>(
        1,
        (instance) async {
          await DelayUtility.pause();
        },
      );

      expect(
        instances.forceGet<TestBaseKoreInstance>(),
        null,
      );
    });

    test('Instance collection async beforeInitialize test', () async {
      final instance = await instances
          .constructAndInitializeInstanceAsync<TestAsyncBaseKoreInstance>(
              TestAsyncBaseKoreInstance().runtimeType.toString(),
              beforeInitialize: (instance) {
        instance.value = 3;
      });

      expect(
        instance.value,
        3,
      );
    });

    test('Instance collection async beforeInitialize test', () async {
      try {
        await instances.getUniqueAsync<TestInteractorAsyncSameDependency>();
      } catch (e) {
        expect(
          e is IllegalArgumentException,
          true,
        );
      }
    });
  });
}
