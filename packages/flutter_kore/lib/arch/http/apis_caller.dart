import 'package:flutter_kore/flutter_kore.dart';

/// Mixin containing logic to collect requests
/// in collection and cancel them in a batch when [BaseKoreInstance.dispose] called
///
/// ```dart
/// abstract class BaseBox extends BaseKoreInstance<dynamic> with ApiCaller<dynamic> {
///   String get boxName;
///
///   late final hiveWrapper = app.instances.get<HiveWrapper>();
///
///   @mustCallSuper
///   @override
///   void dispose() {
///     super.dispose();
///
///     cancelAllRequests();
///   }
/// }
/// ```
mixin ApiCaller<Input> on KoreInstance<Input> {
  /// Collection of requests running in this instance
  final requests = <BaseRequest>[];

  /// Executes request and adds it in local requests collection
  ///
  /// If this instance is disposed while request is running the request is canceled,
  /// but the returned future still completes and the code after `await`
  /// is executed on a disposed instance
  ///
  /// Usually the result is unsuccessful [Response] with canceled error,
  /// but it can also be successful - for example if request is retried
  /// after [RequestCollection.cancelAllRequests], has [BaseRequest.ignoreCancellations] flag
  /// or returns data from database. Do not rely on [Response.isSuccessful] to detect dispose,
  /// check [KoreInstance.isDisposed] instead
  ///
  /// [request] - request to track
  Future<Response<T>> executeAndCancelOnDispose<T, I, B, F>(
    BaseRequest<T, I, B, F> request,
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
