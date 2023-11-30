import 'package:test/test.dart';
import 'package:umvvm/arch/utility/debouncer.dart';
import 'package:umvvm/umvvm.dart';

import '../helpers/delay_utility.dart';

void main() {
  group('Debouncer tests', () {
    setUp(() async {
      UMvvmApp.isInTestMode = true;
    });

    test('Debouncer debounce test', () async {
      bool event1Received = false;
      bool event2Received = false;
      bool event3Received = false;

      final debouncer = Debouncer(const Duration(milliseconds: 200));

      debouncer(() {
        event1Received = true;
      });

      await DelayUtility.pause(millis: 250);

      debouncer(() {
        event2Received = true;
      });

      await DelayUtility.pause();

      debouncer(() {
        event3Received = true;
      });

      await DelayUtility.pause(millis: 250);

      expect(event1Received, true);
      expect(event2Received, false);
      expect(event3Received, true);

      debouncer.dispose();
    });

    test('Debouncer processPendingImmediately test', () async {
      bool event1Received = false;
      bool event2Received = false;
      bool event3Received = false;

      final debouncer = Debouncer(const Duration(milliseconds: 200));

      debouncer(() {
        event1Received = true;
      });

      await DelayUtility.pause(millis: 250);

      debouncer(() {
        event2Received = true;
      });

      debouncer.processPendingImmediately();

      await DelayUtility.pause();

      debouncer(() {
        event3Received = true;
      });

      await DelayUtility.pause(millis: 250);

      expect(event1Received, true);
      expect(event2Received, true);
      expect(event3Received, true);

      debouncer.dispose();
    });

    test('Debouncer dispose test', () async {
      final debouncer = Debouncer(const Duration(milliseconds: 200));

      // ignore: cascade_invocations
      debouncer.dispose();

      expect(debouncer.isDisposed, true);
    });

    test('Debouncer call after dispose test', () async {
      final debouncer = Debouncer(const Duration(milliseconds: 200));

      // ignore: cascade_invocations
      debouncer.dispose();

      expect(debouncer.isDisposed, true);

      expect(
        () => debouncer.call(() {}),
        throwsA(isA<IllegalStateException>()),
      );
    });
  });
}
