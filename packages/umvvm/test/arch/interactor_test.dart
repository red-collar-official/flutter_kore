import 'dart:async';

import 'package:test/test.dart';
import 'package:umvvm/umvvm.dart';

import '../helpers/delay_utility.dart';
import '../helpers/test_builders.dart';
import '../mocks/test_event.dart';
import '../mocks/test_interactors.dart';

void main() {
  group('Interactor tests', () {
    final instances = InstanceCollection.implementationInstance;
    final cache = <String, String?>{};
    final eventBus = EventBus.instance;

    setUpAll(() async {
      UMvvmApp.isInTestMode = true;

      UMvvmApp.cacheGetDelegate = (key) {
        return cache[key] ?? '';
      };

      UMvvmApp.cachePutDelegate = (key, value) async {
        cache[key] = value;

        return true;
      };

      addTestBuilders(instances);
    });

    test('Interactor initialization error test', () async {
      expect(
        () => instances.getUnique<TestInteractorError>(),
        throwsA(isA<IllegalArgumentException>()),
      );
    });

    test('Interactor initialization error with lazy deps test', () async {
      expect(
        () => instances.getUnique<TestInteractorErrorWithLazyDeps>(),
        throwsA(isA<IllegalArgumentException>()),
      );
    });

    test('Interactor initialization error with async lazy deps test', () async {
      expect(
        () async =>
            instances.getUniqueAsync<TestInteractorErrorWithAsyncLazyDeps>(),
        throwsA(isA<IllegalArgumentException>()),
      );
    });

    test('Interactor initialization error with async deps test', () async {
      expect(
        () async => instances.getUniqueAsync<TestInteractorErrorAsync>(),
        throwsA(isA<IllegalArgumentException>()),
      );
    });

    test('Interactor event bus test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();

      // ignore: cascade_invocations
      eventBus.send(TestEvent(number: 5));

      await DelayUtility.pause();

      expect(interactor3.checkEventWasReceived(TestEvent), true);
      expect(interactor3.state, 5);

      interactor3.dispose();
    });

    test('Interactor initialization test', () async {
      final interactor1 = instances.getUnique<TestInteractor1>();
      final interactor2 = instances.getUnique<TestInteractor2>();
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();
      final interactorAsync =
          await instances.getUniqueAsync<TestInteractorAsync>();

      expect(interactor1.state, 0);
      expect(interactor2.state, 0);
      expect(interactor3.state, 0);
      expect(interactorAsync.state, 0);

      expect(interactor3.testInteractor1.state, 2);
      expect(interactor3.testInteractor1.initialized, true);

      expect(interactor3.testInteractor2.state, 3);
      expect(interactor3.testInteractor2.initialized, true);

      expect(interactor3.testInstancePart3.value, 5);
      expect(interactor3.testInstancePart3.initialized, true);

      expect(interactor3.testInstancePart3.testInstancePart2.value, 6);
      expect(interactor3.testInstancePart3.testInstancePart2.initialized, true);

      expect(
        (interactor3.testInstancePart3.testInstancePart2.rootParentInstance
                as TestInteractor3)
            .state,
        0,
      );

      expect(interactor3.testInstancePart2_1.value, 10);
      expect(interactor3.testInstancePart2_1.initialized, true);

      expect(interactor3.testInstancePart2_2.value, 10);
      expect(interactor3.testInstancePart2_2.initialized, true);

      expect(interactor3.testInstancePart_1.value, 1);
      expect(interactor3.testInstancePart_1.initialized, true);

      expect(interactor3.testInstancePart_2.value, 2);
      expect(interactor3.testInstancePart_2.initialized, true);

      expect(interactor3.testInstancePart4_1.value, 1);
      expect(interactor3.testInstancePart4_1.initialized, true);

      expect(interactor3.testInstancePart4_2.value, 2);
      expect(interactor3.testInstancePart4_2.initialized, true);

      expect(interactor3.testInteractor4_1.state, 3);
      expect(interactor3.testInteractor4_1.initialized, true);

      expect(interactor3.testInteractor4_2.state, 3);
      expect(interactor3.testInteractor4_2.initialized, true);

      expect(interactor3.testInteractor5_1.state, 1);
      expect(interactor3.testInteractor5_1.initialized, true);

      expect(interactor3.testInteractor5_2.state, 2);
      expect(interactor3.testInteractor5_2.initialized, true);

      expect(interactor3.testInteractorAsync2_1.state, 3);
      expect(interactor3.testInteractorAsync2_1.initialized, true);

      expect(interactor3.testInteractorAsync2_2.state, 3);
      expect(interactor3.testInteractorAsync2_2.initialized, true);

      expect(interactor3.testInteractorAsync3_1.state, 1);
      expect(interactor3.testInteractorAsync3_1.initialized, true);

      expect(interactor3.testInteractorAsync3_2.state, 2);
      expect(interactor3.testInteractorAsync3_2.initialized, true);

      expect(interactor3.testInteractorAsync4.state, 2);
      expect(interactor3.testInteractorAsync4.initialized, true);

      expect(interactor3.testInteractor7.initialized, true);
      expect(interactor3.testInteractor8.initialized, true);

      expect(interactor3.testInteractor9_1.state, 1);
      expect(interactor3.testInteractor9_1.initialized, true);

      expect(interactor3.testInteractor9_2.state, 2);
      expect(interactor3.testInteractor9_2.initialized, true);

      expect((await interactor3.testInteractorAsync5_1).state, 1);
      expect((await interactor3.testInteractorAsync5_1).initialized, true);

      expect((await interactor3.testInteractorAsync5_2).state, 2);
      expect((await interactor3.testInteractorAsync5_2).initialized, true);

      expect(interactor3.testInteractor10.state, 2);
      expect(interactor3.testInteractor10.initialized, true);

      expect((await interactor3.testInteractorAsync6).state, 2);
      expect((await interactor3.testInteractorAsync6).initialized, true);

      expect(interactor3.testInteractor11.state, 2);
      expect(interactor3.testInteractor11.initialized, true);

      expect((await interactor3.testInteractorAsync7).state, 2);
      expect((await interactor3.testInteractorAsync7).initialized, true);

      // check again cached instances

      expect(interactor3.getLazyLocalInstance<TestInteractor11>().state, 2);
      expect(
        interactor3.getLazyLocalInstance<TestInteractor11>().initialized,
        true,
      );

      expect(
        (await interactor3.getAsyncLazyLocalInstance<TestInteractorAsync7>())
            .state,
        2,
      );
      expect(
        (await interactor3.getAsyncLazyLocalInstance<TestInteractorAsync7>())
            .initialized,
        true,
      );

      expect(
        () => interactor3.testInteractor9_error_1,
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(
        () => interactor3.testInteractor10_error_2,
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(
        () async => interactor3.testInteractorAsync5_error_1,
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(
        () async => interactor3.testInteractorAsync6_error_2,
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(interactor3.testInteractor12_1.state, 2);
      expect(interactor3.testInteractor12_1.initialized, true);

      expect(interactor3.testInteractor12_2.state, 2);
      expect(interactor3.testInteractor12_2.initialized, true);

      expect((await interactor3.testInteractorAsync8_1).state, 2);
      expect((await interactor3.testInteractorAsync8_1).initialized, true);

      expect((await interactor3.testInteractorAsync8_2).state, 2);
      expect((await interactor3.testInteractorAsync8_2).initialized, true);

      interactor1.dispose();
      interactor2.dispose();
      interactor3.dispose();
      interactorAsync.dispose();
    });

    test('Interactor store initial state test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();

      expect(interactor3.state, 0);

      interactor3.dispose();
    });

    test('Interactor store update state test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();

      interactor3.updateState(1);

      expect(interactor3.state, 1);

      interactor3.dispose();
    });

    test('Interactor store updates test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();

      final completer = Completer();

      final subscription =
          interactor3.updates((state) => state).listen((event) {
        if (event == 2) {
          completer.complete();
        }
      });

      DelayUtility.withDelay(() {
        interactor3.updateState(2);
      });

      await completer.future.timeout(const Duration(seconds: 1));

      await subscription.cancel();

      interactor3.dispose();
    });

    test('Interactor state stream test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();

      final completer = Completer();

      final subscription = interactor3.stateStream.listen((event) {
        if (event == 2) {
          completer.complete();
        }
      });

      DelayUtility.withDelay(() {
        interactor3.updateState(2);
      });

      await completer.future.timeout(const Duration(seconds: 1));

      await subscription.cancel();

      interactor3.dispose();
    });

    test('Interactor store changes test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();

      final completer = Completer();

      final subscription =
          interactor3.changes((state) => state).listen((event) {
        if (event.next == 2) {
          completer.complete();
        }
      });

      DelayUtility.withDelay(() {
        interactor3.updateState(2);
      });

      await completer.future.timeout(const Duration(seconds: 1));

      await subscription.cancel();

      interactor3.dispose();
    });

    test('Interactor store dispose test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();

      // ignore: cascade_invocations
      interactor3.dispose();

      expect(interactor3.isDisposed, true);
    });

    test('Interactor store updateState after dispose test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();

      // ignore: cascade_invocations
      interactor3.dispose();

      expect(interactor3.isDisposed, true);

      expect(
        () => interactor3.updateState(1),
        throwsA(isA<IllegalStateException>()),
      );
    });

    test('Interactor async unconnected store initial state test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>(
        withoutConnections: true,
      );

      expect(interactor3.state, 0);

      interactor3.updateState(1);

      expect(interactor3.state, 1);

      interactor3.dispose();
    });

    test('Interactor unconnected store initial state test', () async {
      final interactor1 = instances.getUnique<TestInteractor1>(
        withoutConnections: true,
      );

      expect(interactor1.state, 0);

      interactor1.updateState(1);

      expect(interactor1.state, 1);

      interactor1.dispose();
    });

    test('Interactor async unconnected store initial state test', () async {
      final interactor1 = await instances.getUniqueAsync<TestInteractor3>(
        withoutConnections: true,
      );

      expect(interactor1.state, 0);

      interactor1.updateState(1);

      expect(interactor1.state, 1);

      interactor1.dispose();
    });

    test('Interactor restore state test', () async {
      final interactor1 = instances.getUnique<TestInteractorWithRestore>();

      expect(interactor1.state, 0);

      interactor1.updateState(1);

      expect(interactor1.state, 1);

      await DelayUtility.pause();

      final interactor1New = instances.getUnique<TestInteractorWithRestore>();

      expect(interactor1New.state, 1);

      interactor1.dispose();
      interactor1New.dispose();
    });

    test('Interactor default restore state test', () async {
      final interactor1 =
          instances.getUnique<TestInteractorWithDefaultRestore>();

      expect(interactor1.state, 0.0);

      interactor1.updateState(1);

      expect(interactor1.state, 1.0);

      await DelayUtility.pause();

      final interactor1New =
          instances.getUnique<TestInteractorWithDefaultRestore>();

      expect(interactor1New.state, 0.0);

      interactor1.dispose();
      interactor1New.dispose();
    });

    test('Interactor async restore state test', () async {
      final interactor1 = instances.getUnique<TestInteractorWithAsyncRestore>();

      // ignore: cascade_invocations
      interactor1.updateState(1);

      expect(interactor1.state, 1);

      await DelayUtility.pause();

      final interactor1New =
          instances.getUnique<TestInteractorWithAsyncRestore>();

      await DelayUtility.pause();

      expect(interactor1New.state, 1);

      interactor1.dispose();
      interactor1New.dispose();
    });

    test('Interactor pause test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();

      // ignore: cascade_invocations
      eventBus.send(TestEvent(number: 5));

      await DelayUtility.pause();

      interactor3.checkEventWasReceived(TestEvent);

      expect(interactor3.checkEventWasReceived(TestEvent), true);
      expect(interactor3.state, 5);

      interactor3.pauseEventBusSubscription();

      // ignore: cascade_invocations
      eventBus.send(TestEvent(number: 5));

      await DelayUtility.pause();

      expect(interactor3.checkEventWasReceived(TestEvent), true);
      expect(interactor3.state, 5);

      eventBus.send(TestEvent2(number: 6));

      await DelayUtility.pause();

      expect(interactor3.checkEventWasReceived(TestEvent2), true);
      expect(interactor3.state, 5);

      eventBus.send(TestEvent3(number: 7));

      await DelayUtility.pause();

      expect(interactor3.checkEventWasReceived(TestEvent3), false);
      expect(interactor3.state, 5);

      interactor3.resumeEventBusSubscription();

      await DelayUtility.pause();

      expect(interactor3.state, 6);

      interactor3.dispose();
    });

    test('Interactor errors test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();

      expect(
        interactor3.testInstancePart5.initialized,
        true,
      );

      expect(
        () => interactor3.testInstancePart5_error_1,
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(
        () => interactor3.testInstancePart5_error_2,
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(
        () => interactor3.testInteractor1_error_1,
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(
        () => interactor3.testInteractor1_error_2,
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(
        () => interactor3.testInteractor1_error_no_object,
        throwsA(isA<IllegalStateException>()),
      );

      expect(
        () => interactor3.testPart_error_no_object,
        throwsA(isA<IllegalStateException>()),
      );

      interactor3.dispose();
    });

    test('Interactor cyclic dependency test', () async {
      instances.checkForCyclicDependencies = true;

      expect(
        () => instances.getWithParams<TestInteractorCyclic, int>(
          params: 1,
          scope: BaseScopes.weak,
        ),
        throwsA(isA<IllegalArgumentException>()),
      );

      instances.checkForCyclicDependencies = false;

      expect(
        () => instances.getWithParams<TestInteractorCyclic, int>(
          params: 1,
          scope: BaseScopes.weak,
        ),
        throwsA(isA<StackOverflowError>()),
      );
    });

    test('Interactor cyclic dependency success test', () async {
      instances.checkForCyclicDependencies = true;

      final instance = await instances.getWithParamsAsync<TestInteractor3, int>(
        params: 1,
        scope: BaseScopes.weak,
      );

      expect(instance.state, 1);
    });

    tearDownAll(eventBus.dispose);
  });
}
