// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:async';

import 'package:test/test.dart';
import 'package:flutter_kore/flutter_kore.dart';

import '../helpers/delay_utility.dart';
import '../helpers/test_builders.dart';
import '../mocks/test_event.dart';
import '../mocks/test_interactors.dart';

void main() {
  group('Interactor tests', () {
    final instances = InstanceCollection.instance;
    final cache = <String, String?>{};
    final eventBus = EventBus.instance;

    setUpAll(() async {
      KoreApp.isInTestMode = true;

      KoreApp.cacheGetDelegate = (key) {
        return cache[key] ?? '';
      };

      KoreApp.cachePutDelegate = (key, value) async {
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

    test('Interactor wait event is received test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();

      // ignore: cascade_invocations
      eventBus.send(TestEvent(number: 5));

      await interactor3.waitTillEventIsReceived(TestEvent);

      expect(interactor3.checkEventWasReceived(TestEvent), true);
      expect(interactor3.state, 5);

      interactor3.dispose();
    });

    test('Interactor cleanup received events test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();

      // ignore: cascade_invocations
      eventBus.send(TestEvent(number: 5));

      await interactor3.waitTillEventIsReceived(TestEvent);

      expect(interactor3.checkEventWasReceived(TestEvent), true);
      expect(interactor3.state, 5);

      interactor3.cleanupReceivedEvents();

      expect(interactor3.checkEventWasReceived(TestEvent), false);

      interactor3.dispose();
    });

    test('Interactor wait multiple events are received test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();

      for (var i = 0; i < 10; i++) {
        eventBus.send(TestEvent(number: 5));
      }

      await interactor3.waitTillEventIsReceived(TestEvent, count: 10);

      expect(interactor3.checkEventWasReceived(TestEvent, count: 10), true);
      expect(interactor3.state, 5);

      interactor3.dispose();
    });

    test('Interactor wait multiple events are received timeout test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();

      for (var i = 0; i < 10; i++) {
        eventBus.send(TestEvent(number: 5));
      }

      await interactor3.waitTillEventIsReceived(TestEvent, count: 11);

      expect(interactor3.checkEventWasReceived(TestEvent, count: 11), false);
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
      expect(interactor3.testInteractor1.isInitialized, true);

      expect(interactor3.testInteractor2.state, 3);
      expect(interactor3.testInteractor2.isInitialized, true);

      expect(interactor3.testInstancePart3.value, 5);
      expect(interactor3.testInstancePart3.isInitialized, true);

      expect(interactor3.testInstancePart3.testInstancePart2.value, 6);
      expect(
          interactor3.testInstancePart3.testInstancePart2.isInitialized, true);

      expect(
        (interactor3.testInstancePart3.testInstancePart2.rootParentInstance
                as TestInteractor3)
            .state,
        0,
      );

      expect(interactor3.testInstancePart2_1.value, 10);
      expect(interactor3.testInstancePart2_1.isInitialized, true);

      expect(interactor3.testInstancePart2_2.value, 10);
      expect(interactor3.testInstancePart2_2.isInitialized, true);

      expect(interactor3.testInstancePart_1.value, 1);
      expect(interactor3.testInstancePart_1.isInitialized, true);

      expect(interactor3.testInstancePart_2.value, 2);
      expect(interactor3.testInstancePart_2.isInitialized, true);

      expect(interactor3.testInstancePart4_1.value, 1);
      expect(interactor3.testInstancePart4_1.isInitialized, true);

      expect(interactor3.testInstancePart4_2.value, 2);
      expect(interactor3.testInstancePart4_2.isInitialized, true);

      expect(interactor3.testInteractor4_1.state, 3);
      expect(interactor3.testInteractor4_1.isInitialized, true);

      expect(interactor3.testInteractor4_2.state, 3);
      expect(interactor3.testInteractor4_2.isInitialized, true);

      expect(interactor3.testInteractor5_1.state, 1);
      expect(interactor3.testInteractor5_1.isInitialized, true);

      expect(interactor3.testInteractor5_2.state, 2);
      expect(interactor3.testInteractor5_2.isInitialized, true);

      expect(interactor3.testInteractorAsync2_1.state, 3);
      expect(interactor3.testInteractorAsync2_1.isInitialized, true);

      expect(interactor3.testInteractorAsync2_2.state, 3);
      expect(interactor3.testInteractorAsync2_2.isInitialized, true);

      expect(interactor3.testInteractorAsync3_1.state, 1);
      expect(interactor3.testInteractorAsync3_1.isInitialized, true);

      expect(interactor3.testInteractorAsync3_2.state, 2);
      expect(interactor3.testInteractorAsync3_2.isInitialized, true);

      expect(interactor3.testInteractorAsync4.state, 2);
      expect(interactor3.testInteractorAsync4.isInitialized, true);

      expect(interactor3.testInteractor7.isInitialized, true);
      expect(interactor3.testInteractor8.isInitialized, true);

      expect(interactor3.testInteractor9_1.state, 1);
      expect(interactor3.testInteractor9_1.isInitialized, true);

      expect(interactor3.testInteractor9_2.state, 2);
      expect(interactor3.testInteractor9_2.isInitialized, true);

      expect((await interactor3.testInteractorAsync5_1).state, 1);
      expect((await interactor3.testInteractorAsync5_1).isInitialized, true);

      expect((await interactor3.testInteractorAsync5_2).state, 2);
      expect((await interactor3.testInteractorAsync5_2).isInitialized, true);

      expect(interactor3.testInteractor10.state, 2);
      expect(interactor3.testInteractor10.isInitialized, true);

      expect((await interactor3.testInteractorAsync6).state, 2);
      expect((await interactor3.testInteractorAsync6).isInitialized, true);

      expect(interactor3.testInteractor11.state, 2);
      expect(interactor3.testInteractor11.isInitialized, true);

      expect((await interactor3.testInteractorAsync7).state, 2);
      expect((await interactor3.testInteractorAsync7).isInitialized, true);

      // check again cached instances

      expect(interactor3.useLazyLocalInstance<TestInteractor11>().state, 2);
      expect(
        interactor3.useLazyLocalInstance<TestInteractor11>().isInitialized,
        true,
      );

      expect(
        (await interactor3.useAsyncLazyLocalInstance<TestInteractorAsync7>())
            .state,
        2,
      );
      expect(
        (await interactor3.useAsyncLazyLocalInstance<TestInteractorAsync7>())
            .isInitialized,
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
      expect(interactor3.testInteractor12_1.isInitialized, true);

      expect(interactor3.testInteractor12_2.state, 2);
      expect(interactor3.testInteractor12_2.isInitialized, true);

      expect((await interactor3.testInteractorAsync8_1).state, 2);
      expect((await interactor3.testInteractorAsync8_1).isInitialized, true);

      expect((await interactor3.testInteractorAsync8_2).state, 2);
      expect((await interactor3.testInteractorAsync8_2).isInitialized, true);

      expect(interactor3.testModule.testInstancePart5.isInitialized, true);
      expect(interactor3.testModule.testInteractor7.isInitialized, true);
      expect(interactor3.testModule.testInteractor13.isInitialized, true);

      expect(
        (await interactor3.testModule.testInteractorAsync9).isInitialized,
        true,
      );

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

    test('Interactor store wrap updates test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();

      final completer = Completer();

      final stateStream = interactor3.wrapUpdates((state) => state);

      final subscription = stateStream.stream.listen((event) {
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

    test('Interactor store wrap changes test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();

      final completer = Completer();

      final stateStream = interactor3.wrapChanges(
          changeMapper: (state) => state,
          stateMapper: (change) => change.next,
          currentMapper: (state) => state);

      final subscription = stateStream.stream.listen((event) {
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

    test('Interactor store wrap updates current value test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();

      final stateStream = interactor3.wrapUpdates((state) => state);

      interactor3.updateState(2);

      expect(2, stateStream.current);

      interactor3.dispose();
    });

    test('Interactor store wrap changes current value test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();

      final stateStream = interactor3.wrapChanges(
          changeMapper: (state) => state,
          stateMapper: (change) => change.next,
          currentMapper: (state) => state);

      interactor3.updateState(2);

      expect(2, stateStream.current);

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

      expect(interactor3.checkEventWasReceived(TestEvent3), true);
      expect(interactor3.state, 5);

      interactor3.resumeEventBusSubscription();

      await DelayUtility.pause();

      expect(interactor3.state, 6);

      interactor3.dispose();
    });

    test('Interactor errors test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();

      expect(
        interactor3.testInstancePart5.isInitialized,
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

    test('Interactor enqueue operation test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();

      var future1Completed = false;
      var future2Completed = false;
      var future3Completed = false;

      final future1 = () async {
        await Future.delayed(const Duration(seconds: 1));
        future1Completed = true;
      };

      final future2 = () async {
        await Future.delayed(const Duration(seconds: 1));
        future2Completed = true;
      };

      final future3 = () async {
        await Future.delayed(const Duration(seconds: 1));
        future3Completed = true;
      };

      unawaited(interactor3.enqueue(operation: future1));
      unawaited(interactor3.enqueue(operation: future2));
      unawaited(interactor3.enqueue(operation: future3));

      await Future.delayed(const Duration(milliseconds: 500));

      expect(future1Completed, false);
      expect(future2Completed, false);
      expect(future3Completed, false);

      await Future.delayed(const Duration(milliseconds: 600));

      expect(future1Completed, true);
      expect(future2Completed, false);
      expect(future3Completed, false);

      await Future.delayed(const Duration(milliseconds: 1000));

      expect(future1Completed, true);
      expect(future2Completed, true);
      expect(future3Completed, false);

      await Future.delayed(const Duration(milliseconds: 1000));

      expect(future1Completed, true);
      expect(future2Completed, true);
      expect(future3Completed, true);

      interactor3.dispose();
    });

    test('Interactor enqueue operation dispose test', () async {
      final interactor6 = await instances.getUniqueAsync<TestInteractor6>();

      var future1Completed = false;
      var future2Completed = false;
      var future3Completed = false;

      final future1 = () async {
        await Future.delayed(const Duration(seconds: 1));
        future1Completed = true;
      };

      final future2 = () async {
        await Future.delayed(const Duration(seconds: 1));
        future2Completed = true;
      };

      final future3 = () async {
        await Future.delayed(const Duration(seconds: 1));
        future3Completed = true;
      };

      unawaited(interactor6.enqueue(operation: future1));
      unawaited(
          interactor6.enqueue(operation: future2, discardOnDispose: false));
      unawaited(interactor6.enqueue(operation: future3));

      await Future.delayed(const Duration(milliseconds: 500));

      expect(future1Completed, false);
      expect(future2Completed, false);
      expect(future3Completed, false);

      interactor6.dispose();

      await Future.delayed(const Duration(milliseconds: 600));

      expect(future1Completed, true);
      expect(future2Completed, false);
      expect(future3Completed, false);

      await Future.delayed(const Duration(milliseconds: 1000));

      expect(future1Completed, true);
      expect(future2Completed, true);
      expect(future3Completed, false);

      await Future.delayed(const Duration(milliseconds: 1000));

      expect(future1Completed, true);
      expect(future2Completed, true);
      expect(future3Completed, false);
    });

    test('Interactor enqueue operation timeout test', () async {
      final interactor3 = await instances.getUniqueAsync<TestInteractor3>();

      var future1Completed = false;
      var future2Completed = false;
      var future3Completed = false;
      var future3Timeout = false;

      final future1 = () async {
        await Future.delayed(const Duration(seconds: 1));
        future1Completed = true;
      };

      final future2 = () async {
        await Future.delayed(const Duration(seconds: 3));
        future2Completed = true;
      };

      final future3 = () async {
        await Future.delayed(const Duration(seconds: 2));
        future3Completed = true;
      };

      unawaited(interactor3.enqueue(operation: future1));
      unawaited(interactor3.enqueue(
        operation: future2,
        timeout: const Duration(seconds: 1),
      ));
      unawaited(interactor3.enqueue(
        operation: future3,
        timeout: const Duration(seconds: 1),
        onTimeout: () {
          future3Timeout = true;
        },
      ));

      await Future.delayed(const Duration(milliseconds: 500));

      expect(future1Completed, false);
      expect(future2Completed, false);
      expect(future3Completed, false);

      await Future.delayed(const Duration(milliseconds: 600));

      expect(future1Completed, true);
      expect(future2Completed, false);
      expect(future3Completed, false);

      await Future.delayed(const Duration(milliseconds: 1000));

      expect(future1Completed, true);
      expect(future2Completed, false);
      expect(future3Completed, false);

      await Future.delayed(const Duration(milliseconds: 1000));

      expect(future1Completed, true);
      expect(future2Completed, false);
      expect(future3Completed, false);
      expect(future3Timeout, true);

      interactor3.dispose();
    });

    tearDownAll(eventBus.dispose);
  });
}
