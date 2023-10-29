import 'package:test/test.dart';
import 'package:umvvm/umvvm.dart';

import '../helpers/delay_utility.dart';
import '../helpers/test_builders.dart';
import '../mocks/test_event.dart';
import '../mocks/test_wrappers.dart';

void main() {
  group('Wrapper tests', () {
    final instances = InstanceCollection.implementationInstance;
    final cache = <String, String>{};
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

    test('Wrapper initialization error test', () async {
      expect(
        () async => instances.getUniqueAsync<TestWrapperError>(),
        throwsA(isA<IllegalArgumentException>()),
      );
    });

    test('Wrapper event bus test', () async {
      final wrapper3 = await instances.getUniqueAsync<TestWrapper3>();

      // ignore: cascade_invocations
      eventBus.send(TestEvent(number: 5));

      await DelayUtility.pause();

      expect(wrapper3.checkEventWasReceived(TestEvent), true);
      expect(wrapper3.value, 5);

      wrapper3.dispose();
    });

    test('Wrapper initialization test', () async {
      final wrapper1 = instances.getUnique<TestWrapper1>();
      final wrapper2 = instances.getUnique<TestWrapper2>();
      final wrapper3 = await instances.getUniqueAsync<TestWrapper3>();
      final wrapperAsync = await instances.getUniqueAsync<TestWrapperAsync>();

      expect(wrapper1.value, null);
      expect(wrapper2.value, null);
      expect(wrapper3.value, null);
      expect(wrapperAsync.value, null);

      expect(wrapper3.testWrapper1.initialized, true);

      expect(wrapper3.testWrapper2.initialized, true);

      expect(wrapper3.testInstancePart3.initialized, true);

      expect(wrapper3.testInstancePart3.testInstancePart2.value, 6);
      expect(wrapper3.testInstancePart3.testInstancePart2.initialized, true);

      expect(wrapper3.testInstancePart2_1.value, 10);
      expect(wrapper3.testInstancePart2_1.initialized, true);

      expect(wrapper3.testInstancePart2_2.value, 10);
      expect(wrapper3.testInstancePart2_2.initialized, true);

      expect(wrapper3.testInstancePart_1.value, 1);
      expect(wrapper3.testInstancePart_1.initialized, true);

      expect(wrapper3.testInstancePart_2.value, 2);
      expect(wrapper3.testInstancePart_2.initialized, true);

      expect(wrapper3.testInstancePart4_1.value, 1);
      expect(wrapper3.testInstancePart4_1.initialized, true);

      expect(wrapper3.testInstancePart4_2.value, 2);
      expect(wrapper3.testInstancePart4_2.initialized, true);

      expect(
        () => wrapper3.testWrapperAsync2.testWrapperAsync,
        throwsA(isA<IllegalStateException>()),
      );

      wrapper1.dispose();
      wrapper2.dispose();
      wrapper3.dispose();
      wrapperAsync.dispose();
    });

    test('Wrapper holder initialization test', () async {
      final holderWrapper =
          await instances.getUniqueWithParamsAsync<TestHolderWrapper, int>(
        params: 3,
      );

      expect(holderWrapper.instance, 3);

      holderWrapper.dispose();
    });

    test('Wrapper dispose test', () async {
      final wrapper3 = await instances.getUniqueAsync<TestWrapper3>();

      // ignore: cascade_invocations
      wrapper3.dispose();

      expect(wrapper3.isDisposed, true);
    });

    test('Wrapper holder dispose test', () async {
      final holderWrapper = await instances.getUniqueAsync<TestHolderWrapper>();

      // ignore: cascade_invocations
      holderWrapper.dispose();

      expect(holderWrapper.isDisposed, true);
    });

    test('Wrapper pause test', () async {
      final wrapper3 = await instances.getUniqueAsync<TestWrapper3>();

      // ignore: cascade_invocations
      eventBus.send(TestEvent(number: 5));

      await DelayUtility.pause();

      wrapper3.checkEventWasReceived(TestEvent);

      expect(wrapper3.checkEventWasReceived(TestEvent), true);
      expect(wrapper3.value, 5);

      wrapper3.pauseEventBusSubscription();

      // ignore: cascade_invocations
      eventBus.send(TestEvent(number: 5));

      await DelayUtility.pause();

      expect(wrapper3.checkEventWasReceived(TestEvent), true);
      expect(wrapper3.value, 5);

      eventBus.send(TestEvent2(number: 6));

      await DelayUtility.pause();

      expect(wrapper3.checkEventWasReceived(TestEvent2), true);
      expect(wrapper3.value, 5);

      eventBus.send(TestEvent3(number: 7));

      await DelayUtility.pause();

      expect(wrapper3.checkEventWasReceived(TestEvent3), false);
      expect(wrapper3.value, 5);

      wrapper3.resumeEventBusSubscription();

      await DelayUtility.pause();

      expect(wrapper3.value, 6);

      wrapper3.dispose();
    });

    test('Wrapper errors test', () async {
      final wrapper3 = await instances.getUniqueAsync<TestWrapper3>();

      expect(
        wrapper3.testInstancePart5.initialized,
        true,
      );

      expect(
        () => wrapper3.testInstancePart5_error_1,
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(
        () => wrapper3.testInstancePart5_error_2,
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(
        () => wrapper3.testWrapper1_error_1,
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(
        () => wrapper3.testWrapper1_error_2,
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(
        () => wrapper3.testWrapper1_error_no_object,
        throwsA(isA<IllegalStateException>()),
      );

      expect(
        () => wrapper3.testPart_error_no_object,
        throwsA(isA<IllegalStateException>()),
      );

      wrapper3.dispose();
    });

    tearDownAll(eventBus.dispose);
  });
}
