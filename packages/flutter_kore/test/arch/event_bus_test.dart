import 'dart:async';

import 'package:test/test.dart';
import 'package:flutter_kore/flutter_kore.dart';

import '../helpers/delay_utility.dart';
import '../mocks/test_event.dart';

void main() {
  group('EventBus tests', () {
    late final eventBus = EventBus.newSeparateInstance();

    setUp(() async {
      KoreApp.isInTestMode = true;
    });

    test('EventBus initial test', () async {
      eventBus.send(TestEvent(number: 1));

      expect(eventBus.checkEventWasSent(TestEvent), true);
    });

    test('EventBus listen to event test', () async {
      final completer = Completer();

      final subscription = eventBus.streamOf<TestEvent>().listen((event) {
        if (event.number == 2) {
          completer.complete();
        }
      });

      DelayUtility.withDelay(() {
        eventBus.send(TestEvent(number: 2));
      });

      await completer.future.timeout(const Duration(seconds: 1));

      await subscription.cancel();
    });

    test('EventBus listen to events test', () async {
      final completer = Completer();
      final completer2 = Completer();

      final subscription = eventBus.streamOfCollection([
        TestEvent,
        TestEvent2,
      ]).listen((event) {
        if (event is TestEvent) {
          completer.complete();
        }

        if (event is TestEvent2) {
          completer2.complete();
        }
      });

      DelayUtility.withDelay(() {
        eventBus.send(TestEvent(number: 2));
      });

      DelayUtility.withDelay(
        () {
          eventBus.send(TestEvent2(number: 2));
        },
        millis: 100,
      );

      await completer.future.timeout(const Duration(seconds: 1));
      await completer2.future.timeout(const Duration(seconds: 1));

      await subscription.cancel();
    });

    test('EventBus dispose test', () async {
      final eventBus = EventBus.newSeparateInstance();

      // ignore: cascade_invocations
      eventBus.dispose();

      expect(eventBus.isDisposed, true);

      expect(
        () => eventBus.send(TestEvent(number: 1)),
        throwsA(isA<IllegalStateException>()),
      );
    });

    test('EventBus streamOf after dispose test', () async {
      final eventBus = EventBus.newSeparateInstance();

      // ignore: cascade_invocations
      eventBus.dispose();

      expect(eventBus.isDisposed, true);

      expect(
        () => eventBus.streamOf<TestEvent>(),
        throwsA(isA<IllegalStateException>()),
      );
    });

    test('EventBus streamOfCollection after dispose test', () async {
      final eventBus = EventBus.newSeparateInstance();

      // ignore: cascade_invocations
      eventBus.dispose();

      expect(eventBus.isDisposed, true);

      expect(
        () => eventBus.streamOfCollection([TestEvent]),
        throwsA(isA<IllegalStateException>()),
      );
    });

    test('EventBus dispose after dispose test', () async {
      final eventBus = EventBus.newSeparateInstance();

      // ignore: cascade_invocations
      eventBus.dispose();

      expect(eventBus.isDisposed, true);

      expect(
        eventBus.dispose,
        throwsA(isA<IllegalStateException>()),
      );
    });

    tearDownAll(() async {
      eventBus.dispose();
    });
  });
}
