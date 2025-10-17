import 'dart:async';

import 'package:test/test.dart';
import 'package:flutter_kore/flutter_kore.dart';

import '../helpers/delay_utility.dart';

class TestState {
  final int number;

  TestState({
    required this.number,
  });

  TestState copyWith({required int number}) {
    return TestState(number: number);
  }
}

void main() {
  group('Store tests', () {
    late final store = Store<TestState>();

    setUp(() async {
      KoreApp.isInTestMode = true;

      store.initialize(TestState(number: 0));
    });

    test('Store initial state test', () async {
      expect(store.state.number, 0);
    });

    test('Store update state test', () async {
      store.updateState(store.state.copyWith(number: 1));

      expect(store.state.number, 1);
    });

    test('Store updates test', () async {
      final completer = Completer();

      final subscription =
          store.updates((state) => state.number).listen((event) {
        if (event == 2) {
          completer.complete();
        }
      });

      DelayUtility.withDelay(() {
        store.updateState(TestState(number: 2));
      });

      await completer.future.timeout(const Duration(seconds: 1));

      await subscription.cancel();
    });

    test('Store changes test', () async {
      final completer = Completer();

      final subscription =
          store.changes((state) => state.number).listen((event) {
        if (event.next == 2) {
          completer.complete();
        }
      });

      DelayUtility.withDelay(() {
        store.updateState(TestState(number: 2));
      });

      await completer.future.timeout(const Duration(seconds: 1));

      await subscription.cancel();
    });

    test('Store dispose test', () async {
      final store = Store<TestState>();

      // ignore: cascade_invocations
      store.initialize(TestState(number: 0));

      // ignore: cascade_invocations
      store.dispose();

      expect(store.isDisposed, true);
    });

    test('Store updateState after dispose test', () async {
      final store = Store<TestState>();

      // ignore: cascade_invocations
      store.initialize(TestState(number: 0));

      // ignore: cascade_invocations
      store.dispose();

      expect(store.isDisposed, true);

      expect(
        () => store.updateState(TestState(number: 1)),
        throwsA(isA<IllegalStateException>()),
      );
    });

    test('Store dispose after dispose test', () async {
      final store = Store<TestState>();

      // ignore: cascade_invocations
      store.initialize(TestState(number: 0));

      // ignore: cascade_invocations
      store.dispose();

      expect(store.isDisposed, true);

      expect(
        store.dispose,
        throwsA(isA<IllegalStateException>()),
      );
    });

    test('Store updates after dispose test', () async {
      final store = Store<TestState>();

      // ignore: cascade_invocations
      store.initialize(TestState(number: 0));

      // ignore: cascade_invocations
      store.dispose();

      expect(store.isDisposed, true);

      expect(
        () => store.updates((state) => state),
        throwsA(isA<IllegalStateException>()),
      );
    });

    test('Store changes after dispose test', () async {
      final store = Store<TestState>();

      // ignore: cascade_invocations
      store.initialize(TestState(number: 0));

      // ignore: cascade_invocations
      store.dispose();

      expect(store.isDisposed, true);

      expect(
        () => store.changes((state) => state),
        throwsA(isA<IllegalStateException>()),
      );
    });

    tearDownAll(() async {
      store.dispose();
    });
  });
}
