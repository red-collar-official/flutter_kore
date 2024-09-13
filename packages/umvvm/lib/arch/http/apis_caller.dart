import 'package:umvvm/umvvm.dart';

/// Mixin containing logic to collect requests
/// in collection and cancel them in a batch
mixin ApiCaller<Input> on MvvmInstance<Input> {
  /// Collection of requests running in this instance
  final List<BaseRequest> requests = [];

  /// Executes request and adds it in local requests collection
  ///
  /// [request] - request to track
  Future<Response<T>> executeAndCancelOnDispose<T>(
    BaseRequest<T> request,
  ) async {
    requests.add(request);

    final result = await request.execute();

    requests.remove(request);

    return result;
  }

  /// Cancels all requests in local requests collection
  void cancelAllRequests() {
    for (final element in requests) {
      element.cancel();
    }
  }
}
