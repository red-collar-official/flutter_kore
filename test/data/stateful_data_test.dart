import 'package:test/test.dart';
import 'package:umvvm/umvvm.dart';

void main() {
  group('StatefulData tests', () {
    setUp(() async {
      UMvvmApp.isInTestMode = true;
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
  });
}
