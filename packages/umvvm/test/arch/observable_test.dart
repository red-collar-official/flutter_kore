import 'package:test/test.dart';
import 'package:umvvm/umvvm.dart';

void main() {
  group('Observable tests', () {
    setUp(() async {
      UMvvmApp.isInTestMode = true;
    });

    test('Observable initial test', () async {
      final Observable<int> observable = Observable.initial(1);

      expect(observable.current, 1);

      observable.dispose();
    });

    test('Observable empty test', () async {
      final Observable<int> observable = Observable();

      expect(observable.current, null);

      observable.dispose();
    });

    test('Observable update test', () async {
      final Observable<int> observable = Observable.initial(1);

      expect(observable.current, 1);

      observable.update(2);

      expect(observable.current, 2);

      observable.dispose();
    });

    test('Observable dispose test', () async {
      final Observable<int> observable = Observable.initial(1);

      expect(observable.current, 1);

      observable.update(2);

      expect(observable.current, 2);

      observable.dispose();

      expect(observable.isDisposed, true);
    });

    test('Observable update after dispose test', () async {
      final Observable<int> observable = Observable.initial(1);

      // ignore: cascade_invocations
      observable.dispose();

      expect(observable.isDisposed, true);
      expect(() => observable.update(2), throwsA(isA<IllegalStateException>()));
    });

    test('Observable dispose after dispose test', () async {
      final Observable<int> observable = Observable.initial(1);

      // ignore: cascade_invocations
      observable.dispose();

      expect(observable.isDisposed, true);
      expect(observable.dispose, throwsA(isA<IllegalStateException>()));
    });
  });
}
