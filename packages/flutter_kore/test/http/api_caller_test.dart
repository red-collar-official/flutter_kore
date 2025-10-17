import 'dart:async';

import 'package:dio/dio.dart' as dio;

import 'package:test/test.dart';
import 'package:flutter_kore/flutter_kore.dart';

import '../helpers/delay_utility.dart';
import '../helpers/test_builders.dart';
import '../mocks/request.dart';
import '../mocks/test_interactors.dart';
import 'request_test.dart';

void main() {
  group('ApiCaller tests', () {
    final instances = InstanceCollection.instance;

    setUp(() async {
      KoreApp.isInTestMode = true;

      addTestBuilders(instances);
    });

    test('ApiCaller dispose test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.post
        ..baseUrl = testBaseUrl
        ..url = testPath;

      addTestResponsesToDio(request.httpInstance!);

      final request2 = HttpRequest<int>()
        ..method = RequestMethod.get
        ..baseUrl = testBaseUrl
        ..url = testPath;

      addTestResponsesToDio(request2.httpInstance!);

      final interactor =
          await instances.getUniqueAsync<TestInteractorWithRequest>();

      late Response<int> response1;
      late Response<int> response2;

      unawaited(interactor.executeAndCancelOnDispose(request).then((value) {
        response1 = value;
      }));

      unawaited(interactor.executeAndCancelOnDispose(request2).then((value) {
        response2 = value;
      }));

      await DelayUtility.pause();

      interactor.dispose();

      await DelayUtility.pause();

      expect(response1.isSuccessful, false);
      expect(response2.isSuccessful, false);

      expect(
        (response1.error as dio.DioException).type ==
            dio.DioExceptionType.cancel,
        true,
      );
      expect(
        (response2.error as dio.DioException).type ==
            dio.DioExceptionType.cancel,
        true,
      );
    });
  });
}
