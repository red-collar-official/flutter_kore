import 'package:test/test.dart';
import 'package:flutter_kore/flutter_kore.dart';

void main() {
  group('ResultState tests', () {
    setUp(() async {
      KoreApp.isInTestMode = true;
    });

    test('ResultState unwrapError test', () async {
      final resultStateError = ResultState.error(
        error: IllegalArgumentException(message: 'test'),
      );

      expect(
        resultStateError.unwrapError<IllegalArgumentException>().message,
        'test',
      );
    });

    test('ResultState unwrapError test', () async {
      final resultStateSuccess = ResultState.success();
      final resultStateError = ResultState.error(
        error: IllegalArgumentException(message: 'test'),
      );

      expect(resultStateSuccess.isSuccessful, true);
      expect(resultStateError.isSuccessful, false);
    });

    test('ResultState check test', () async {
      final resultStateSuccess = ResultState.check();
      final resultStateError = ResultState.check(
        error: IllegalArgumentException(message: 'test'),
      );

      expect(resultStateSuccess.isSuccessful, true);
      expect(resultStateError.isSuccessful, false);
    });
  });
}
