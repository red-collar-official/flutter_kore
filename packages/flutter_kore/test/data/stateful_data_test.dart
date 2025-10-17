import 'package:test/test.dart';
import 'package:flutter_kore/flutter_kore.dart';

void main() {
  group('StatefulData tests', () {
    setUp(() async {
      KoreApp.isInTestMode = true;
    });

    test('StatefulData unwrap test', () async {
      const statefulDataLoading = LoadingData();
      const statefulDataError = ErrorData();
      const statefulDataSuccess = SuccessData(result: 1);

      expect(
        () => statefulDataLoading.unwrap(),
        throwsA(isA<IllegalStateException>()),
      );

      expect(
        () => statefulDataError.unwrap(),
        throwsA(isA<IllegalStateException>()),
      );

      expect(statefulDataSuccess.unwrap(), 1);
    });

    test('StatefulData constructor test', () async {
      StatefulData<int> statefulData = const LoadingData();

      expect(
        () => statefulData.unwrap(),
        throwsA(isA<IllegalStateException>()),
      );

      statefulData = const ErrorData(error: '');

      expect(
        () => statefulData.unwrap(),
        throwsA(isA<IllegalStateException>()),
      );

      statefulData = const SuccessData(result: 1);

      expect(statefulData.unwrap(), 1);
    });

    test('StatefulData runIfSuccess test', () async {
      StatefulData<int> statefulData = const LoadingData();

      var value = 1;

      statefulData.runIfSuccess((data) {
        value = 2;
      });

      expect(value, 1);

      statefulData = const ErrorData(error: '');

      // ignore: cascade_invocations
      statefulData.runIfSuccess((data) {
        value = 2;
      });

      expect(value, 1);

      statefulData = const SuccessData(result: 1);

      // ignore: cascade_invocations
      statefulData.runIfSuccess((data) {
        value = 2;
      });

      expect(value, 2);

      final result = statefulData.runIfSuccess((data) {
        return 2;
      });

      expect(result, 2);

      statefulData = const ErrorData(error: '');

      final errorResult = statefulData.runIfSuccess((data) {
        return 2;
      });

      expect(errorResult, null);
    });

    test('StatefulData runIfSuccessAsync test', () async {
      StatefulData<int> statefulData = const LoadingData();

      var value = 1;

      await statefulData.runIfSuccessAsync((data) async {
        value = 2;
      });

      expect(value, 1);

      statefulData = const ErrorData(error: '');

      // ignore: cascade_invocations
      await statefulData.runIfSuccessAsync((data) async {
        value = 2;
      });

      expect(value, 1);

      statefulData = const SuccessData(result: 1);

      // ignore: cascade_invocations
      await statefulData.runIfSuccessAsync((data) async {
        value = 2;
      });

      expect(value, 2);

      final result = await statefulData.runIfSuccessAsync((data) async {
        return 2;
      });

      expect(result, 2);

      statefulData = const ErrorData(error: '');

      final errorResult = await statefulData.runIfSuccessAsync((data) async {
        return 2;
      });

      expect(errorResult, null);
    });
  });
}
